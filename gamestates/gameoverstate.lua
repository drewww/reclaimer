local keybindings = require "keybindingschema"
local Game = require "game"
--- @class GameOverState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(display)
   self.display = display

   Game.stats:finalize()
   Game.stats:print()
   Game.stats:save()
end

function GameOverState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()
   self.display:putString(3, 3, "EXPEDITION OVER", nil, nil, nil, "left", self.display.width)

   self.display:putString(midpointX + 2, midpointY + 5, "R TO RESTART", nil, nil, nil, "left", self.display.width)
   self.display:putString(midpointX + 2, midpointY + 6, "Q TO QUIT", nil, nil, nil, "left", self.display.width)

   -- TODO draw the stats in here
   self.display:putString(3, 7, "STATS", nil, nil, nil, "left")

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
         self.display:put(4, 9 + i, (15 * 32) + 6)
      end
      self.display:putString(6, 9 + i, string.upper(value.name))
      self.display:putString(14, 9 + i, tostring(value.cur))
      self.display:putString(20, 9 + i, "(" .. tostring(value.best) .. ")")

      i = i + 1
   end

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
