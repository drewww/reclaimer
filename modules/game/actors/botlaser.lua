prism.registerActor("BotLaser", function()
   return prism.Actor.fromComponents {
      prism.components.Name("BotLaser"),
      prism.components.Position(),
      prism.components.Drawable { index = "l", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 1,
         push = 0,
         range = 10,
         ammo = 1,
         maxAmmo = 1,
         ammopershot = 1,
         aoe = 0,
         template = "line",
         hotkey = 4,
         active = true,
         ammoType = "Laser"
      })
   }
end)
