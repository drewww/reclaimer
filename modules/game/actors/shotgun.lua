prism.registerActor("Shotgun", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Shotgun"),
      prism.components.Position(),
      prism.components.Drawable { index = "s", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 1,
         push = 3,
         range = 4,
         ammo = 4,
         maxAmmo = 4,
         ammopershot = 2,
         aoe = 0,
         template = "cone",
         hotkey = 3
      })
   }
end)
