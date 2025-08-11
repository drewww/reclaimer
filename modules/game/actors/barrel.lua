prism.registerActor("Barrel", function()
   return prism.Actor.fromComponents {
      prism.components.Position(),
      prism.components.Drawable { char = "o", color = prism.Color4.BLUE },
      prism.components.Collider(),
      prism.components.Health(1),
      prism.components.Unstable(),
   }
end)
