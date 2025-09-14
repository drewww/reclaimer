local Game = require "game"
local Audio = require "audio"

--- @class ResupplyState : GameState
--- @field display Display
--- @field menuGrid table
--- @field gridWidth number
--- @field gridHeight number
--- @field cursorX number
--- @field cursorY number
--- @field maxSpend number
--- @overload fun(): ResupplyState
local ResupplyState = spectrum.GameState:extend("ResupplyState")

function ResupplyState:__new()
   local cp437Atlas = require "display.cp437_atlas"

   self.display     = spectrum.Display(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, cp437Atlas, prism.Vector2(16, 16))
   self.display:fitWindowToTerminal()

   -- Menu grid setup
   self.menuGrid = {}
   self.gridWidth = 4
   self.gridHeight = 6
   self.cursorX = 1
   self.cursorY = 1

   -- Grid positioning constants
   self.cellWidth = 12
   self.cellHeight = 4
   self.cellPadding = 0

   -- Load weapon images
   self.weaponImages = {
      Pistol = love.graphics.newImage("display/weapons/weapon_0.png"),
      Rocket = love.graphics.newImage("display/weapons/weapon_1.png"),
      Laser = love.graphics.newImage("display/weapons/weapon_2.png"),
      Shotgun = love.graphics.newImage("display/weapons/weapon_3.png"),
   }

   -- Load resupply background image
   self.resupplyImage = love.graphics.newImage("display/images/resupply_title.png")

   -- Get player's current money from inventory
   local inventory = Game.player:get(prism.components.Inventory)
   local loot = inventory:getStack(prism.actors.Loot)

   self.maxSpend = loot and loot:get(prism.components.Item).stackCount or 0

   prism.logger.info("maxSpend = " .. self.maxSpend)

   self.controls = spectrum.Input.Controls {
      controls = {
         move_up        = { "w", "k", "kp8", "up" },
         move_upleft    = { "q", "y", "kp7" },
         move_upright   = { "e", "u", "kp9" },
         move_left      = { "a", "h", "kp4", "left" },
         move_right     = { "d", "l", "kp6", "right" },
         move_downleft  = { "z", "b", "kp1" },
         move_down      = { "s", "j", "kp2", "down" },
         move_downright = { "c", "n" },
         select         = { "return", "space" },
      },

      pairs = {
         move = { "move_upleft", "move_up", "move_upright", "move_left", "move_right", "move_downleft", "move_down", "move_downright" }
      }
   }

   -- Initialize the menu items
   self:initializeMenu()


   -- local inventory = Game.player:get(prism.components.Inventory)
   -- local cash = inventory:getStack(prism.actors.Loot)

   -- self.maxSpend = cash.stackCount
end

function ResupplyState:coordKey(x, y)
   return x .. "," .. y
end

function ResupplyState:initializeMenu()
   -- Example menu items - replace with actual actors/items

   -- looks at the next depth in the list
   local depthInfo = DEPTHS[10 + Game.depth]
   local inventory = Game.player:get(prism.components.Inventory)

   -- show ammo if the player has the weapon

   local hasShotgun, hasLaser, hasRocket = false, false, false
   for _, actor in ipairs(inventory:query(prism.components.Weapon):gather()) do
      local weaponC = actor:get(prism.components.Weapon)
      prism.logger.info("weapon.ammotype: " .. weaponC.ammoType)
      if weaponC.ammoType == "Shotgun" then
         hasShotgun = true
      elseif weaponC.ammoType == "Laser" then
         hasLaser = true
      elseif weaponC.ammoType == "Rocket" then
         hasRocket = true
      end
   end

   if (depthInfo.weapons[1] == "laser" or depthInfo.weapons[2] == "laser") and not hasLaser then
      self.menuGrid[self:coordKey(3, 1)] = {
         actor = prism.actors.Laser(),
         displayName = "Laser",
         price = 10,
         purchased = false
      }
   end

   if (depthInfo.weapons[1] == "shotgun" or depthInfo.weapons[2] == "shotgun") and not hasShotgun then
      self.menuGrid[self:coordKey(2, 1)] = {
         actor = prism.actors.Shotgun(),
         displayName = "Shotgun",
         price = 10,
         purchased = false
      }
   end

   if (depthInfo.weapons[1] == "rocket" or depthInfo.weapons[2] == "rocket") and not hasRocket then
      self.menuGrid[self:coordKey(4, 1)] = {
         actor = prism.actors.Rocket(),
         displayName = "Rocket",
         price = 10,
         purchased = false
      }
   end

   self.menuGrid[self:coordKey(1, 2)] = {
      actor = AMMO_TYPES["Pistol"](15),
      displayName = "Bullet x15",
      price = 1,
      purchased = false
   }



   if hasShotgun then
      self.menuGrid[self:coordKey(2, 2)] = {
         actor = AMMO_TYPES["Shotgun"](8),
         displayName = "Shells x8",
         price = 2,
         purchased = false
      }
   end

   if hasLaser then
      self.menuGrid[self:coordKey(3, 2)] = {
         actor = AMMO_TYPES["Laser"](5),
         displayName = "Battery x5",
         price = 2,
         purchased = false
      }
   end

   if hasRocket then
      self.menuGrid[self:coordKey(4, 2)] = {
         actor = AMMO_TYPES["Rocket"](2),
         displayName = "Rocket x2",
         price = 2,
         purchased = false
      }
   end

   self.menuGrid[self:coordKey(1, 3)] = {
      actor = nil,
      displayName = "Heal All",
      price = 1,
      purchased = false
   }

   self.menuGrid[self:coordKey(2, 3)] = {
      actor = nil,
      displayName = "Health +1",
      price = 4,
      purchased = false
   }

   self.menuGrid[self:coordKey(3, 3)] = {
      actor = nil,
      displayName = "Energy +1",
      price = 4,
      purchased = false
   }

   self.menuGrid[self:coordKey(4, 3)] = {
      actor = nil,
      displayName = "Recharge +1",
      price = 4,
      purchased = false
   }

   self.menuGrid[self:coordKey(1, 5)] = {
      actor = nil,
      displayName = "RESET",
      price = 0,
      purchased = false
   }

   self.menuGrid[self:coordKey(2, 5)] = {
      actor = nil,
      displayName = "COMPLETE",
      price = 0,
      purchased = false
   }
