prism.registerActor("Loot", function(value)
   if not value then
      value = 4
   end
   return prism.Actor.fromComponents {
      prism.components.Name("nanos"),
      prism.components.Position(),
      prism.components.Drawable { index = LOOT_BASE + (4 - value), color = prism.Color4.YELLOW },
      prism.components.Item {
         stackable = prism.actors.Loot,
         stackCount = value,
      }
   }
end)
