local class = require("lay.class")
local css = require("lay.css")

local view = class()
view.name = "view"

local NEXT_VIEW_ID = 1

-- This constructor could be improved a lot
function view:new(t)
  if t.id == nil then
    t.id = "." .. NEXT_VIEW_ID
    NEXT_VIEW_ID = NEXT_VIEW_ID + 1
  end

  t.destroyed = false
  t.isDirty = false

  t.listeners = {}

  if t.style == nil then
    t.style = {}
  end

  -- if t.style.background == nil then
  --   t.style.background = {love.math.random()*255,love.math.random()*255,love.math.random()*255}
  -- end

  if t.children == nil then
    t.children = {}

    for i, child in ipairs(t) do
      if child.parent ~= nil then
        error("child #" .. i .. " already has a parent")
      end

      child.parent = t

      t.children[i] = child
      t[i] = nil
    end
  else
    for i, child in ipairs(t.children) do
      if child.parent ~= nil then
        error("child #" .. i .. " already has a parent")
      end

      child.parent = t
    end
  end

  setmetatable(t, self)
  return t
end

function view.__instance:destroy()
  self.destroyed = true

  if self.parent ~= nil then
    self.parent:remove(self)
    self.parent = nil
  end
end

function view.__instance:add(child)
  if child.parent ~= nil then
    error("child already has a parent")
  end

  table.insert(self.children, child)
  child.parent = self
  child:dirty()
end

function view.__instance:remove(child)
  if child.parent ~= self then
    error("child parent is not self")
  end

  for i, other in ipairs(self.children) do
    if child == other then
      child.parent = nil
      table.remove(self.children, i)
      self:dirty()
      return
    end
  end

  error("could not find own child in list")
end

function view.__instance:dirty()
  if not self.isDirty then
    self.isDirty = true

    if self.parent ~= nil then
      self.parent:dirty()
    end
  end
end

function view.__instance:get_relative_position()
  return 0, 0
end

function view.__instance:get_absolute_position()
  local x, y = self.layout.left, self.layout.top

  if self.parent ~= nil then
    local i, j = self.parent:get_absolute_position()
    local a, b = self.parent:get_relative_position()
    return x + i + a, y + j + b
  end

  return x, y
end

function view.__instance:reflow()
  if css.computeLayout(self) then
    -- flash change
  end
end

function view.__instance:__post_reflow()
end

function view.__instance:by_id(id)
  if self.id == id then return self end

  for _, child in ipairs(self.children) do
    local find = child:by_id(id)
    if find ~= nil then return find end
  end
end

function view.__instance:contains_point(x, y)
  local x1, y1 = self:get_absolute_position()

  return not self.destroyed and
    x >= x1 and x <= x1 + self.layout.width and
    y >= y1 and y <= y1 + self.layout.height
end

function view.__instance:pick_view(x, y)
  for _, child in ipairs(self.children) do
    local pick = child:pick_view(x, y)
    if pick ~= nil then return pick, child end
  end

  if self:contains_point(x, y) then
    return self
  end
end

function view.__instance:set_style_width(width)
  if width ~= self.style.width then
    self.style.width = width
    self:dirty()
  end
end

function view.__instance:set_style_height(height)
  if height ~= self.style.height then
    self.style.height = height
    self:dirty()
  end
end

function view.__instance:send(event, ...)
  local on = self["on" .. event]
  if on ~= nil then
    local result = on(self, ...)
    if result ~= nil then return result end
  end

  local listeners = self.listeners[event]
  if listeners ~= nil then
    for i = #listeners, 1, -1 do
      local result = listeners[i](self, ...)
      if result ~= nil then return result end
    end
  end
end

function view.__instance:on(event, handler)
  if self.listeners[event] == nil then
    self.listeners[event] = {handler}
  else
    table.insert(self.listeners[event], handler)
  end
end

function view.__instance:mousepressed(x, y, button)
  for i = #self.children, 1, -1 do
    local child = self.children[i]
    local result = child:mousepressed(x, y, button)
    if result ~= nil then return result end
  end

  if self:contains_point(x, y) then
    return self:send("click", x, y, button)
  end
end

function view.__instance:wheelmoved(x, y)
  for i = #self.children, 1, -1 do
    local child = self.children[i]
    local result = child:wheelmoved(x, y)
    if result ~= nil then return result end
  end
end

local function draw_border(x, y, w, h, size)
  love.graphics.setLineWidth(size)
  love.graphics.rectangle("line",
    x - size / 2, y - size / 2,
    size + w, size + h,
    math.pi / 2, 0)
end

function view.__instance:draw_content()
  for _, child in ipairs(self.children) do
    child:draw()
  end
end

function view.__instance:draw()
  if self.style.visible == false then
    return
  end

  local x, y = self:get_absolute_position()
  local width, height = self.layout.width, self.layout.height

  if self.style.background ~= nil then
    love.graphics.setColor(self.style.background)
    love.graphics.rectangle("fill", x, y, width, height)
  end

  if self.style.borderColor ~= nil then
    love.graphics.setColor(self.style.borderColor)
    draw_border(x, y, width, height, self.style.borderWidth)
  end

  self:draw_content(x, y, width, height)
end

return view