end

function ResupplyState:getItemAt(x, y)
   return self.menuGrid[self:coordKey(x, y)]
end

function ResupplyState:getCurrentItem()
   return self:getItemAt(self.cursorX, self.cursorY)
end

function ResupplyState:getTotalSpend()
   local total = 0
   for _, item in pairs(self.menuGrid) do
      if item.purchased and item.price > 0 then
         total = total + item.price
      end
   end
   return total
end

function ResupplyState:moveCursor(dx, dy)
   local newX = self.cursorX + dx
   local newY = self.cursorY + dy

   -- Wrap around horizontally
   if newX < 1 then
      newX = self.gridWidth
   elseif newX > self.gridWidth then
      newX = 1
   end

   -- Wrap around vertically
   if newY < 1 then
      newY = self.gridHeight
   elseif newY > self.gridHeight then
      newY = 1
   end

   self.cursorX = newX
   self.cursorY = newY
end

function ResupplyState:drawWeaponImages()
   -- Draw weapon images above columns that have weapons or ammo available
   local imageY = 10 * 16 -- Position images above the menu grid (shifted down)
   local weaponTypes = { "Pistol", "Shotgun", "Laser", "Rocket" }

   -- Column order is always: pistol, shotgun, laser, rocket
   for x = 1, 4 do
      -- Check if this column has any items (weapon or ammo)
      local hasItems = false
      for y = 1, self.gridHeight do
         if self:getItemAt(x, y) then
            hasItems = true
            break
         end
      end

      -- Draw the weapon image if column has items
      if hasItems then
         local imageX = (12 + (x - 1) * self.cellWidth) * 16 -- Match column positioning
         love.graphics.draw(self.weaponImages[weaponTypes[x]], imageX, imageY)
      end
   end
end

function ResupplyState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   -- Draw resupply background image
   love.graphics.draw(self.resupplyImage, 0, 0)

   -- Display money information (shifted down)
   local totalSpend = self:getTotalSpend()
   local remaining = self.maxSpend - totalSpend
   self.display:put(6, 8, CENTS, prism.Color4.YELLOW)
   self.display:putString(8, 8,
      tostring(self.maxSpend) .. " - " .. tostring(totalSpend) .. " = " .. tostring(remaining), prism.Color4.WHITE,
      nil, nil, "left")

   self.display:putString(5, 15 + 0, "WEAPONS", prism.Color4.WHITE)
   self.display:putString(8, 15 + 4, "AMMO", prism.Color4.WHITE)
   self.display:putString(5, 15 + 8, "SERVICE", prism.Color4.WHITE)

   -- Draw menu grid (pushed down to make room for background image and weapon images)
   local startX, startY = 13, 15
   for y = 1, self.gridHeight do
      for x = 1, self.gridWidth do
         local item = self:getItemAt(x, y)
         local displayX = startX + (x - 1) * (self.cellWidth + self.cellPadding)
         local displayY = startY + (y - 1) * (self.cellHeight + self.cellPadding)

         if item then
            local color = item.purchased and prism.Color4.DARKGREY or prism.Color4.WHITE
            local prefix = ""

            -- Check if item is affordable
            local canAfford = item.purchased or (totalSpend + item.price <= self.maxSpend) or item.price == 0

            if not canAfford then
               color = prism.Color4.RED
            end

            -- Add cursor indicator
            local bg = prism.Color4.BLACK
            if x == self.cursorX and y == self.cursorY then
               if canAfford and not item.purchased then
                  color = prism.Color4.BLACK
                  bg = prism.Color4.WHITE
               elseif item.purchased then
                  color = prism.Color4.DARKGREY
                  bg = prism.Color4.WHITE
               else
                  color = prism.Color4.RED
                  bg = prism.Color4.WHITE
               end

               self.display:putFilledRect(displayX, displayY, 11, 2, 1, bg, bg)
            end

            self.display:putString(displayX, displayY, prefix .. item.displayName, color, bg, nil, "left")

            if item.price > 0 then
               self.display:put(displayX, displayY + 1, CENTS, color, bg)
               self.display:putString(displayX + 1, displayY + 1, tostring(item.price), color, bg)
            end
         else
            -- just render the selection
            if self.cursorX == x and self.cursorY == y then
               -- prism.logger.info("render menu location")
               self.display:putFilledRect(displayX, displayY, 11, 2, 1, prism.Color4.DARKGREY, prism.Color4.DARKGREY)
            end
         end
      end
   end

   self.display:draw()

   -- Draw weapon images above the grid (using Love2D graphics)
   love.graphics.setColor(1, 1, 1, 1)
   self:drawWeaponImages()
