prism.registerActor("Scrap", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Scrap"),
      prism.components.Position(),
      prism.components.Drawable { index = 81, color = prism.Color4.GREY, layer = 1 },
      prism.components.Item {
         stackable = prism.actors.Scrap,
         stackLimit = 99,
      },
      prism.components.Edible(1),
   }
end)
