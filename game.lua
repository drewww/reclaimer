local levelgen = require "levelgen.levelgen"

--- @class Game : Object
--- @field depth integer
--- @field rng RNG
--- @overload fun(seed: string): Game
local Game = prism.Object:extend("Game")

--- @param seed string
function Game:__new(seed)
   self.depth = 0
   self.rng = prism.RNG(seed)

   -- define a list of stats to track.
   -- when certain events in the game happen, update game stats.
   -- so when you get a kill, go down a level, etc. that will
   -- update the 'cur' field.
   --
   -- later, we can write some code that updates best if it cur
   -- is better than best. and then save/load best from disk.
   self.stats = {
      depth = { sort = "asc", cur = 0, best = 0, record = false }
   }
end

function Game:setStat(key, value)
   if key == nil then
      return
   end

   if self.stats[key] then
      local stat = self.stats[key]
      stat.cur = value
      prism.logger.info("set stat: " .. key .. " -> " .. value)
   end
end

function Game:getStat(key)
   if key == nil then
      return false
   end

   if self.stats[key] then
      local stat = self.stats[key]
      return stat.cur
   else
      return false
   end
end

function Game:incrementStat(key, value)
   if key == nil then
      return false
   end

   value = value or 1

   local new = self:getStat(key) + value
   self:setStat(key, new)

   return new
end

function Game:printStats()
   for index, value in pairs(self.stats) do
      prism.logger.info(index .. ": " .. value.cur .. " (" .. value.best .. ") " .. tostring(value.record))
   end
end

function Game:finalizeStats()
   -- loop through each key, compare cur to best.
   -- if cur is "better" than best (split on ascending/descending) then replace it.
   -- if replaced, flag that stat as "NEW RECORD!"
   for key, value in pairs(self.stats) do
      if (value.cur >= value.best and value.sort == "asc") or
          (value.cur <= value.best and value.sort == "desc") then
         value.best = value.cur
         value.record = true
      else
         value.record = false
      end
   end
end

function Game:loadStats()
   -- TODO
end

function Game:saveStats()
   -- TODO
end

--- @return string
function Game:getLevelSeed()
   return tostring(self.rng:random())
end

--- @param player Actor
--- @return MapBuilder builder
function Game:generateNextFloor(player)
   self.depth = self.depth + 1

   local genRNG = prism.RNG(self:getLevelSeed())
   return levelgen(genRNG, player, 60, 30)
end

return Game(tostring(os.time()))
