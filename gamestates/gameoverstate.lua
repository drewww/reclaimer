local Game = require "game"
--- @class GameOverState : GameState
--- @field display Display
--- @overload fun(): GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(died)
   self.died        = died

   local cp437Atlas = require "display.cp437_atlas"

   self.display     = spectrum.Display(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, cp437Atlas, prism.Vector2(16, 16))
   self.display:fitWindowToTerminal()

   -- Load contract failed image
   self.contractFailedImage = love.graphics.newImage("display/images/contract_failed_title.png")

   Game.stats:finalize()
   Game.stats:print()
   Game.stats:save()

   self.controls = spectrum.Input.Controls {
      controls = {
         restart = { "r" },
         quit = { "q" },
         credits = { "c" }
      }
   }
end

function GameOverState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()
   -- Draw contract failed image as background
   love.graphics.draw(self.contractFailedImage, 0, 0)

   self.display:putString(3, 10, "STATS", nil, nil, nil, "left")

   -- now iterate through stats and display them
   -- first, convert to an array and then sort the array
   local statsArray = {}
   for key, value in pairs(Game.stats.stats) do
      value.name = key
      table.insert(statsArray, value)
   end

   table.sort(statsArray, function(a, b)
      return a.index < b.index
   end)

   local i = 0
   for key, value in ipairs(statsArray) do
      if value.record then
         -- star
         self.display:put(6, 12 + i, EXCLAMATION)
      end
      self.display:putString(8, 12 + i, value.name)
      self.display:putString(16, 12 + i, tostring(value.cur))
      self.display:putString(22, 12 + i, "(" .. tostring(value.best) .. ")")

      i = i + 1
   end

   self.display:draw()
end

function GameOverState:update(dt)
   self.controls:update()

   if self.controls.restart.pressed then
      love.event.restart()
   end

   if self.controls.quit.pressed then
      love.event.quit()
   end

   if self.controls.credits.pressed then
      -- TODO switch to credits
   end
end

return GameOverState
