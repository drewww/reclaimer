prism.registerActor("BotKnife", function()
   return prism.Actor.fromComponents {
      prism.components.Name("BotKnife"),
      prism.components.Position(),
      prism.components.Drawable { index = "w", color = prism.Color4.YELLOW },
      prism.components.Item(),
      prism.components.Weapon({
         damage = 1,
         push = 2,
         range = 1,
         ammo = 1,
         maxAmmo = 1,
         ammopershot = 0,
         aoe = 0,
         template = "melee",
         hotkey = 1
      })
   }
end)
