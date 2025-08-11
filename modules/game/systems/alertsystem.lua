--- @class AlertSystem : System
local AlertSystem = prism.System:extend("AlertSystem")

function AlertSystem:onMove(level, actor, from, to)
   if not actor:has(prism.components.PlayerController) then return end
   prism.logger.info("player moved from " .. tostring(from) .. " -> " .. tostring(to))

   -- get the list of actors that are alert and remove it if they do not see the player
   for alertActor, alertComponent in level:query(prism.components.Alert):iter() do
      if not alertActor:hasRelationship(prism.relationships.Sees, actor) then
         alertActor:remove(prism.components.Alert)
         prism.logger.info("Removing alert from actor " .. tostring(alertActor))
      end
   end

   -- then add in any actors that do now see the player
   for observer, relationship in pairs(actor:getRelationships(prism.relationships.SeenBy)) do
      -- prism.logger.info("seen by " .. tostring(observer))
      if not observer:has(prism.components.Alert) then
         observer:give(prism.components.Alert())

         -- todo trigger animation here
         prism.logger.info("Adding alert to actor " .. tostring(observer))
      end
   end
end

return AlertSystem
