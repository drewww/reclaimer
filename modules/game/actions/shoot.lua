local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format

local ShootTarget = prism.Target()
    :with(prism.components.Collider)
    :range(1)
    :sensed()

local Shoot = prism.Action:extend("ShootAction")
Shoot.name = "Shoot"
Shoot.targets = { ShootTarget }
Shoot.requireComponents = {
    prism.components.Controller
}

function Shoot:canPerform(level)
    return true
end

function Shoot:perform(level, shot)
    local direction = (shot:getPosition() - self.owner:getPosition())

    local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }

    -- pushes back 3 steps
    -- our actual shot will not do this (or we will parameterize it?)
    -- but it's fine for now
    local damageValue = 1


    for _ = 1, 3 do
        local nextpos = shot:getPosition() + direction

        if not level:getCellPassable(nextpos.x, nextpos.y, mask) then
            -- if the next position is not passable, do more damage.
            -- this is a little broken re: movement masks. but i don't think I'm
            -- using them at all here. i.e. i think this kills an entity if they
            -- are pushed into a void, but not based on the movement dynamcs or
            -- a system.
            damageValue = 5
            break
        end
        if not level:hasActor(shot) then break end

        level:moveActor(shot, nextpos)
    end

    local damage = prism.actions.Damage(shot, damageValue)

    -- Why do I need to ask first? I guess this is type protection more or less.
    if level:canPerform(damage) then
        level:perform(damage)
    end

    local shotName = Name.lower(shot)
    local ownerName = Name.lower(self.owner)
    local dmgstr = ""

    if damage.dealt then
        dmgstr = sf("%i damage.", damage.dealt)
    end
    Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
    Log.addMessage(shot, sf("The %s shot you! %s", ownerName, dmgstr))
    Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))
end

return Shoot
