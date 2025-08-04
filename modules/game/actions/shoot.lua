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
    for _ = 1, 3 do
        local nextpos = shot:getPosition() + direction

        if not level:getCellPassable(nextpos.x, nextpos.y, mask) then break end
        if not level:hasActor(shot) then break end

        level:moveActor(shot, nextpos)
    end
end

return Shoot
