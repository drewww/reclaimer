local function registerSprite(sprite)
   return function()
      return prism.Cell.fromComponents {
         prism.components.Name("WallSprite"),
         prism.components.Drawable { index = sprite },
         prism.components.Collider(),
         prism.components.Opaque(),
      }
   end
end

prism.registerCell("TerminalLeft", registerSprite(WALL_BASE + 2))
prism.registerCell("TerminalCenter", registerSprite(WALL_BASE + 3))
prism.registerCell("TerminalRight", registerSprite(WALL_BASE + 4))
