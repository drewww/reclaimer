--- @class Stats : Object
local Stats = prism.Object:extend("Stats")
local json = require "prism.engine.lib.json"

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

   -- attempt to load
   self:load()
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
   local file_info = love.filesystem.getInfo("stats.json")
   if not file_info then
      prism.logger.info("No stats file found, using defaults.")
      return false
   end

   local contents, error = love.filesystem.read("stats.json")
   if not contents then
      prism.logger.error("Failed to read stats.json: " .. error)
   end

   local success, serialized_data = pcall(json.decode, contents)
   if not success then
      prism.logger.error("Failed to parse stats file.")
      return false
   end

   if not serialized_data or type(serialized_data) ~= "table" then
      prism.logger.error("Stats file contains invalid data.")
      return false
   end

   local loadedStats = prism.Object.deserialize(serialized_data)
   if not loadedStats then
      prism.logger.error("Failed to deserialize stats object.")
      return false
   end

   self.stats = loadedStats.stats
   self:resetRecords()

   prism.logger.info("Stats loaded successfully.")
   prism.logger.info(self:prettyprint())

   return true
end

function Stats:save()
   local jsonStats = json.encode(self:serialize())
   local success = love.filesystem.write("stats.json", jsonStats)

   if success then
      prism.logger.info("Stats saved.")
   else
      prism.logger.error("Failed to save stats.")
   end
end

function Stats:resetRecords()
   for key, value in pairs(self.stats) do
      value.record = false
   end
end

return Stats
