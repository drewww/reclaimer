prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = 1, color = COLOR_PLAYER, layer = math.huge - 100 },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Sight { range = 10, fov = true },
      prism.components.Mover { "walk" },
      prism.components.Health(10),
      -- prism.components.Log(),
      prism.components.Energy(3, 0.1),
      prism.components.Inventory {
         limitCount = 26,
      },
   }
end)
