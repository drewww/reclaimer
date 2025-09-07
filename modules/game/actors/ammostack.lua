-- TODO add an ammo type parameter to this, pass it into the ammo component.
prism.registerActor("AmmoPistol", function(count)
   return prism.Actor.fromComponents {
      prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
      prism.components.Health(1),
      prism.components.Item({
         stackable = prism.actors.AmmoPistol, -- TODO work out how to make these stack separately by type.
         stackCount = count or 1,
         stackLimit = 99
      })
   }
end)

prism.registerActor("AmmoShotgun", function(count)
   return prism.Actor.fromComponents {
      prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
      prism.components.Health(1),
      prism.components.Item({
         stackable = prism.actors.AmmoShotgun, -- TODO work out how to make these stack separately by type.
         stackCount = count or 1,
         stackLimit = 99
      })
   }
end)

prism.registerActor("AmmoLaser", function(count)
   return prism.Actor.fromComponents {
      prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
      prism.components.Health(1),
      prism.components.Item({
         stackable = prism.actors.AmmoLaser, -- TODO work out how to make these stack separately by type.
         stackCount = count or 1,
         stackLimit = 99
      })
   }
end)
