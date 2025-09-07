prism.registerCell("Wall", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Wall"),
      prism.components.Drawable { index = WALL_BASE },
      prism.components.Collider(),
      prism.components.Opaque(),
   }
end)
