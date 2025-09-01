local OpenTarget = prism.Target():isPrototype(prism.Actor):with(prism.components.Openable)

---@class Open : Action
local Open = prism.Action:extend("Open")

Open.targets = { OpenTarget }
Open.name = "open"

Open.requiredComponents = {
   prism.components.PlayerController
}


function Open:canPerform(level, target)
   -- for now, consider things only openable if they are closed

   local openable = target:get(prism.components.Openable)
   if openable then
      return not openable.open
   end
end

function Open:perform(level, target)
   local openable = target:get(prism.components.Openable)

   if openable then
      if openable.delay > 0 and not openable.open then
         -- set a tick component and get it started
         prism.logger.info("Started delayed open countdown: " .. tostring(openable.delay))
         target:give(prism.components.Tickable("openchest", openable.delay))

         -- need to do this otherwise it doesn't get a turn to tick on.
         target:give(prism.components.WaitController())
         openable.open = true
      else
         prism.logger.info("Immdiate open.")
         openable.open = true
      end
   end
end

return Open
