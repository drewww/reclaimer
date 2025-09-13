prism.registerCell("Ashes", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Ashes"),
      prism.components.Drawable { index = FIRE_BASE + 1, color = prism.Color4.GREY, layer = 1 },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
