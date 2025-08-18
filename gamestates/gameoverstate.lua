local keybindings = require "keybindingschema"
local Game = require "game"
--- @class GameOverState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(display)
   self.display = display

   Game:finalizeStats()
   Game:printStats()
end

function GameOverState:draw()
   local midpoint = math.floor(self.display.height / 2)

   self.display:clear()
   self.display:putString(1, midpoint, "Game over!", nil, nil, nil, "center", self.display.width)

   self.display:putString(1, midpoint + 3, "[r] to restart", nil, nil, nil, "center", self.display.width)
   self.display:putString(1, midpoint + 4, "[q] to quit", nil, nil, nil, "center", self.display.width)

   -- TODO draw the stats in here

   self.display:draw()
end

function GameOverState:keypressed(key, scancode, isrepeat)
   local action = keybindings:keypressed(key, "title")

   if action == "restart" then
      love.event.restart()
   elseif action == "quit" then
      love.event.quit()
   end
end

return GameOverState