end

function ResupplyState:update(dt)
   self.controls:update()
   Audio.update()

   if self.controls.move.pressed then
      local vector = self.controls.move.vector

      -- repeat
      if vector then
         self:moveCursor(vector.x, vector.y)
      end
      -- until self:getCurrentItem()


      prism.logger.info("Moving cursor to: ", self.cursorX, self.cursorY, " due to vector ", vector)
   end

   if self.controls.select.pressed then
      Audio.playSfx("select")

      local currentItem = self:getCurrentItem()
      if currentItem then
         if currentItem.displayName == "RESET" then
            -- loop through all items and set them to not purchased
            prism.logger.info("Resetting purchases")
            for _, item in pairs(self.menuGrid) do
               prism.logger.info("Resetting item: ", item.displayName)
               item.purchased = false
            end

            return
         end

         if currentItem.displayName == "COMPLETE" then
            -- execute the purchases and deduct money
            local inventory = Game.player:get(prism.components.Inventory)
            local totalSpend = self:getTotalSpend()

            -- Remove the spent money from inventory
            if inventory and totalSpend > 0 then
               local loot = inventory:getStack(prism.actors.Loot)
               inventory:removeQuantity(loot, totalSpend)
            end

            for _, item in pairs(self.menuGrid) do
               if item.displayName == "Heal All" and item.purchased then
                  local health = Game.player:get(prism.components.Health)
                  health:heal(health.maxHP)
               elseif item.displayName == "Health +1" and item.purchased then
                  local health = Game.player:get(prism.components.Health)
                  health.maxHP = health.maxHP + 1
                  health.hp = health.hp + 1
                  prism.logger.info("Increased max health to: " .. health.maxHP)
               elseif item.displayName == "Energy +1" and item.purchased then
                  local energy = Game.player:get(prism.components.Energy)
                  if energy then
                     energy.maxEnergy = energy.maxEnergy + 1
                     energy.energy = energy.energy + 1
                     prism.logger.info("Increased max energy to: " .. energy.maxEnergy)
                  end
               elseif item.displayName == "Recharge +1" and item.purchased then
                  local energy = Game.player:get(prism.components.Energy)
                  if energy then
                     energy.recharge = energy.recharge + 0.125
                     prism.logger.info("Increased recharge to: " .. energy.recharge)
                  end
               elseif item.purchased and inventory and item.actor then
                  prism.logger.info("Adding item: ", item.displayName)
                  inventory:addItem(item.actor)

                  -- Grant bonus ammo when purchasing weapons
                  if item.displayName == "Laser" then
                     local laserAmmo = AMMO_TYPES["Laser"](3)
                     inventory:addItem(laserAmmo)
                     prism.logger.info("Added bonus Laser ammo (5)")
                  elseif item.displayName == "Shotgun" then
                     local shotgunAmmo = AMMO_TYPES["Shotgun"](8)
                     inventory:addItem(shotgunAmmo)
                     prism.logger.info("Added bonus Shotgun ammo (8)")
                  elseif item.displayName == "Rocket" then
                     local rocketAmmo = AMMO_TYPES["Rocket"](2)
                     inventory:addItem(rocketAmmo)
                     prism.logger.info("Added bonus Rocket ammo (2)")
                  end
               end
            end

            local GameLevelState = require "gamestates.gamelevelstate"
            self.manager:enter(GameLevelState(Game:generateNextFloor(), Game:getLevelSeed()))
            return
         end

         if not currentItem.purchased then
            -- Check if player has enough money/resources
            local totalSpend = self:getTotalSpend()
            if currentItem.price == 0 or totalSpend + currentItem.price <= self.maxSpend then
               currentItem.purchased = true
               prism.logger.info("Purchased: ", currentItem.displayName)
            else
               prism.logger.info("Cannot afford: ", currentItem.displayName)
            end
         else
            currentItem.purchased = false
            prism.logger.info("Item unpurchased: ", currentItem.displayName)
         end
      end
   end
end

return ResupplyState
