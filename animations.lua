spectrum.registerAnimation("Projectile", function(owner, targetPosition, char)
   --- @cast owner Actor
   --- @cast targetPosition Vector2
   local x, y = owner:expectPosition():decompose()
   local line = prism.Bresenham(x, y, targetPosition.x, targetPosition.y)

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

spectrum.registerAnimation("Damage", function(value)
   local startColor = prism.Color4.RED
   local lighterColor = startColor:copy()
   lighterColor.a = 0.6

   local lighestColor = startColor:copy()
   lighestColor.a = 0.3

   local on = { index = DAMAGE_BASE + value, color = startColor }
   local fade1 = { index = DAMAGE_BASE + value, color = lighterColor }
   local fade2 = { index = DAMAGE_BASE + value, color = lighestColor }

   return spectrum.Animation(
      { on, on, on, on, on, on, on, fade1, fade2 },
      0.05,
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
spectrum.registerAnimation("Push", function(actor, path, cameraAdjust)
   prism.logger.info("calling path animation")

   if not cameraAdjust then
      cameraAdjust = true
   end

   return spectrum.Animation(function(t, display)
      prism.logger.info("Push animation running")
      local stepDuration = 0.1
      local totalDuration = stepDuration * #path

      if t >= totalDuration then
         return true
      end

      -- Calculate which step we're on
      local progress = t / totalDuration
      local currentStep = math.min(math.floor(progress * #path) + 1, #path)

      if currentStep > 0 and currentStep <= #path then
         local position = path[currentStep]
         local drawable = actor:get(prism.components.Drawable)
         prism.logger.info(" ANIMATE pushing to : ", position)
         if drawable then
            -- get the base cell and render that instead at high level
            local x, y = actor:getPosition():decompose()

            if cameraAdjust then
               x = x - display.camera.x
               y = y - display.camera.y
            end

            -- local maxX = #display.cells
            prism.logger.info("push cells: ", x, y, cameraAdjust)

            -- local maxY = #display.cells[x]
            -- prism.logger.info(" ...y=", maxY)
            -- if the actor we're moving is outside SCREEN bounds, do nothing.
            if x > SCREEN_WIDTH or y > SCREEN_HEIGHT or x <= 0 or y <= 0 then
               prism.logger.info("pushing outside bounds")
               return false
            end

            local cell = display.cells[x][y]

            prism.logger.info("found cell: ", cell)

            if cell then
               display:put(
                  x, y,
                  cell.char,
                  cell.fg,
                  cell.bg,
                  math.huge - 100
               )
            end

            local destX, destY = path[#path]:decompose()
            destX = destX - display.camera.x
            destY = destY - display.camera.y

            if destX > SCREEN_WIDTH or destY > SCREEN_HEIGHT or destX <= 0 or destY <= 0 then
               return false
            end

            local destCell = display.cells[destX][destY]

            if destCell then
               display:put(
                  destX, destY,
                  destCell.char,
                  destCell.fg,
                  destCell.bg,
                  math.huge - 100
               )
            end

            display:put(
               position.x,
               position.y,
               drawable.index,
               drawable.color,
               drawable.background,
               math.huge
            )
         end
      end

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
