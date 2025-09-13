local Game = require "game"

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
   self.gridWidth = 5
   self.gridHeight = 7
   self.cursorX = 1
   self.cursorY = 1

   -- Load weapon images
   self.weaponImages = {
      Pistol = love.graphics.newImage("display/weapons/weapon_0.png"),
      Rocket = love.graphics.newImage("display/weapons/weapon_1.png"),
      Laser = love.graphics.newImage("display/weapons/weapon_2.png"),
      Shotgun = love.graphics.newImage("display/weapons/weapon_3.png"),
   }

   -- Get player's current money from inventory
   local inventory = Game.player:get(prism.components.Inventory)
   local loot = inventory:getStack(prism.actors.Loot)

   self.maxSpend = loot and loot:get(prism.components.Item).stackCount or 0

   prism.logger.info("maxSpend = " .. self.maxSpend)

   self.controls = spectrum.Input.Controls {
      controls = {
         move_up    = { "w", "k" },
         move_left  = { "a", "h" },
         move_right = { "d", "l" },
         move_down  = { "s", "j" },
         select     = { "return", "space" },
      },

      pairs = {
         move = { "move_up", "move_left", "move_right", "move_down" }
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
      self.menuGrid[self:coordKey(1, 1)] = {
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
      self.menuGrid[self:coordKey(3, 1)] = {
         actor = prism.actors.Rocket(),
         displayName = "Rocket",
         price = 10,
         purchased = false
      }
   end

   self.menuGrid[self:coordKey(1, 2)] = {
      actor = AMMO_TYPES["Pistol"](20),
      displayName = "Pistol (20)",
      price = 1,
      purchased = false
   }



   if hasShotgun then
      self.menuGrid[self:coordKey(2, 2)] = {
         actor = AMMO_TYPES["Shotgun"](8),
         displayName = "Shotgun (8)",
         price = 2,
         purchased = false
      }
   end

   if hasLaser then
      self.menuGrid[self:coordKey(3, 2)] = {
         actor = AMMO_TYPES["Laser"](5),
         displayName = "Laser (5)",
         price = 2,
         purchased = false
      }
   end

   if hasRocket then
      self.menuGrid[self:coordKey(4, 2)] = {
         actor = AMMO_TYPES["Rocket"](2),
         displayName = "Rocket (2)",
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
   local imageY = 6 * 16 -- Position images above the menu grid
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
         local imageX = (10 + (x - 1) * 13) * 16 -- Match column positioning
         love.graphics.draw(self.weaponImages[weaponTypes[x]], imageX, imageY)
      end
   end
end

function ResupplyState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   self.display:putString(2, 2, "RESUPPLY", nil, nil, nil, "left")

   -- Display money information
   local totalSpend = self:getTotalSpend()
   local remaining = self.maxSpend - totalSpend
   self.display:put(3, 4, CENTS, prism.Color4.YELLOW)
   self.display:putString(5, 4,
      tostring(self.maxSpend) .. " - " .. tostring(totalSpend) .. " = " .. tostring(remaining), prism.Color4.WHITE,
      nil, nil, "left")
   -- self.display:putString(3, 6, "Total Spend: " .. totalSpend, prism.Color4.WHITE, nil, nil, "left")
   -- self.display:putString(3, 7, "Money Remaining: " .. remaining,
   -- remaining >= 0 and prism.Color4.GREEN or prism.Color4.RED, nil, nil, "left")

   self.display:putString(2, 11 + 0, "WEAPONS", prism.Color4.WHITE)
   self.display:putString(5, 11 + 4, "AMMO", prism.Color4.WHITE)
   self.display:putString(2, 11 + 8, "SERVICE", prism.Color4.WHITE)

   -- Draw menu grid (pushed down to make room for weapon images)
   local startX, startY = 10, 11
   for y = 1, self.gridHeight do
      for x = 1, self.gridWidth do
         local item = self:getItemAt(x, y)
         local displayX = startX + (x - 1) * 13
         local displayY = startY + (y - 1) * 4

         if item then
            local color = item.purchased and prism.Color4.GREY or prism.Color4.WHITE
            local prefix = ""

            -- Check if item is affordable
            local canAfford = item.purchased or (totalSpend + item.price <= self.maxSpend) or item.price == 0

            if not canAfford then
               color = prism.Color4.RED
            end

            -- Add cursor indicator
            if x == self.cursorX and y == self.cursorY then
               prefix = ">"
               if canAfford then
                  color = prism.Color4.YELLOW
               else
                  color = prism.Color4.RED
               end
            end

            self.display:putString(displayX, displayY, prefix .. item.displayName, color, nil, nil, "left")

            if item.price > 0 then
               self.display:putString(displayX, displayY + 1, "Price: " .. item.price, color, nil, nil, "left")
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

   if self.controls.move.pressed then
      local vector = self.controls.move.vector

      repeat
         self:moveCursor(vector.x, vector.y)
      until self:getCurrentItem()


      prism.logger.info("Moving cursor to: ", self.cursorX, self.cursorY)
   end

   if self.controls.select.pressed then
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
               elseif item.purchased and inventory and item.actor then
                  prism.logger.info("Adding item: ", item.displayName)
                  inventory:addItem(item.actor)
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
