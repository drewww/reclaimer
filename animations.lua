spectrum.registerAnimation("Projectile", function(owner, targetPosition, char)
   --- @cast owner Actor
   --- @cast targetPosition Vector2
   local x, y = owner:expectPosition():decompose()
   local line = prism.Bresenham(x, y, targetPosition.x, targetPosition.y)

   table.remove(line, 1)

   if not char then
      char = "*"
   end

   return spectrum.Animation(function(t, display)
      local index = math.floor(t / 0.05) + 1

      if not line or #line == 0 then return true end

      display:put(line[index][1], line[index][2], char, prism.Color4.RED)

      if index == #line then return true end

      return false
   end)
end)

spectrum.registerAnimation("Melee", function(position, color)
   return spectrum.Animation(function(t, display)
      local totalDuration = 0.2
      local progress = math.min(t / totalDuration, 1.0)

      if progress >= 1 then
         return true
      end

      -- Use Vector2.neighborhood8 in clockwise order starting from UP
      local offsets = {
         prism.Vector2.UP,         -- top
         prism.Vector2.UP_RIGHT,   -- top-right
         prism.Vector2.RIGHT,      -- right
         prism.Vector2.DOWN_RIGHT, -- bottom-right
         prism.Vector2.DOWN,       -- bottom
         prism.Vector2.DOWN_LEFT,  -- bottom-left
         prism.Vector2.LEFT,       -- left
         prism.Vector2.UP_LEFT     -- top-left
      }

      local spinColor = color or prism.Color4(1.0, 0.8, 0.3, 0.8)

      -- Calculate how many cells to light up based on progress
      local numCells = math.floor(progress * #offsets) + 1

      local x, y = position:decompose()

      -- Light up cells in clockwise order
      for i = 1, math.min(numCells, #offsets) do
         local offset = offsets[i]
         local cellX = x + offset.x
         local cellY = y + offset.y

         -- Fade earlier cells
         local cellIntensity = 1.0 - ((numCells - i) / #offsets) * 0.5
         local cellColor = prism.Color4(
            spinColor.r,
            spinColor.g,
            spinColor.b,
            spinColor.a * cellIntensity
         )

         display:putBG(cellX, cellY, cellColor, math.huge)
      end

      return false
   end)
end)

spectrum.registerAnimation("Damage", function(value, color)
   local startColor = color or COLOR_DAMAGE
   local lighterColor = startColor:copy()
   lighterColor.a = 0.6

   local lighestColor = startColor:copy()
   lighestColor.a = 0.3

   local on = { index = DAMAGE_BASE + value, color = startColor }
   local fade1 = { index = DAMAGE_BASE + value, color = lighterColor }
   local fade2 = { index = DAMAGE_BASE + value, color = lighestColor }

   return spectrum.Animation(
      { on, on, on, on, on, on, on, fade1, fade1, fade2 },
      0.10,
      "pauseAtEnd"
   )
end)

spectrum.registerAnimation("Notice", function(text, x, y)
   return spectrum.Animation(function(t, display)
      prism.logger.info("in notice animation")
      local totalDuration = 1.0
      local progress = math.min(t / totalDuration, 1.0)

      -- put a reload string where the mouse was clicked
      local color = prism.Color4.WHITE:copy()

      color.a = progress < 0.5 and 1.0 or (1 - (progress - 0.5) * 2)

      local mX, mY = display:getCellUnderMouse()

      if not x and not y then
         x = mX + 1
         y = mY
      end

      if text == "EMPTY" then
         display:put(x + 0, y, EMPTY_BASE, color)
         display:put(x + 1, y, EMPTY_BASE + 1, color)
         display:put(x + 2, y, EMPTY_BASE + 2, color)
      elseif text == "RELOAD" then
         display:put(x + 0, y, RELOAD_BASE, color)
         display:put(x + 1, y, RELOAD_BASE + 1, color)
         display:put(x + 2, y, RELOAD_BASE + 2, color)
      end


      if progress >= 1.0 then
         return true
      else
         return false
      end
   end)
end
)

spectrum.registerAnimation("Laser", function(source, target, color, range)
   return spectrum.Animation(function(t, display)
      local x, y = source:decompose()
      local line, found = prism.Bresenham(x, y, target.x, target.y)
      local totalDuration = 0.3
      if not found then return true end

      local progress = math.min(t / totalDuration, 1.0)

      local curColor = color:copy()
      curColor.a = 1 - progress
      -- light up every cell in the line the same, intensity based on progress
      for i, p in ipairs(line) do
         local point = prism.Vector2(p[1], p[2])

         if point:getRange(source) > 0 and point:getRange(source) < range then
            display:putBG(point.x, point.y, curColor, math.huge)
            prism.logger.info("point: ", point, curColor)
         end
      end

      if progress >= 1 then
         return true
      else
         return false
      end
   end)
end
)

--- @param actor Actor
--- @param path Vector2[]
--- @param prediction boolean Whether the animation is being played for prediction purposes
--- @param impassablePos Vector2 Position where movement was stopped by an impassable object
spectrum.registerAnimation("Push", function(actor, path, prediction, impassablePos)
   -- prism.logger.info("calling path animation")

   if not prediction then
      prediction = false
   end

   local fullPath = {}
   for i, p in ipairs(path) do
      table.insert(fullPath, p)
   end

   local drawable = actor:get(prism.components.Drawable)

   return spectrum.Animation(function(t, display)
      -- display:overrideActor(actor)
      local stepDuration = 0.15

      display:push()


      local totalDuration = stepDuration * #path

      -- add an extra step if we hit a wall
      if impassablePos then
         prism.logger.info("adding extra step, ", totalDuration, " to ", totalDuration + stepDuration)
         totalDuration = totalDuration + stepDuration
      end



      -- prism.logger.info("totalDuration: ", totalDuration)

      if t >= totalDuration then
         -- drawable.layer = initialLayer
         -- handles the case when the actor is dead at this point
         -- display:unoverrideActor(actor)
         display:pop()

         return true
      end

      -- Calculate which step we're on
      local progress = t / totalDuration
      local currentStep = math.floor(progress * (#path + (impassablePos and 1 or 0))) + 1

      -- prism.logger.info("currentStep, maxStep, t, totalDuration", currentStep, #path, t, totalDuration)


      -- drawable.layer = -10000

      -- the problem is sometimes path is empty because the push is up against a wall
      -- so it would be ...
      local startX, startY = path[1]:decompose()
      local destX, destY = path[#path]:decompose()

      -- if #path == 0 then
      --    destX, destY = startX, startY
      -- end


      if currentStep > 0 and currentStep <= #path then
         local position = path[currentStep]


         prism.logger.info(" ANIMATE pushing to : ", position)
         if drawable then
            -- get the base cell and render that instead at high level
            -- part of what's awkward here is that this could be destination
            -- OR source. do we always move the actor first?
            -- in the case of prediction, the actor hasn't moved so it's source.
            -- in the case of the actual push it's the destination.
            -- local x, y = actor:getPosition():decompose()

            -- if not prediction then
            --    x = x - display.camera.x
            --    y = y - display.camera.y
            -- end

            -- local maxX = #display.cells
            -- prism.logger.info("push cells: ", x, y, prediction)

            -- local maxY = #display.cells[x]
            -- prism.logger.info(" ...y=", maxY)
            -- if the actor we're moving is outside SCREEN bounds, do nothing.

            -- this needs to be in screen terms, so we need to pull camera out
            local positionScreen = position:copy()
            positionScreen = positionScreen + display.camera
            if positionScreen.x <= 0 or positionScreen.y <= 0 or positionScreen.x > SCREEN_WIDTH or positionScreen.y > SCREEN_HEIGHT then
               display:pop()
               return false
            end

            local currentCell = display.cells[positionScreen.x][positionScreen.y]

            if currentCell and not prediction then
               -- this blanks the current cell. not totally sure why it's necessary. but
               -- it's not happening during prediction so it's not our issue.

               display:put(
                  position.x, position.y,
                  currentCell.char,
                  currentCell.fg,
                  currentCell.bg,
                  math.huge - 100
               )
            end


            -- if not prediction then
            --    destX = destX - display.camera.x
            --    destY = destY - display.camera.y
            -- end

            if destX + display.camera.x > SCREEN_WIDTH or destY + display.camera.y > SCREEN_HEIGHT or destX + display.camera.x <= 0 or destY + display.camera.y <= 0 then
               display:pop()
               return false
            end

            local destCell = display.cells[destX + display.camera.x][destY + display.camera.y]

            if destCell and not prediction then
               -- blank the destination because the actor has probably already been
               -- moved there. so get the cell there and redraw it over the actor
               prism.logger.info("blanking destination: ", destX, destY, destCell.char, destCell.fg, destCell.bg)
               display:put(
                  destX, destY,
                  destCell.char,
                  destCell.fg,
                  destCell.bg,
                  math.huge - 10
               )
            end

            -- this puts the actual actor drawable in position
            prism.logger.info("putting actual actor at ", position, " with pushed: ", display.pushed, " and camera ",
               display.camera)
            display:put(
               position.x,
               position.y,
               drawable.index,
               prediction and prism.Color4.GREY or drawable.color,
               drawable.background,
               math.huge
            )
         end
      else
         -- prism.logger.info("ANIMATE flash")
         -- we have stepDuration worth of time here, so let's
         -- split it into four chunks.
         local flashProgress = (t - (stepDuration * #path)) / stepDuration


         if flashProgress > 0 then
            local flashIndex = math.floor(flashProgress * 3) + 1
            local flashColor = flashIndex % 2 == 0 and prism.Color4.RED or prism.Color4.BLACK

            -- prism.logger.info("flashProgress: " ..
            -- tostring(flashProgress) ..
            -- ", flashIndex: " .. tostring(flashIndex) .. ", flashColor: " .. tostring(flashColor))
            local x, y = impassablePos:decompose()

            -- use full path because if there is no actual movement, then path will be empty.
            local impassableX, impassableY = fullPath[#fullPath]:decompose()

            -- if x > SCREEN_WIDTH or y > SCREEN_HEIGHT or x <= 0 or y <= 0 then
            --    prism.logger.info("pushing outside bounds")
            --    display:pop()

            --    return false
            -- end

            -- local cell = display.cells[x + display.camera.x][y + display.camera.y]
            -- local destCell = display.cells[impassableX + display.camera.x][impassableY + display.camera.y]

            -- if cell and destCell then
            -- flash the impasasble object that got hit
            display:putBG(
               impassablePos.x,
               impassablePos.y,
               -- cell.char,
               -- cell.fg,
               flashColor,
               math.huge
            )

            -- flash the final cell in the path
            display:putBG(
               destX,
               destY,
               -- drawable.index,
               -- prism.Color4.GREY,
               flashColor,
               math.huge
            )
            -- end
         end
      end

      display:pop()
      return false
   end)
end)

--- @param center Vector2
--- @param radius number
--- @param targetPoints Vector2[]? -- Optional mask of specific points to explode at
--- @param color Color4? -- Optional color for the explosion (defaults to orange)
spectrum.registerAnimation("Explode", function(center, radius, targetPoints, color)
   return spectrum.Animation(function(t, display)
      local totalDuration = 0.25
      local maxRadius = radius
      local waveWidth = 2.0

      local progress = math.min(t / totalDuration, 1.0)
      local currentRadius = progress * maxRadius

      if progress >= 1 then
         return true
      end

      -- If targetPoints is provided, create a lookup table for fast checking
      local pointMask = nil
      if targetPoints then
         pointMask = {}
         for _, point in ipairs(targetPoints) do
            local key = point.x .. "," .. point.y
            pointMask[key] = true
         end
      end

      -- Use provided color or default to bright orange
      local explosionColor = color or prism.Color4(1.0, 0.5, 0.1, 1.0)
      local blackColor = prism.Color4(0.0, 0.0, 0.0, 1.0)

      -- Draw the explosion area
      for dx = -maxRadius, maxRadius do
         for dy = -maxRadius, maxRadius do
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance <= maxRadius then
               local x = center.x + dx
               local y = center.y + dy

               -- Check if this point should be included
               local shouldExplode = true
               if pointMask then
                  local key = x .. "," .. y
                  shouldExplode = pointMask[key] == true
               end

               if shouldExplode then
                  -- Hard leading edge: bright orange wave
                  if distance <= currentRadius and distance >= currentRadius - waveWidth then
                     -- Calculate intensity based on position within wave
                     local wavePosition = (currentRadius - distance) / waveWidth
                     local intensity = math.max(0, math.min(1, wavePosition))

                     -- Add some randomness for organic look
                     local randomFactor = (math.random() * 0.2 + 0.9) -- 0.9 to 1.1
                     intensity = intensity * randomFactor

                     local finalColor = prism.Color4(
                        explosionColor.r,
                        explosionColor.g,
                        explosionColor.b,
                        intensity
                     )

                     display:putBG(x, y, finalColor, math.huge)

                     -- Soft trailing edge: fading to black behind the wave
                  elseif distance < currentRadius - waveWidth then
                     -- Calculate fade based on how far behind the wave we are
                     local fadeDistance = (currentRadius - waveWidth) - distance
                     local maxFade = waveWidth * 0.8
                     local fadeAmount = math.min(fadeDistance / maxFade, 1.0)

                     -- Fade from explosion color to black
                     local trailColor = prism.Color4(
                        explosionColor.r * (1 - fadeAmount),
                        explosionColor.g * (1 - fadeAmount),
                        explosionColor.b * (1 - fadeAmount),
                        0.8 + (fadeAmount * 0.2) -- Gradually become more opaque/black
                     )

                     display:putBG(x, y, trailColor, math.huge)
                  end
               end
            end
         end
      end

      return false
   end)
end)


spectrum.registerAnimation("SelfDestruct", function(turns)
   prism.logger.info(" in animation construction")
   return spectrum.Animation(function(t, display)
      -- display:push()
      prism.logger.info("in animation running ", t)
      -- do a put string, center screen that says
      -- "SELF DESTRUCTING IN N TURNS"
      -- "FIND AN EXIT QUICKLY"
      -- "SELF DESTRUCTING NOW"

      -- now our problem with text on the main display. I dont' want
      -- to make a whole new font for this.
      local duration = 1.5
      local progress = math.min(t / duration, 1.0)

      if progress >= 1 then
         -- display:pop()
         return true
      end

      local maxOffset = turns <= 0 and 6 or 7
      local turnsOffset = turns <= 0 and 0 or 6

      display:putFilledRect(9 - display.camera.x, 5 - display.camera.y, 10 + turnsOffset, 3, 3, prism.Color4.RED,
         prism.Color4.RED, math.huge)



      for i = 0, maxOffset do
         -- prism.logger.info("SELF_DESTRUCT_BASE + i", i)
         display:put(10 + i - display.camera.x, 6 - display.camera.y, SELF_DESTRUCT_BASE + i, prism.Color4.WHITE,
            prism.Color4.RED, math.huge)
      end

      if turns > 0 then
         -- display turns left
         local turnsOffset = 0
         if turns == 75 then
            turnsOffset = 1
         elseif turns == 50 then
            turnsOffset = 2
         elseif turns == 25 then
            turnsOffset = 3
         end

         display:put(10 + maxOffset + 2 - display.camera.x, 6 - display.camera.y,
            REMAINING_TURNS_BASE + turnsOffset,
            prism.Color4.WHITE,
            prism.Color4.RED, math.huge)

         for i = 0, 3 do
            display:put(10 + maxOffset + 3 + i - display.camera.x, 6 - display.camera.y,
               SELF_DESTRUCT_BASE + 8 + i,
               prism.Color4.WHITE,
               prism.Color4.RED, math.huge)
         end
      else
         display:put(10 + 7 - display.camera.x, 6 - display.camera.y, SELF_DESTRUCT_BASE + 11, prism.Color4.WHITE,
            prism.Color4.RED, math.huge)
      end

      -- display:pop()
      return false
   end)
end)
