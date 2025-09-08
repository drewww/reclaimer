prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = 1, color = prism.Color4.GREEN, layer = math.huge - 100 },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Sight { range = 20, fov = true },
      prism.components.Mover { "walk" },
      prism.components.Health(10),
      -- prism.components.Log(),
      prism.components.Energy(4, 0.2),
      prism.components.Inventory {
         limitCount = 26,
      },
   }
end)
