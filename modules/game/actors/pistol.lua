prism.registerActor("Pistol", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Pistol"),
      prism.components.Position(),
      prism.components.Drawable { index = "p", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(2, 0, 5, "point", 2)
   }
end)
