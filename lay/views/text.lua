local class = require("lay.class")
local view = require("lay.views.view")

local text = class(view)
text.name = "text"

text.__instance.text = ""
text.__instance.align = "left"

function text:new(t)
  if text.__instance.font == nil then
    text.__instance.font = love.graphics.newFont(16)
  end

  t = view.new(self, t)

  function t.style.measure(maxWidth)
    local wrapWidth, wrapLines = t.font:getWrap(t.text, maxWidth)
    return {width = wrapWidth, height = t.font:getHeight() * #wrapLines}
  end

  return t
end

function text.__instance:set_text(text)
  if text ~= self.text then
    self.text = text
    self:dirty()
  end
end

function text.__instance:draw_content(x, y, w)
  x = math.floor(x + 0.5)
  y = math.floor(y + 0.5)
  w = math.floor(w + 0.5)

  if self.style.color then
    love.graphics.setColor(self.style.color)
  else
    love.graphics.setColor(40, 40, 40)
  end

  love.graphics.setFont(self.font)
  love.graphics.printf(self.text, x, y, w, self.align)
end

return text
