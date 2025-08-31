local MapState       = require "gamestates.mapstate"
local GameLevelState = require "gamestates.gamelevelstate"
local Game           = require "game"

--- @class TitleState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local TitleState     = spectrum.GameState:extend("TitleState")

function TitleState:__new(display)
   self.display = display

   self.controls = spectrum.Input.Controls {
      controls = {
         start = { "p" },
         quit = { "q" },
         generate = { "g" }
      }
   }
end

function TitleState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()
   self.display:putString(5, 5, "RECLAIMER", nil, nil, nil, "left", self.display.width)

   self.display:putString(5, 6, "A GAME BY DREW HARRY", nil, nil, nil, "left", self.display.width)

   self.display:putString(midpointX + 2, 20, "[P]LAY", nil, nil, nil, "left", midpointX - 2)

   self.display:putString(midpointX + 2, 22, "[Q]UIT", nil, nil, nil, "left", midpointX - 2)

   self.display:draw()
end

function TitleState:update(dt)
   self.controls:update()

   prism.logger.info("UPDATE DECISON: " ..
      tostring(self.controls.start.pressed) ..
      " - " .. tostring(self.controls.start.down) .. " - " .. tostring(self.controls.start.released))

   if self.controls.start.pressed then
      local builder = Game:generateNextFloor(prism.actors.Player())
      prism.logger:info("entering game state")

      self.manager:enter(GameLevelState(self.display, builder, Game:getLevelSeed()))
   elseif self.controls.quit.pressed then
      love.event.quit()
   elseif self.controls.generate.pressed then
      self.manager:enter(MapState(self.display))
   end
end

return TitleState
