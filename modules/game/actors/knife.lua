prism.registerActor("Knife", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Knife"),
      prism.components.Position(),
      prism.components.Drawable { index = "w", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(0, 3, 1, 1, 1, 1, 0, "melee", 1)
   }
end)
