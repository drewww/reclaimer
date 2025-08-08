prism.registerActor("Bot", function()
    return prism.Actor.fromComponents {
        prism.components.Position(),
        prism.components.Drawable { index = "b", color = prism.Color4.RED },
        prism.components.Collider(),
        prism.components.Senses(),
        prism.components.Sight { range = 12, fov = true },
        prism.components.Mover { "walk" },
        prism.components.BotController(),
        prism.components.Health(3),
        prism.components.Attacker(1),
        -- put a scrap item in the inventory of the bot
        prism.components.Inventory {
            totalCount = 1,
            items = {
                prism.actors.Scrap()
            }
        }
    }
end)
