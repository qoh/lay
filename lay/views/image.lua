local class = require("lay.class")
local view = require("lay.views.view")

local image = class(view)
image.name = "image"

function image:new(t)
  t = view.new(self, t)

  if type(t.image) == "string" then
    t.image = love.graphics.newImage(t.image)
  end

  function t.style.measure(maxWidth)
    local w, h = t.image:getDimensions()

    if maxWidth == nil or maxWidth ~= maxWidth then
      maxWidth = t.style.maxWidth
    end

    local maxHeight = t.style.maxHeight

    if maxHeight ~= nil and w > maxHeight then
      w = w * (maxHeight / h)
      h = maxHeight
    end

    if maxWidth ~= nil and w > maxWidth then
      h = h * (maxWidth / w)
      w = maxWidth
    end

    return {width = w, height = h}
  end

  return t
end

-- function image.__instance:set_image(image)
--   if image ~= self.image then
--     self.image = image
--     self:dirty()
--   end
-- end

function image.__instance:draw_content(x, y, w, h)
  local iw, ih = self.image:getDimensions()
  local sx = w / iw
  local sy = h / ih

  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.image, x, y, 0, sx, sy)
end

return image
