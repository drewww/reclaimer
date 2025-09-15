prism.registerActor("Laser", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Laser"),
      prism.components.Position(),
      prism.components.Drawable { index = GUN, color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 5,
         push = 0,
         range = 12,
         ammo = 4,
         maxAmmo = 4,
         ammopershot = 1,
         aoe = 0,
         template = "line",
         hotkey = 4,
         ammoType = "Laser"
      })
   }
end)
