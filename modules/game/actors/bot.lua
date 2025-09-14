prism.registerActor("Bot", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Name("Bot"),
      prism.components.Drawable { index = 2, color = COLOR_ENEMY, layer = 10 },
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { range = 10, fov = true },
      prism.components.Mover { "walk" },
      prism.components.BotController(),
      prism.components.Health(3),
      -- prism.components.Attacker(1),
      prism.components.Alert(),
      -- put a scrap item in the inventory of the bot
      prism.components.Inventory {
         totalCount = 1,
         items = {
            AMMO_TYPES["Laser"](2),
            prism.actors.BotLaser(),
            prism.actors.BotKnife()
         },
      },
   }
end)
