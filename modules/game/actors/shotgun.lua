prism.registerActor("Shotgun", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Shotgun"),
      prism.components.Position(),
      prism.components.Drawable { index = "s", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(1, 3, 4, 4, 4, 2, "cone", 3)
   }
end)
