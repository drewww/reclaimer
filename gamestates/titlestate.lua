local MapState       = require "gamestates.mapstate"
local GameLevelState = require "gamestates.gamelevelstate"
local Game           = require "game"

--- @class TitleState : GameState
--- @field display Display
--- @overload fun(): GameState
local TitleState     = spectrum.GameState:extend("TitleState")
local cp437Atlas     = require "display.cp437_atlas"

function TitleState:__new()
   self.display = spectrum.Display(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, cp437Atlas, prism.Vector2(16, 16))
   self.display:fitWindowToTerminal()

   -- Load title image
   self.titleImage = love.graphics.newImage("display/images/game_title.png")
   self.contractImage = love.graphics.newImage("display/images/crawl_title.png")

   -- Track state: "title" or "contract"
   self.state = "title"

   self.controls = spectrum.Input.Controls {
      controls = {
         start = { "p", "P" },
         quit = { "q", "Q" },
         generate = { "g", "G" },
         credits = { "c", "C" },
         help = { "h", "H" },
         anykey = { "return", "space", "escape", "w", "a", "s", "d", "up", "down", "left", "right", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
      }
   }
end

function TitleState:draw()
   local midpointX, midpointY = math.floor(self.display.width / 2), math.floor(self.display.height / 2)

   self.display:clear()

   -- self.display:putString(midpointX + 2, 20, "[P]lay", nil, nil, nil, "left", midpointX - 2)

   -- self.display:putString(midpointX + 2, 22, "[Q]uit", nil, nil, nil, "left", midpointX - 2)

   self.display:draw()

   -- Draw appropriate image based on state
   if self.state == "title" then
      love.graphics.draw(self.titleImage, 0, 0)
   elseif self.state == "contract" then
      love.graphics.draw(self.contractImage, 0, 0)
   end
end

function TitleState:update(dt)
   self.controls:update()

   if self.state == "title" then
      if self.controls.start.pressed then
         -- Switch to contract briefing screen
         self.state = "contract"
      elseif self.controls.quit.pressed then
         love.event.quit()
      elseif self.controls.generate.pressed then
         self.manager:enter(MapState(self.display))
      elseif self.controls.help.pressed then
         -- TODO build this out
      elseif self.controls.credits.pressed then
         -- TODO merge this in.
         local CreditsState = require "gamestates.creditsstate"

         self.manager:enter(CreditsState(self))
      end
   elseif self.state == "contract" then
      -- Any key press starts the game
      if self.controls.anykey.pressed or self.controls.start.pressed or self.controls.quit.pressed then
         local player = prism.actors.Player()

         local inventory = player:get(prism.components.Inventory)
         if inventory then
            -- DEFINE STARTING INVENTORY
            local ammo = AMMO_TYPES["Pistol"](10)
            inventory:addItem(ammo)

            local pistol = prism.actors.Pistol()
            pistol:get(prism.components.Weapon).active = true
            inventory:addItem(pistol)

            local knife = prism.actors.Knife()
            inventory:addItem(knife)

            -- local shotgun = prism.actors.Shotgun()
            -- inventory:addItem(shotgun)
            -- inventory:addItem(AMMO_TYPES["Shotgun"](12))

            -- local laser = prism.actors.Laser()
            -- inventory:addItem(laser)
            -- inventory:addItem(AMMO_TYPES["Laser"](10))


            -- local rocket = prism.actors.Rocket()
            -- inventory:addItem(rocket)
            -- inventory:addItem(AMMO_TYPES["Rocket"](2))
         end

         Game.player = player

         local builder = Game:generateNextFloor()
         prism.logger:info("entering game state")

         self.manager:enter(GameLevelState(builder, Game:getLevelSeed()))
      end
   end
end

return TitleState
