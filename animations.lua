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
