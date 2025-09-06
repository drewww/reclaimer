-- TODO add an ammo type parameter to this, pass it into the ammo component.
prism.registerActor("AmmoStack", function(count)
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { index = 10 * 16 + 3, color = prism.Color4.BLUE },
      prism.components.Health(1),
      prism.components.Item({
         stackable = prism.actors.AmmoStack, -- TODO work out how to make these stack separately by type.
         stackCount = count or 1,
         stackLimit = 99
      }),
      -- prism.components.Ammo(
      -- "pistol"
      -- )
   }
end)
