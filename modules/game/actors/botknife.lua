prism.registerActor("BotKnife", function()
   return prism.Actor.fromComponents {
      prism.components.Name("BotKnife"),
      prism.components.Position(),
      prism.components.Drawable { index = "w", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(1, 2, 1, 1, 1, 0, 0, "melee", 1)
   }
end)
