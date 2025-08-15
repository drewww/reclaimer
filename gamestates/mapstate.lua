local keybindings = require "keybindingschema"

--- @class MapState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local MapState = spectrum.GameState:extend("MapState")

local Game = require "game"

function MapState:__new(display)
   self.display = display
end

function MapState:draw()
   self.display:clear()
   self.display:putString(5, 5, "MAP GENERATE STATE")

   self.display:draw()
end

function MapState:keypressed(key, scancode, isrepeat)
   local action = keybindings:keypressed(key, "title")

   if action == "start" or action == "restart" then
      local builder = Game:generateNextFloor(prism.actors.Player())
      prism.logger:info("entering game state")

      self.manager:enter(TitleState(self.display, builder, Game:getLevelSeed()))
   elseif action == "quit" then
      love.event.quit()
   end
end

return MapState
