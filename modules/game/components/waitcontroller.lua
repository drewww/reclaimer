local WaitController = prism.components.Controller:extend("WaitController")

function WaitController:act(level, actor)
    return prism.actions.Wait(actor)
end

return WaitController
