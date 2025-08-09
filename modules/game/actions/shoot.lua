local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format

local ShootTarget = prism.Target()
    :with(prism.components.Collider)
    :range(10)
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
    local initialPosition = shot:getPosition()
    local direction = (shot:getPosition() - self.owner:getPosition())
    local distance = direction:length()
    direction = distance == 0 and 0 or direction / direction:length()

    print("direction: " .. tostring(direction))

    local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }

    -- pushes back 3 steps
    -- our actual shot will not do this (or we will parameterize it?)
    -- but it's fine for now
    local damageValue = 1

    -- because the enemy moves immediately after this, if you just move one space
    -- it appears like they're not moving.
    for _ = 1, 2 do
        local nextpos = shot:getPosition() + (direction)
        nextpos.x = nextpos.x >= 0 and math.floor(nextpos.x + 0.5) or math.ceil(nextpos.x - 0.5)
        nextpos.y = nextpos.y >= 0 and math.floor(nextpos.y + 0.5) or math.ceil(nextpos.y - 0.5)

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

        print("moving target from " .. tostring(shot:getPosition()) .. " to " .. tostring(nextpos))
        level:moveActor(shot, nextpos)
    end

    local damage = prism.actions.Damage(shot, damageValue)

    -- Why do I need to ask first? I guess this is type protection more or less.
    if level:canPerform(damage) then
        level:perform(damage)

        local shotName = Name.lower(shot)
        local ownerName = Name.lower(self.owner)
        local dmgstr = ""

        if damage.dealt then
            dmgstr = sf("%i damage.", damage.dealt)
        end
        Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
        Log.addMessage(shot, sf("The %s shot you! %s", ownerName, dmgstr))
        Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))

        level:yield(prism.messages.Animation {
            animation = spectrum.animations.Projectile(self.owner, initialPosition),
            actor = self.owner
        })
    end
end

return Shoot
