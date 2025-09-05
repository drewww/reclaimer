local MapState       = require "gamestates.mapstate"
local GameLevelState = require "gamestates.gamelevelstate"
local Game           = require "game"

--- @class TitleState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local TitleState     = spectrum.GameState:extend("TitleState")

function TitleState:__new(display)
   self.display = display

   self.controls = spectrum.Input.Controls {
      controls = {
         start = { "p" },
         quit = { "q" },
         generate = { "g" }
      }
   }
end

function TitleState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   self.display:putString(5, 5, "RECLAIMER", nil, nil, nil, "left", self.display.width)

   self.display:putString(5, 6, "a game by drew harry", nil, nil, nil, "left", self.display.width)

   self.display:putString(midpointX + 2, 20, "[P]lay", nil, nil, nil, "left", midpointX - 2)

   self.display:putString(midpointX + 2, 22, "[Q]uit", nil, nil, nil, "left", midpointX - 2)

   self.display:draw()
end

function TitleState:update(dt)
   self.controls:update()

   if self.controls.start.pressed or self.controls.start.down or self.controls.start.released then
      prism.logger.info("UPDATE DECISON: " ..
         tostring(self.controls.start.pressed) ..
         " - " .. tostring(self.controls.start.down) .. " - " .. tostring(self.controls.start.released))
   end

   if self.controls.start.pressed then
      local player = prism.actors.Player()

      local inventory = player:get(prism.components.Inventory)
      if inventory then
         -- DEFINE STARTING INVENTORY
         local ammo = prism.actors.AmmoStack()
         ammo:get(prism.components.Item).stackCount = 50
         inventory:addItem(ammo)

         local pistol = prism.actors.Pistol()
         pistol:get(prism.components.Weapon).active = true
         inventory:addItem(pistol)

         local knife = prism.actors.Knife()
         inventory:addItem(knife)

         local shotgun = prism.actors.Shotgun()
         inventory:addItem(shotgun)

         local laser = prism.actors.Laser()
         inventory:addItem(laser)
      end



      local builder = Game:generateNextFloor(player)
      prism.logger:info("entering game state")

      self.manager:enter(GameLevelState(self.display, builder, Game:getLevelSeed()))
   elseif self.controls.quit.pressed then
      love.event.quit()
   elseif self.controls.generate.pressed then
      self.manager:enter(MapState(self.display))
   end
end

return TitleState
