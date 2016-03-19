local lay = require("lay")
local class = require("lay.class")

local inspector = class()

local CHR_X = "\xe2\x9c\x95"

local function text_strip_color(text)
  if type(text) == "table" then
    local segments = {}
    for i = 2, #text, 2 do table.insert(segments, text[i]) end
    return table.concat(segments)
  end
  return text
end

function inspector:new(t)
  assert(t.root, "missing view root")

  local make_font
  if t.font_file then
    function make_font(size)
      return love.graphics.newFont(t.font_file, size)
    end
  else
    make_font = love.graphics.newFont
  end

  t.font_small = make_font(12)
  if t.font_small:hasGlyphs(CHR_X) then
    t.chr_x = CHR_X
  else
    t.chr_x = "x"
  end

  t.font_medium = make_font(14)
  t.font_large = make_font(20)

  t.details_panel = lay.view {
    style = {
      padding = 8,
      alignItems = "flex-end"
    },
    -- lay.view {
    --   style = {
    --     width = 200, padding = 6,
    --     background = {230, 230, 230},
    --     borderWidth = 4, borderColor = {100, 100, 100}
    --   },
    --   lay.text {text = "tree goes here"}
    -- },
    lay.view {
      style = {
        width = 300, padding = 6,
        background = {230, 230, 230},
        borderWidth = 4, borderColor = {100, 100, 100}
      },
      lay.text {text = "Details", font = t.font_large, style = {marginBottom = 8}},
      lay.view {style = {flexDirection = "row"},
        lay.text {text = "Type:", font = t.font_medium, style = {marginRight = 6}},
        lay.text {id = "type", font = t.font_medium},
      },
      lay.view {style = {flexDirection = "row"},
        lay.text {text = "Id:", font = t.font_medium, style = {marginRight = 6}},
        lay.text {id = "id", font = t.font_medium},
      },
      lay.view {style = {background = {150, 150, 150}, height = 2, marginTop = 12, marginBottom = 12}},
      lay.text {id = "style", font = t.font_medium}
      -- lay.view {style = {flexDirection = "row"},
      --   lay.text {text = "Size:", font = t.font_medium, style = {marginRight = 6}},
      --   lay.text {id = "width", font = t.font_medium},
      --   lay.text {text = t.chr_x, font = t.font_medium, color = {150, 150, 150}, style = {marginLeft = 4, marginRight = 4}},
      --   lay.text {id = "height", font = t.font_medium}
      -- },
    }
  }

  return setmetatable(t, self)
end

function inspector.__instance:get_selected()
  if self.selected ~= nil then
    if self.selected.destroyed or
      (self.selected.parent == nil and self.selected ~= self.root) then
      self.selected = nil
    else
      return self.selected
    end
  end
end

function inspector.__instance:keypressed(key)
  local selected = self:get_selected()

  if key == "delete" then
    if selected and selected ~= self.root then
      selected:destroy()
      self.selected = nil
      return true
    end
  elseif key == "escape" then
    if selected then
      self.selected = nil
      return true
    end
  end
end

function inspector.__instance:mousepressed(x, y, button)
  if not love.keyboard.isDown("lctrl") then
    if self:get_selected() then
      self.selected = nil
      return true
    end
  elseif button == 1 then
    self.selected = self.root:pick_view(x, y)
    if self.selected ~= nil then
      return true
    end
  end
end

local function dashed_line(x1, y1, x2, y2)
  local nsolid = 4
  local nblank = 6

  local dx = x2 - x1
  local dy = y2 - y1
  local len = math.sqrt(dx*dx + dy*dy)
  local sx = dx / len
  local sy = dy / len

  for i = 0, len, nsolid + nblank do
    love.graphics.line(
      x1 + sx * i,
      y1 + sy * i,
      x1 + sx * (i + nsolid),
      y1 + sy * (i + nsolid)
    )
  end
end

