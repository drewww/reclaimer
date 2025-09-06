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

spectrum.registerAnimation("Damage", function(value)
   local startColor = prism.Color4.RED
   local lighterColor = startColor:copy()
   lighterColor.a = 0.6

   local lighestColor = startColor:copy()
   lighestColor.a = 0.3

   local on = { index = tostring(value), color = startColor }
   local fade1 = { index = tostring(value), color = lighterColor }
   local fade2 = { index = tostring(value), color = lighestColor }

   return spectrum.Animation(
      { on, on, on, on, on, on, on, fade1, fade2 },
      0.05,
      "pauseAtEnd"
   )
end)

spectrum.registerAnimation("Laser", function(source, target, color)
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

         if point:getRange(source) > 0 then
            display:putBG(point.x, point.y, curColor, math.huge)
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
