--- @class AlertSystem : System
local AlertSystem = prism.System:extend("AlertSystem")

function AlertSystem:onMove(level, actor, from, to)
    if not actor:has(prism.components.PlayerController) then return end

    prism.logger.info("player moved from " .. tostring(from) .. " -> " .. tostring(to))
end

return AlertSystem
