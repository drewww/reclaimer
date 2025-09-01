prism.registerActor("Chest", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { index = 8 * 16 + 5, color = prism.Color4.YELLOW },
      prism.components.Collider(),
      prism.components.Openable(10)
   }
end)
