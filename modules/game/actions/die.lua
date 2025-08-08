--- @class Die : Action
--- @overload fun(owner: Actor): Die
local Die = prism.Action:extend("Die")

function Die:perform(level)
    -- check if the dying actor has an inventory. if it does, drop the first item
    -- from its inventory at this position.
    local inventory = self.owner:get(prism.components.Inventory)
    if inventory and inventory.totalCount > 0 then
        -- TODO how to make this random? might be a nice bit of query suger
        local item = inventory:query(prism.components.Item):first()
        level:addActor(item, self.owner:getPosition():decompose())
    end

    prism.logger.info("making death animation at " .. tostring(self.owner:getPosition()))

    level:yield(prism.messages.Animation {
        animation = spectrum.animations.Alert(),
        actor = self.owner
        -- x = self.owner:getPosition().x,
        -- y = self.owner:getPosition().y
        -- x = 20,
        -- y = 20
    })

    level:removeActor(self.owner)



    -- if there are no players left, game is over.
    if not level:query(prism.components.PlayerController):first() then
        level:yield(prism.messages.Lose())
    end
end

return Die
