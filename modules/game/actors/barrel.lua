prism.registerActor("Barrel", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { index = 10 * 16 + 3, color = prism.Color4.BLUE },
      prism.components.Collider(),
      prism.components.Health(1),
      prism.components.Unstable(),
   }
end)
