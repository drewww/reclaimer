prism.registerCell("Fire", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Fire"),
      prism.components.Drawable { index = FIRE_BASE, color = prism.Color4.ORANGE, layer = 1 },
      prism.components.OnFire(),
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
