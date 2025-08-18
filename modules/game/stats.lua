--- @class Stats : Object
local Stats = prism.Object:extend("Stats")

function Stats:__new()
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

function Stats:set(key, value)
   if key == nil then
      return
   end

   if self.stats[key] then
      local stat = self.stats[key]
      stat.cur = value
      prism.logger.info("set stat: " .. key .. " -> " .. value)
   end
end

function Stats:get(key)
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

function Stats:increment(key, value)
   if key == nil then
      return false
   end

   value = value or 1

   local new = self:get(key) + value
   self:set(key, new)

   return new
end

function Stats:print()
   prism.logger.info("STATS")
   for index, value in pairs(self.stats) do
      prism.logger.info(index .. ": " .. value.cur .. " (" .. value.best .. ") " .. tostring(value.record))
   end
end

function Stats:finalize()
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

function Stats:load()
   -- TODO
end

function Stats:save()
   -- TODO
end

return Stats
