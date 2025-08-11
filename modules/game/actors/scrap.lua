prism.registerActor("Scrap", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Scrap"),
      prism.components.Position(),
      prism.components.Drawable { char = "%", color = prism.Color4.YELLOW },
      prism.components.Item {
         stackable = prism.actors.Scrap,
         stackLimit = 99,
      },
      prism.components.Edible(1),
   }
end)
