local GameOverState = require "gamestates.gameoverstate"
local InfoFrame = require "display.infoframe"
local Game = require "game"
local WeaponUtil = require "util.weapons"
local WeaponFrame = require "display.weaponframe"
local knockback = require "util.knockback"

--- @class GameLevelState : LevelState
--- A custom game level state responsible for initializing the level map,
--- handling input, and drawing the state to the screen.
---
--- @field path Path
--- @field level Level
--- @overload fun(display: Display, builder: LevelBuilder, seed: string): GameLevelState
local GameLevelState = spectrum.LevelState:extend "GameLevelState"

-- set up my custom turn logic

--- This is the default core turn logic. Use :lua:func:`LevelBuilder.addTurnHandler` to override this.

---@param level Level
---@param actor Actor
---@param controller Controller
---@diagnostic disable-next-line
function turn(level, actor, controller)
   local continueTurn = false
   repeat
      prism.logger.info("IN TURN FOR ACTOR ", actor:getName())
      local action = controller:act(level, actor)
      -- if actor:has(prism.components.PlayerController) then
      prism.logger.info("action: " .. action.className .. " for actor: " .. actor.className)
      -- end
      -- we make sure we got an action back from the controller for sanity's sake
      assert(action, "Actor " .. actor:getName() .. " returned nil from act()")

      if (level:canPerform(action)) then
         prism.logger.info("Returning action.")
         level:perform(action)
      else
         prism.logger.error("Failed to perform action: " .. tostring(action))
      end

      -- if the actor is dashing and the move they're doing right now is a Move, continue the turn.
      -- later logic may include things like "does the gun firing have multiple shot available?"
      -- certain enemies may get multiple actions a turn.
      -- we may generalize this into an action cost / available AP model at some point, too.
      -- also, we will want to limit dash distances. both per dash and overall dash energy available.
      continueTurn = (actor:has(prism.components.Dashing)
         and (prism.actions.Move:is(action)) or prism.actions.Dash:is(action))

      if prism.actions.SelectWeapon:is(action) then
         continueTurn = true
      end

      if not actor:has(prism.components.PlayerController) then
         continueTurn = false
      end

      if actor:has(prism.components.PlayerController) then
         -- prism.logger.info("continueTurn: " .. tostring(continueTurn))
      end
   until not continueTurn
end

--- @param builder LevelBuilder
--- @param seed string
function GameLevelState:__new(builder, seed)
   -- Construct a simple test map using LevelBuilder.
   -- In a complete game, you'd likely extract this logic to a separate module
   -- and pass in an existing player object between levels.

   builder:addSystems(
      prism.systems.Senses(),
      prism.systems.Sight(),
      -- prism.systems.Alert(),
      prism.systems.Energy(),
      prism.systems.Tick()
   -- prism.systems.Target()
   )

   -- setup custom turn handler
   builder:addTurnHandler(turn)

   local spriteAtlas = spectrum.SpriteAtlas.fromGrid("display/reclaimer_tiles.png", 32, 32)
   self.display = spectrum.Display(SCREEN_WIDTH, SCREEN_HEIGHT, spriteAtlas, prism.Vector2(32, 32))
   self.display:fitWindowToTerminal()

   -- Initialize with the created level and display, the heavy lifting is done by
   -- the parent class.
   spectrum.LevelState.__new(self, builder:build(), self.display)

   --- @type Vector2?
   self.mouseCellPosition = nil
   self.mouseCellPositionChanged = false

   -- TODO consider if this should be inlined
   self.controls = require "controls"
   local cp437Atlas = require "display.cp437_atlas"

   self.uiDisplay = spectrum.Display(self.display.width * 2, self.display.height * 2, cp437Atlas, prism.Vector2(16, 16))

   self.infoFrame = InfoFrame(self.level, self.uiDisplay)
   self.weaponFrame = WeaponFrame(self.level, self.uiDisplay)
