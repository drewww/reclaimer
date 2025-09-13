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
   self.gridWidth = 4
   self.gridHeight = 7
   self.cursorX = 1
   self.cursorY = 1

   -- Get player's current money from inventory
   local inventory = Game.player:get(prism.components.Inventory)
   self.maxSpend = inventory and inventory:getStack(prism.actors.Loot):get(prism.components.Item).stackCount or 0

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
   self.menuGrid[self:coordKey(1, 1)] = {
      actor = nil,
      displayName = "Laser",
      price = 10,
      purchased = false
   }
   self.menuGrid[self:coordKey(2, 1)] = {
      actor = nil,
      displayName = "Shotgun",
      price = 10,
      purchased = false
   }

   self.menuGrid[self:coordKey(1, 2)] = {
      actor = AMMO_TYPES["Pistol"](20),
      displayName = "Pistol Ammo (20)",
      price = 1,
      purchased = false
   }
   self.menuGrid[self:coordKey(2, 2)] = {
      actor = AMMO_TYPES["Shotgun"](8),
      displayName = "Shotgun Ammo (8)",
      price = 2,
      purchased = false
   }

   self.menuGrid[self:coordKey(3, 2)] = {
      actor = AMMO_TYPES["Laser"](5),
      displayName = "Laser Ammo (5)",
      price = 2,
      purchased = false
   }

   self.menuGrid[self:coordKey(1, 3)] = {
      actor = AMMO_TYPES["Rocket"](2),
      displayName = "Rocket Ammo (2)",
      price = 2,
      purchased = false
   }

   self.menuGrid[self:coordKey(1, 4)] = {
      actor = nil,
      displayName = "Heal All",
      price = 1,
      purchased = false
   }

   self.menuGrid[self:coordKey(1, 6)] = {
      actor = nil,
      displayName = "RESET",
      price = 0,
      purchased = false
   }

   self.menuGrid[self:coordKey(2, 6)] = {
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

function ResupplyState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   self.display:putString(3, 3, "RESUPPLY", nil, nil, nil, "left")

   -- Display money information
   local totalSpend = self:getTotalSpend()
   local remaining = self.maxSpend - totalSpend
   self.display:putString(3, 5, "Money Available: " .. self.maxSpend, prism.Color4.WHITE, nil, nil, "left")
   self.display:putString(3, 6, "Total Spend: " .. totalSpend, prism.Color4.WHITE, nil, nil, "left")
   self.display:putString(3, 7, "Money Remaining: " .. remaining,
      remaining >= 0 and prism.Color4.GREEN or prism.Color4.RED, nil, nil, "left")

   -- Draw menu grid
   local startX, startY = 5, 10
   for y = 1, self.gridHeight do
      for x = 1, self.gridWidth do
         local item = self:getItemAt(x, y)
         local displayX = startX + (x - 1) * 20
         local displayY = startY + (y - 1) * 3

         if item then
            local color = item.purchased and prism.Color4.GREY or prism.Color4.WHITE
            local prefix = ""

            -- Check if item is affordable
            local totalSpend = self:getTotalSpend()
            local canAfford = item.purchased or (totalSpend + item.price <= self.maxSpend) or item.price == 0

            if not canAfford then
               color = prism.Color4.RED
            end

            -- Add cursor indicator
            if x == self.cursorX and y == self.cursorY then
               prefix = "> "
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
