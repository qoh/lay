local class = require("lay.class")
local view = require("lay.views.view")

local scroll = class(view)
scroll.name = "scroll"

function scroll:new(t)
  t = view.new(self, t)

  if t.x == nil then t.x = 0 end
  if t.y == nil then t.y = 0 end

  if type(t.scroll) == "string" then
    t.scroll = love.graphics.scroll(t.scroll)
  end

  return t
end

function scroll.__instance:__post_reflow()
  local max_x, max_y = 0, 0

  for _, child in ipairs(self.children) do
    max_x = math.max(max_x, child.layout.left + child.layout.width + (child.style.marginRight or child.style.margin or 0))
    max_y = math.max(max_y, child.layout.top + child.layout.height + (child.style.marginBottom or child.style.margin or 0))
  end

  self.min_x = 0
  self.min_y = 0
  self.max_x = max_x - self.layout.width
  self.max_y = max_y - self.layout.height

  self.x = math.max(self.min_x, math.min(self.max_x, self.x))
  self.y = math.max(self.min_y, math.min(self.max_y, self.y))
end

function scroll.__instance:get_relative_position()
  if self.parent then
    local px, py = self.parent:get_relative_position()
    return -self.x + px, -self.y + py
  else
    return -self.x, -self.y
  end
end

function scroll.__instance:wheelmoved(x, y)
  if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
    x, y = y, x
  end

  self.x = math.max(self.min_x, math.min(self.max_x, self.x - x * 50))
  self.y = math.max(self.min_y, math.min(self.max_y, self.y - y * 50))
end

function scroll.__instance:draw_content(x, y, width, height)
  -- local x, y = self:get_absolute_position()
  -- local width, height = self.layout.width, self.layout.height

  local scx, scy, scw, sch = love.graphics.getScissor()
  love.graphics.setScissor(x, y, width, height)

  for _, child in ipairs(self.children) do
    child:draw()
  end

  love.graphics.setScissor(scx, scy, scw, sch)

  local bar_width = 4
  local bar_radius = math.pi * 2

  if self.max_y > 0 then
    local bar_length = height * (height / (self.max_y + height))
    local bar_offset = (self.y / self.max_y) * (height - bar_length)

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill",
      x + width - bar_width, y + bar_offset,
      bar_width, bar_length, bar_radius)
  end

  if self.max_x > 0 then
    local bar_length = width * (width / (self.max_x + width))
    local bar_offset = (self.x / self.max_x) * (width - bar_length)

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill",
      x + bar_offset, y + height - bar_width,
      bar_length, bar_width, bar_radius)
  end
end

return scroll