function inspector.__instance:draw_overlay(view)
  local gw, gh = love.graphics.getDimensions()
  local left, top = view:get_absolute_position()
  local width, height = view.layout.width, view.layout.height
  local right, bottom = left + width, top + height
  local style = view.style

  -- Content overlay
  love.graphics.setColor(50, 200, 255, 100)
  love.graphics.rectangle("fill", left, top, width, height)

  -- Dashed lines on edge axes
  love.graphics.setColor(25, 100, 127, 150)
  love.graphics.setLineWidth(0.5)
  local rl = math.floor(  left) - 0.5
  local rr = math.floor( right) + 0.5
  local rt = math.floor(   top) - 0.5
  local rb = math.floor(bottom) + 0.5
  dashed_line(rl,  0, rl, gh)
  dashed_line(rr,  0, rr, gh)
  dashed_line( 0, rt, gw, rt)
  dashed_line( 0, rb, gw, rb)

  -- Margin overlay
  love.graphics.setColor(255, 255, 0, 50)
  local marginTop = style.marginTop or style.margin or 0
  love.graphics.rectangle("fill", left, top - marginTop, width, marginTop)
  local marginBottom = style.marginBottom or style.margin or 0
  love.graphics.rectangle("fill", left, bottom, width, marginBottom)
  local marginLeft = style.marginLeft or style.margin or 0
  love.graphics.rectangle("fill", left - marginLeft, top, marginLeft, height)
  local marginRight = style.marginRight or style.margin or 0
  love.graphics.rectangle("fill", right, top, marginRight, height)

  -- Padding overlay
  love.graphics.setColor(0, 0, 200, 50)
  local paddingTop = style.paddingTop or style.padding or 0
  love.graphics.rectangle("fill", left, top, width, paddingTop)
  local paddingBottom = style.paddingBottom or style.padding or 0
  love.graphics.rectangle("fill", left, bottom - paddingBottom, width, paddingBottom)
  local paddingLeft = style.paddingLeft or style.padding or 0
  love.graphics.rectangle("fill", left, top, paddingLeft, height)
  local paddingRight = style.paddingRight or style.padding or 0
  love.graphics.rectangle("fill", right - paddingRight, top, paddingRight, height)

  -- Draw popup with info
  local text = {
    { 50, 200, 255}, getmetatable(view).name .. "#" .. view.id,
    { 90,  90,  90}, " | ",
    {255, 255, 255}, tostring(width),
    {150, 150, 150}, " " .. self.chr_x .. " ",
    {255, 255, 255}, tostring(height)
  }
  local text_w = self.font_small:getWidth(text_strip_color(text))
  local text_h = self.font_small:getHeight()

  local text_x = math.floor(left + width / 2 - text_w / 2)
  local text_y = math.floor(top - 8 - 4 - text_h)

  text_x = math.max(6, text_x)
  text_y = math.max(6, text_y)

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", text_x - 4, text_y - 4, text_w + 8, text_h + 8, math.pi)
  love.graphics.polygon("fill",
    left + width / 2, top,
    left + width / 2 - 8, top - 8.5,
    left + width / 2 + 8, top - 8.5
  )

  love.graphics.setFont(self.font_small)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, text_x, text_y)
end

function inspector.__instance:draw_details(view)
  local sw, sh = love.graphics.getDimensions()

  self.details_panel:by_id(  "type"):set_text(getmetatable(view).name)
  self.details_panel:by_id(    "id"):set_text(view.id)
  -- self.details_panel:by_id( "width"):set_text(tostring(view.layout.width))
  -- self.details_panel:by_id("height"):set_text(tostring(view.layout.height))

  -- generate style string
  -- this shouldn't be here, but too bad.
  local keys = {}
  local lines = {}

  for k in pairs(view.style) do
    table.insert(keys, k)
  end

  table.sort(keys)

  for _, k in ipairs(keys) do
    if k ~= "measure" then
      local v = view.style[k]

      if type(v) == "table" then
        v = table.concat(v, ", ")
      else
        v = tostring(v)
      end

      table.insert(lines, k .. ": " .. v)
    end
  end

  local style = table.concat(lines, "\n")
  self.details_panel:by_id("style"):set_text(style)

  self.details_panel:set_style_width(sw)
  self.details_panel:set_style_height(sh)

  self.details_panel:reflow()
  self.details_panel:draw()
end

local function txbg(text, x, y)
  local font = love.graphics.getFont()
  local w = font:getWidth(text)
  local h = font:getHeight()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", x, y, w + 4, h + 4)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, x + 2, y + 2)
  return y + h + 4
end

function inspector.__instance:text_tree(x, y, view)
  if view == nil then
    view = self.root
  end

  love.graphics.setFont(self.font_small)
  -- y = txbg(view.id .. ": " .. view.layout.left .. "," .. view.layout.top .. " | " .. view.layout.width .. "x" .. view.layout.height, x, y)
  y = txbg(view.layout.width .. ", " .. view.layout.height .. ", " .. view.layout.top .. ", " .. view.layout.left, x, y)

  for _, child in ipairs(view.children) do
    y = self:text_tree(x + 16, y, child)
  end

  return y
end

function inspector.__instance:draw_debug_tree(view)
  if view == nil then view = self.root end

  self:draw_overlay(view)

  for _, child in ipairs(view.children) do
    self:draw_debug_tree(child)
  end
end

function inspector.__instance:draw()
  collectgarbage()
  collectgarbage()

  local selected = self:get_selected()
  if selected then
    self:draw_overlay(selected)
    self:draw_details(selected)
  end

  -- love.graphics.setColor(255, 255, 255)
  -- love.graphics.setFont(self.font_medium)
  -- love.graphics.print("INSPECTOR ACTIVE", 4, 4)
end

return inspector