end

function GameLevelState:handleMessage(message)
   spectrum.LevelState.handleMessage(self, message)

   -- Handle any messages sent to the level state from the level. LevelState
   -- handles a few built-in messages for you, like the decision you fill out
   -- here.

   -- This is where you'd process custom messages like advancing to the next
   -- level or triggering a game over.
   if prism.messages.Lose:is(message) then self.manager:enter(GameOverState(true)) end

   if prism.messages.Descend:is(message) then
      prism.logger.info("DESCENDING")

      Game.depth = Game.depth + 1

      Game.stats:increment("depth", 1)
      Game.stats:print()

      if Game.depth == 0 then
         self.manager:enter(GameOverState(false))
      else
         --- @cast message DescendMessage
         self.manager:enter(GameLevelState(Game:generateNextFloor(message.descender), Game:getLevelSeed()))
      end
   end
end

function GameLevelState:updateCamera()
   local position = self.level:query(prism.components.PlayerController):first():getPosition()
   if not position then return end

   local x, y = self.display:getCenterOffset(position:decompose())
   self.display:setCamera(x, y)
end

--- @param primary Senses[] { curActor:getComponent(prism.components.Senses)}
--- @param secondary Senses[]
function GameLevelState:draw(primary, secondary)
   self.display:clear()
   self.uiDisplay:clear()

   local player = self.level:query(prism.components.PlayerController):first()
   assert(player)

   if self.decision or not self.display.camera then
      self:updateCamera()
   end

   local cameraX, cameraY = self.display.camera:decompose()

   local primary, secondary = self:getSenses()
   -- Render the level using the actor’s senses
   self.display:putSenses(primary, secondary, self.level)

   -- custom terminal drawing goes here!

   local health = player:get(prism.components.Health)
   if health then self.display:putString(1, 1, "HP:" .. health.hp .. "/" .. health.maxHP) end

   local log = player:get(prism.components.Log)
   if log then
      local offset = 0
      for line in log:iterLast(5) do
         self.display:putString(1, self.display.height - offset, line)
         offset = offset + 1
      end
   end

   local playerSenses = player:get(prism.components.Senses)

   -- loop through the cells. this is inefficient.

   if player:has(prism.components.Inventory) then
      local inventory = player:get(prism.components.Inventory)

      local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)


      for cellX, cellY, cell in self.level:eachCell() do
         local color = prism.Color4.TRANSPARENT

         -- checks -- player can see, and it's in range of current weapon
         -- position is playerPosition

         -- if weapon and
         --     player:getPosition():distance(prism.Vector2(cellX, cellY)) <= weapon.range
         --     and playerSenses
         --     and playerSenses.cells:get(cellX, cellY)
         -- then
         --    color = prism.Color4(0.5, 0.5, 1.0, 0.2)
         -- end

         local layer = 50
         if cell:has(prism.components.Dashing) then color = prism.Color4(0.5, 0.5, 1.0, 0.5) end

         if cell:has(prism.components.Targeted) then
            local targeted = cell:get(prism.components.Targeted)
            assert(targeted)

            color = prism.Color4(1.0, 0, 0, 0.3 + 0.2 * targeted.times)
            layer = math.huge - 10
         end

         self.display:putBG(cellX + cameraX, cellY + cameraY, color, layer)
      end
   end


   if self.mouseCellPosition then
      local mouseX, mouseY = self.mouseCellPosition.x, self.mouseCellPosition.y

      -- prism.logger.info(string.format("Drawing mouse cell position: x=%d, y=%d, w=%d, h=%d", x, y, w, h))

      -- figure out what points to highlight given the current weapon
      if player then
         local weapon = WeaponUtil.getActive(player:get(prism.components.Inventory))
         assert(weapon, "No weapon")

         local points = WeaponUtil.getTargetPoints(self.level, player, prism.Vector2(mouseX, mouseY))

         for i, point in ipairs(points) do
            self.display:putBG(point.x + cameraX, point.y + cameraY, prism.Color4(0.5, 0.5, 1.0, 0.5), 50)
         end

         -- to see if this is working, only do this if the target point has changed, not every frame.

         -- consider if there are entities in the set of points.
         -- if there are, and the current weapon has push, loop a non-blocking push animation
         -- for that entity.
         if self.mouseCellPositionChanged then
            -- prism.logger.info("mouseCellPositionChanged")
            self.display:skipAnimations()

            local weaponC = weapon:get(prism.components.Weapon)
            local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }
            if #points > 0 and weaponC and weaponC.push > 0 then
               for _, point in ipairs(points) do
                  local entity = self.level:query(prism.components.Collider):at(point:decompose()):first()
                  -- prism.logger.info("Entity at weapon target point: ", point, entity)

                  if entity then
                     -- prism.logger.info("entity: ", entity:getName())
                     -- return function(level, startPos, direction, maxCells, moveMask)
                     -- TODO this needs to adapt to the AOE knockback variation, but this works
                     -- for everything else.
                     local direction = point - player:getPosition()

                     if weaponC.template == "aoe" then
                        direction = point - prism.Vector2(mouseX, mouseY)
                     end

                     -- prism.logger.info("direction: ", direction)
                     local finalPos, hitWall, cellsMoved, path, impassablePos = knockback(self.level, point, direction,
                        weaponC.push,
                        mask)

                     -- prism.logger.info("starting push. final, hit, cells: ", finalPos, hitWall, cellsMoved)
                     for _, p in ipairs(path) do
                        prism.logger.info("pushing entity to: ", p)
                     end

                     -- prism.logger.info("triggering animation: ", entity, #path)

                     self.display:yieldAnimation(prism.messages.Animation {
                        animation = spectrum.animations.Push(entity, path, true, impassablePos),
                        blocking = false,
                        skippable = true
                     })
                  end
               end
            end
         end
      end
   end

   -- custom handle the player.
   if player:has(prism.components.Dashing) then
      self.display:putBG(player:getPosition().x + cameraX, player:getPosition().y + cameraY,
         prism.Color4(0.5, 0.5, 1.0, 0.5))
   end

   -- Actually render the terminal out and present it to the screen.
   -- You could use love2d to translate and say center a smaller terminal or
   -- offset it for custom non-terminal UI elements. If you do scale the UI
   -- just remember that display:getCellUnderMouse expects the mouse in the
   -- display's local pixel coordinates
   self.infoFrame:draw()
   self.weaponFrame:draw()


   self.display:draw()
   self.uiDisplay:draw()

   -- custom love2d drawing goes here!
   -- love.graphics.pop("all")
   love.graphics.setColor(1, 1, 1, 1)

   -- now, based on active weapon -- show an appropriate weapon image.
   -- figure out looking up after, just place it.
   self.weaponFrame:drawActiveWeapon()
end

function GameLevelState:mousepressed(x, y, button, istouch, presses)
   -- self.display:skipAnimations()
   -- get the cell under the mouse button
   local cellX, cellY, targetCell = self:getCellUnderMouse()
   local playerSenses = self.level:query(prism.components.PlayerController):first():get(prism.components.Senses)

   if playerSenses and not playerSenses.cells:get(cellX, cellY) then
      return
   end

   local target = prism.Vector2(cellX, cellY)

   local decision = self.decision
   if not decision then return end

   -- local target = self.level:query(prism.components.Collider):at(cellX, cellY):first()

   -- not totally sure why this isn't just Player. Can decision have a different actor?
   -- if target then
   prism.logger.info("Shooting at entity at " .. tostring(target))

   local shoot = prism.actions.Shoot(decision.actor, target)
   decision:setAction(shoot, self.level)
   -- end
end

function GameLevelState:mousemoved()
   local cellX, cellY, targetCell = self:getCellUnderMouse()

   local playerSenses = self.level:query(prism.components.PlayerController):first():get(prism.components.Senses)

   if playerSenses then
      if playerSenses.cells:get(cellX, cellY) then
         if self.mouseCellPosition and self.mouseCellPosition:equals(cellX, cellY) and targetCell then
            self.mouseCellPositionChanged = false
         else
            self.mouseCellPositionChanged = true
            self.mouseCellPosition = targetCell and prism.Vector2(cellX, cellY) or nil

            -- prism.logger.info("yielding to notice")
            -- self.level:yield(
            --    prism.messages.Animation {
            --       animation = spectrum.animations.Notice("RELOAD", cellX, cellY),
            --       blocking = false
            --    }
            -- )
         end
      else
         self.mouseCellPosition = nil
      end
   else
      self.mouseCellPosition = nil
   end
end

-- The input handling functions act as the player controller’s logic.
-- You should NOT mutate the Level here directly. Instead, find a valid
-- action and set it in the decision object. It will then be executed by
-- the level. This is a similar pattern to the example KoboldController.
function GameLevelState:updateDecision(dt, owner, decision)
   self.controls:update()

   -- if self.controls.move.pressed or self.controls.dash.pressed then
   if self.controls.move.pressed then
      -- self.display:skipAnimations()

      local vector
      -- if self.controls.move.pressed then
      vector = self.controls.move.vector
      -- else
      -- vector = self.controls.dash.vector
      -- end

      local destination = owner:getPosition() + vector

      -- test for descending
      local descendTarget = self.level:query(prism.components.Stair)
          :at(destination:decompose())
          :first()
      local descend = prism.actions.Descend(owner, descendTarget)
      if self.level:canPerform(descend) then
         self:setAction(descend)
      end

      -- test for a loot box to open
      local openableTarget = self.level:query(prism.components.Openable):at(destination:decompose())
          :first()

      if openableTarget then
         -- prism.logger.info("bumping into openable target")

         local set, err = decision:setAction(prism.actions.Open(owner, openableTarget), self.level)
         if err then
            prism.logger.error("error opening: " .. err)
         end
      end

      local move = prism.actions.Move(owner, destination)
      if self:setAction(move) then return end
   end

   if self.controls.wait.pressed then
      decision:setAction(prism.actions.Wait(self.decision.actor), self.level)
   end

   if self.controls.dash.pressed or self.controls.dash.released then
      prism.logger.info("DASH ACTION")
      decision:setAction(prism.actions.Dash(self.decision.actor), self.level)
   end

   if self.controls.pickup.pressed then
      local target = self.level:query(prism.components.Item):at(owner:getPosition():decompose()):first()

      local pickup = prism.actions.Pickup(owner, target)

      if pickup:canPerform() and target and target:getName() == "nanos" then
         Game.stats:increment("cash", target:get(prism.components.Item).stackCount)
      end

      decision:setAction(pickup, self.level)
   end


   -- check on weapon selection keys
   local weaponHotkey = nil
   for key, control in pairs(self.controls) do
      local n = key:match("^weapon_(%d+)$")
      if n and control.pressed then
         weaponHotkey = tonumber(n)
         break
      end
   end

   if weaponHotkey then
      -- prism.logger.info("setting selectWeapon action with hotkey: " .. tostring(weaponHotkey))
      decision:setAction(prism.actions.SelectWeapon(owner, weaponHotkey), self.level)
   end

   if self.controls.reload.pressed then
      prism.logger.info("reloading")
      local weapon = WeaponUtil.getActive(owner:get(prism.components.Inventory))

      local set, err = decision:setAction(prism.actions.Reload(owner), self.level)
      prism.logger.info("reload: " .. tostring(set))
      if err then
         prism.logger.info("result: " .. tostring(set) .. " " .. err)
      end
   end
end

return GameLevelState
