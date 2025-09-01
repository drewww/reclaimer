prism.registerActor("Loot", function(value)
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { index = 8 * 16 + 6, color = prism.Color4.YELLOW },
      prism.components.Item {
         stackable = prism.actors.Loot,
         stackCount = value
      }
   }
end)
