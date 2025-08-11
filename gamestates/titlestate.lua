local keybindings = require "keybindingschema"

--- @class TitleState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local TitleState = spectrum.GameState:extend("TitleState")
local GameLevelState = require "gamestates.gamelevelstate"

local Game = require "game"

function TitleState:__new(display)
   self.display = display
end

function TitleState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()
   self.display:putString(5, 5, "RECLAIMER", nil, nil, nil, "left", self.display.width)

   self.display:putString(5, 6, "a game by Drew Harry", nil, nil, nil, "left", self.display.width)

   self.display:putString(midpointX + 2, 20, "[p]lay", nil, nil, nil, "left", midpointX - 2)

   self.display:putString(midpointX + 2, 22, "[q]uit", nil, nil, nil, "left", midpointX - 2)

   self.display:draw()
end

function TitleState:keypressed(key, scancode, isrepeat)
   local action = keybindings:keypressed(key, "title")

   if action == "start" or action == "restart" then
      local builder = Game:generateNextFloor(prism.actors.Player())
      prism.logger:info("entering game state")

      self.manager:enter(GameLevelState(self.display, builder, Game:getLevelSeed()))
   elseif action == "quit" then
      love.event.quit()
   end
end

return TitleState
