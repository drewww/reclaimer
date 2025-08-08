local on = { index = "!", color = prism.Color4.WHITE }
local off = { index = " ", color = prism.Color4.BLACK }

spectrum.registerAnimation("alert", function()
    return spectrum.Animation({ on, off, on, off }, 0.2, "pauseAtEnd")
end)
