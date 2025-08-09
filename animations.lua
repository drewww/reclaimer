local alertOn = { index = "!", color = prism.Color4.WHITE }
local alertOff = { index = " ", color = prism.Color4.BLACK }

spectrum.registerAnimation("Alert", function()
    return spectrum.Animation({ alertOn, alertOff, alertOn, alertOff }, 0.2, "pauseAtEnd")
end)


local deathBig = { index = 8, color = prism.Color4.WHITE }
local deathMid = { index = 9, color = prism.Color4(1.0, 1.0, 1.0, 0.8) }
local deathSmall = { index = 7, color = prism.Color4(1.0, 1.0, 1.0, 0.5) }

spectrum.registerAnimation("BotDie", function()
    return spectrum.Animation({ deathBig, deathMid, deathSmall }, 0.2, "pauseAtEnd")
end)


spectrum.registerAnimation("DebugCustom", function(owner)
    local x, y = owner:getPosition():decompose()

    return spectrum.Animation(function(t, display)
        if t >= 1 then return true end

        display:putBG(x, y, prism.Color4(1.0, 1.0, 1.0, 1 - t))

        return false
    end)
end)

spectrum.registerAnimation("Projectile", function(owner, targetPosition)
    local x, y = owner:expectPosition():decompose()
    local line = prism.Bresenham(x, y, targetPosition.x, targetPosition.y)

    prism.logger.info("creating custom animation function for line " .. tostring(line))
    return spectrum.Animation(function(t, display)
        local index = math.floor(t / 0.02) + 1
        display:put(line[index][1], line[index][2], "*", prism.Color4.WHITE, prism.Color4.BLACK, 2)

        prism.logger.info("animating frame " .. t .. " index: " .. index .. " line: " .. tostring(line[index]))
        if index == #line then return true end

        return false
    end)
end)
