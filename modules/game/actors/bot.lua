prism.registerActor("bot", function()
    return prism.Actor.fromComponents {
        prism.components.Position(),
        prism.components.Drawable("b", prism.Color4.RED),
        prism.components.Collider(),
        prism.components.Senses(),
        prism.components.Sight { range = 12, fov = true },
        prism.components.Mover { "walk" },
        prism.components.BotController()
    }
end)
