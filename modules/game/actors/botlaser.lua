prism.registerActor("BotLaser", function()
   return prism.Actor.fromComponents {
      prism.components.Name("BotLaser"),
      prism.components.Position(),
      prism.components.Drawable { index = "l", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon(5, 0, 10, 3, 3, 1, 0, "line", 4, true)
   }
end)
