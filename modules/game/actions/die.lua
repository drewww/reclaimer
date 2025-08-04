--- @class Die : Action
--- @overload fun(owner: Actor): Die
local Die = prism.Action:extend("Die")

function Die:perform(level)
    level:removeActor(self.owner)

    -- if there are no players left, game is over.
    if not level:query(prism.components.PlayerController):first() then
        level:yield(prism.messages.Lose())
    end
end

return Die
