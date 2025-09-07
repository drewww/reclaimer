prism.registerActor("Rocket", function(active)
   return prism.Actor.fromComponents {
      prism.components.Name("Rocket"),
      prism.components.Position(),
      prism.components.Drawable { index = "R", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 3,
         push = 2,
         range = 15,
         ammo = 1,
         maxAmmo = 1,
         ammopershot = 1,
         aoe = 4,
         template = "aoe",
         hotkey = 5,
         active = active
      })
   }
end)
