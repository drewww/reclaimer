-- TODO add an ammo type parameter to this, pass it into the ammo component.
-- prism.registerActor("AmmoStack", function(count)
--    return prism.Actor.fromComponents {
--       prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
--       prism.components.Health(1),
--       prism.components.Item({
--          stackable = prism.actors.AmmoStack, -- TODO work out how to make these stack separately by type.
--          stackCount = count or 1,
--          stackLimit = 99
--       })
--    }
-- end)

AMMO_TYPES = {}

local function registerAmmo(type)
   --- @return Actor
   return function()
      return prism.Actor.fromComponents {
         prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
         prism.components.Health(1),
         prism.components.Item({
            stackable = AMMO_TYPES[type], -- TODO work out how to make these stack separately by type.
            stackCount = 1,
            stackLimit = 99
         })
      }
   end
end
-- table stores ACTOR constructors that we can pass into Item.stackable

AMMO_TYPES["pistol"] = registerAmmo("pistol")
AMMO_TYPES["rocket"] = registerAmmo("rocket")
AMMO_TYPES["shotgun"] = registerAmmo("shotgun")
AMMO_TYPES["laser"] = registerAmmo("laser")
AMMO_TYPES["rifle"] = registerAmmo("rifle")
