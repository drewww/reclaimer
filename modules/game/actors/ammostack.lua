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
   local constructor = function()
      return prism.Actor.fromComponents {
         prism.components.Drawable { index = "a", color = prism.Color4.YELLOW },
         prism.components.Health(1),
         prism.components.Item({
            stackable = AMMO_TYPES[type],
            stackCount = 1,
            stackLimit = 99
         })
      }
   end

   prism.registerActor("Ammo" .. type, constructor)
   --- @return Actor
   return constructor
end

-- table stores ACTOR constructors that we can pass into Item.stackable

AMMO_TYPES["Pistol"] = registerAmmo("Pistol")
AMMO_TYPES["Rocket"] = registerAmmo("Rocket")
AMMO_TYPES["Shotgun"] = registerAmmo("Shotgun")
AMMO_TYPES["Laser"] = registerAmmo("Laser")
AMMO_TYPES["Rifle"] = registerAmmo("Rifle")
