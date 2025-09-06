prism.registerActor("Pistol", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Pistol"),
      prism.components.Position(),
      prism.components.Drawable { index = "w", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(1, 2, 5, 5, 5, 1, 0, "point", 2)
   }
end)
