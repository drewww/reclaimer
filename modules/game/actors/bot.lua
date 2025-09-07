prism.registerActor("Bot", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Name("Bot"),
      prism.components.Drawable { index = 2, color = prism.Color4.RED, layer = 10 },
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { range = 12, fov = true },
      prism.components.Mover { "walk" },
      prism.components.BotController(),
      prism.components.Health(5),
      prism.components.Attacker(1),
      prism.components.Alert(),
      -- put a scrap item in the inventory of the bot
      prism.components.Inventory {
         totalCount = 1,
         items = {
            prism.actors.AmmoStack(4),
            prism.actors.BotLaser(),
            prism.actors.BotKnife()
         },
      },
   }
end)
