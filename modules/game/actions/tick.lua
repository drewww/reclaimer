--- @class Tick : Action
local Tick = prism.Action:extend "Tick"
Tick.requiredComponents = { prism.components.Tickable }

-- what's my design here? we want something to happen at the end of a countdown, not something to happen every tick of a countdown. what happens at the end is variable ...
-- does inheritance work? NO it does not work.
-- so we could apply tick to any actor that ...has tickable component?? but as written the Tick _action_
-- okay the most basic version of this is simply to put the logic inside the tick action, with a type field on tickable. so type explode on the 0, does a thing. on a continuous effect, it would do it every time, etc. ideally that would get encapsulated somewhere else. but let's try it for now.

--- @param level Level
function Tick:perform(level)
    -- Handle status effect durations
    local tickable = self.owner:expect(prism.components.Tickable)

    local expired = {}
    if tickable.duration then
        tickable.duration = tickable.duration - 1

        prism.logger.info("ticked." .. tickable.type .. "@" .. tickable.duration)
        -- put mid process actions here, i.e. effects every tick

        if tickable.duration <= 0 then
            -- put end of process action here
            prism.logger.info("TICK OVER")
            self.owner:remove(tickable)
        end
    end
end

return Tick
