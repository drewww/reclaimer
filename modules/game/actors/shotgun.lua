prism.registerActor("Shotgun", function(active)
   return prism.Actor.fromComponents {
      prism.components.Name("Shotgun"),
      prism.components.Position(),
      prism.components.Drawable { index = GUN, color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 2,
         push = 3,
         range = 4,
         ammo = 4,
         maxAmmo = 4,
         ammopershot = 2,
         aoe = 0,
         template = "cone",
         hotkey = 3,
         ammoType = "Shotgun",
         active = active or false
      })
   }
end)
