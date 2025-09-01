prism.registerActor("Chest", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { index = CHEST_BASE, color = prism.Color4.YELLOW },
      prism.components.Collider(),
      prism.components.Openable(CHEST_DURATION)
   }
end)
