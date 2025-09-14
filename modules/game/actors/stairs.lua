prism.registerActor("Stairs", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Stairs"),
      prism.components.Position(),
      prism.components.Drawable { index = STAIRS, color = COLOR_PLAYER },
      prism.components.Stair(),
      prism.components.Remembered(),
   }
end)
