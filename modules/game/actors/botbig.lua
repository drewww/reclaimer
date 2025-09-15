prism.registerActor("BotBig", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Name("BotBig"),
      prism.components.Drawable { index = 3, color = COLOR_ENEMY, layer = 10 },
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { range = 8, fov = true },
      prism.components.Mover { "walk" },
      prism.components.BotController(),
      prism.components.Health(12),
      -- prism.components.Attacker(1),
      prism.components.Alert(),
      -- put a scrap item in the inventory of the bot
      prism.components.Inventory {
         totalCount = 1,
         items = {
            AMMO_TYPES["Shotgun"](20),
            prism.actors.Shotgun(true),
            prism.actors.BotKnife()
         },
      },
   }
end)
