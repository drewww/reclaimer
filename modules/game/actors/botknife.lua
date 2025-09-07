prism.registerActor("BotKnife", function()
   return prism.Actor.fromComponents {
      prism.components.Name("BotKnife"),
      prism.components.Position(),
      prism.components.Drawable { index = "w", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(0, 3, 1.8, 1, 1, 1, 0, "melee", 1)
   }
end)
