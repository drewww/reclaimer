prism.registerActor("Rocket", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Rocket"),
      prism.components.Position(),
      prism.components.Drawable { index = "R", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(3, 2, 15, 1, 1, 1, 4, "aoe", 5)
   }
end)
