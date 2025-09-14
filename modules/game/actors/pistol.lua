prism.registerActor("Pistol", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Pistol"),
      prism.components.Position(),
      prism.components.Drawable { index = GUN, color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 1,
         push = 1,
         range = 6,
         ammo = 5,
         maxAmmo = 5,
         ammopershot = 1,
         aoe = 0,
         template = "point",
         hotkey = 2,
         ammoType = "Pistol"
      })
   }
end)
