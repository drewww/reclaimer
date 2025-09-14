prism.registerActor("BotRocket", function(active)
   return prism.Actor.fromComponents {
      prism.components.Name("BotRocket"),
      prism.components.Position(),
      prism.components.Drawable { index = GUN, color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 1,
         push = 2,
         range = 15,
         ammo = 1,
         maxAmmo = 1,
         ammopershot = 1,
         aoe = 2,
         template = "aoe",
         hotkey = 5,
         active = active,
         ammoType = "Rocket",
         reloadTurns = 3
      })
   }
end)
