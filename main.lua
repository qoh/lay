local lay = require "lay"
local root, inspector

local function demo_game_menu()
  local white = {255, 255, 255}

  root = lay.view {
    style = {
      width = 500, height = 500,
      padding = 50, justifyContent = "center", flexWrap = "wrap",
      background = {40, 40, 40}
    },
    lay.text {id = "title", text = "Game name", font = love.graphics.newFont(32), style = {color = white, marginBottom = 20}},
    lay.text {text = "New game", style = {color = white}},
    lay.text {text = "Load saved game", style = {color = white}},
    lay.text {text = "Start server", style = {color = white}},
    lay.text {text = "Join server", style = {color = white}},
    lay.text {text = "Options", style = {color = white}},
    lay.text {text = "Credits", style = {color = white}},
    lay.text {text = "Exit", style = {color = white}, onclick = love.event.quit},
    lay.text {
      align = "right", style = {color = white, marginTop = 20},
      text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    },
  }
end

-- local function demo_image_gallery()
--   root = lay.view {
--     lay.scroll {
--       id = "scroll",
--       style = {
--         margin = 24,
--         flex = 1,
--         flexDirection = "row",
--         flexWrap = "wrap",
--         alignItems = "center",
--         justifyContent = "center"
--       }
--     },
--     lay.view {
--       id = "overlay",
--       style = {
--         position = "absolute",
--         top = 0,
--         left = 0,
--         justifyContent = "center",
--         alignItems = "center",
--         visible = false,
--         background = {0, 0, 0, 230}
--       },
--       onclick = function(self)
--         if self.children[1] then
--           self:remove(self.children[1])
--           self.style.visible = false
--           return true
--         end
--       end
--     }
--   }
--
--   local sc = root:by_id("scroll")
--   for _, name in ipairs(love.filesystem.getDirectoryItems("assets/images")) do
--     sc:add(lay.image {
--       image = "assets/images/" .. name,
--       style = {margin = 8, maxWidth = 130, maxHeight = 130},
--       onclick = function()
--         root:by_id("overlay"):add(lay.image {
--           image = "assets/images/" .. name
--         })
--         root:by_id("overlay").style.visible = true
--         return true
--       end
--     })
--   end
-- end

function love.load()
  demo_game_menu()

  inspector = require "lay.inspector" {
    root = root,
    font_file = "assets/fonts/DejaVuSans.ttf"
  }
end

function love.resize(w, h)
  root:set_style_width(w)
  root:set_style_height(h)
  root:by_id("overlay"):set_style_width(w)
  root:by_id("overlay"):set_style_height(h)
end

function love.keypressed(key)
  if inspector:keypressed(key) then
    return true
  end

  if key == "escape" then
    love.event.quit()
    return true
  end
end

function love.wheelmoved(x, y)
  return root:wheelmoved(x, y)
end

function love.mousepressed(x, y, button)
  local result = inspector:mousepressed(x, y, button)
  if result ~= nil then return result end
  return root:mousepressed(x, y, button)
end

function love.draw()
  root:reflow()
  root:draw()

  inspector:draw()
end
