prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { char = "@", color = prism.Color4.GREEN, layer = math.huge },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Sight { range = 20, fov = true },
      prism.components.Mover { "walk" },
      prism.components.Health(10),
      prism.components.Log(),
      prism.components.Tickable("countdown", 10),
      prism.components.Inventory {
         limitCount = 26,
      },
   }
end)
