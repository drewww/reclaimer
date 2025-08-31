prism.registerActor("BarrelExploding", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.WaitController(),
      prism.components.Drawable { index = "O", color = prism.Color4.RED },
      prism.components.Collider(),
      prism.components.Tickable("explode", 3),
   }
end)
