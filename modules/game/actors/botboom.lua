prism.registerActor("BotBoom", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Name("BotBoom"),
      prism.components.Drawable { index = 4, color = COLOR_ENEMY, layer = 10 },
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { range = 12, fov = true },
      prism.components.Mover { "walk" },
      prism.components.BotController(),
      prism.components.Health(5),
      -- prism.components.Attacker(1),
      prism.components.Alert(),
      -- put a scrap item in the inventory of the bot
      prism.components.Inventory {
         totalCount = 1,
         items = {
            AMMO_TYPES["Rocket"](20),
            prism.actors.BotRocket(true),
            prism.actors.BotKnife()
         },
      },
   }
end)
