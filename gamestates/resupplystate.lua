local Game = require "game"

--- @class ResupplyState : GameState
--- @field display Display
--- @overload fun(): ResupplyState
local ResupplyState = spectrum.GameState:extend("ResupplyState")

function ResupplyState:__new()
   local cp437Atlas = require "display.cp437_atlas"

   self.display     = spectrum.Display(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, cp437Atlas, prism.Vector2(16, 16))
   self.display:fitWindowToTerminal()

   self.controls = spectrum.Input.Controls {
      controls = {
         move_up    = { "w", "k" },
         move_left  = { "a", "h" },
         move_right = { "d", "l" },
         move_down  = { "s", "j" },
         select     = { "enter", "space" },
      },

      pairs = {
         move = { "move_up", "move_left", "move_right", "move_down" }
      }
   }
end

function ResupplyState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   self.display:putString(3, 3, "RESUPPLY", nil, nil, nil, "left")

   self.display:draw()
end

function ResupplyState:update(dt)
   self.controls:update()

   if self.controls.move.pressed then
      local vector = self.controls.move.vector
      prism.logger.info("Moving in direction: %s", vector)
   end

   if self.controls.select.pressed then
      prism.logger.info("Select pressed")
      -- for now, transition to next level.
      local GameLevelState = require "gamestates.gamelevelstate"

      self.manager:enter(GameLevelState(Game:generateNextFloor(), Game:getLevelSeed()))
   end
end

return ResupplyState
