spectrum.registerAnimation("Projectile", function(owner, targetPosition)
   --- @cast owner Actor
   --- @cast targetPosition Vector2
   local x, y = owner:expectPosition():decompose()
   local line = prism.Bresenham(x, y, targetPosition.x, targetPosition.y)

   return spectrum.Animation(function(t, display)
      local index = math.floor(t / 0.05) + 1

      if not line or #line == 0 then return true end
      
      display:put(line[index][1], line[index][2], "*", prism.Color4.ORANGE)

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

   prism.logger.info("DAMAGE ANIM FOR ", value)
   return spectrum.Animation(
      { on, on, on, on, on, on, on, fade1, fade2 },
      0.05,
      "pauseAtEnd"
   )
end)

--- @param center Vector2
--- @param radius number
spectrum.registerAnimation("Explode", function(center, radius)
   return spectrum.Animation(function(t, display)
      local totalDuration = 0.25
      local maxRadius = radius
      local waveWidth = 2.0

      local progress = math.min(t / totalDuration, 1.0)
      local currentRadius = progress * maxRadius

      if progress >= 1 then
         return true
      end

      -- Single bright orange color for the wave
      local orangeColor = prism.Color4(1.0, 0.5, 0.1, 1.0)
      local blackColor = prism.Color4(0.0, 0.0, 0.0, 1.0)

      -- Draw the explosion area
      for dx = -maxRadius, maxRadius do
         for dy = -maxRadius, maxRadius do
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance <= maxRadius then
               local x = center.x + dx
               local y = center.y + dy

               -- Hard leading edge: bright orange wave
               if distance <= currentRadius and distance >= currentRadius - waveWidth then
                  -- Calculate intensity based on position within wave
                  local wavePosition = (currentRadius - distance) / waveWidth
                  local intensity = math.max(0, math.min(1, wavePosition))

                  -- Add some randomness for organic look
                  local randomFactor = (math.random() * 0.2 + 0.9) -- 0.9 to 1.1
                  intensity = intensity * randomFactor

                  local finalColor = prism.Color4(
                     orangeColor.r,
                     orangeColor.g,
                     orangeColor.b,
                     intensity
                  )

                  display:putBG(x, y, finalColor, math.huge)

                  -- Soft trailing edge: fading to black behind the wave
               elseif distance < currentRadius - waveWidth then
                  -- Calculate fade based on how far behind the wave we are
                  local fadeDistance = (currentRadius - waveWidth) - distance
                  local maxFade = waveWidth * 0.8
                  local fadeAmount = math.min(fadeDistance / maxFade, 1.0)

                  -- Fade from orange to black
                  local trailColor = prism.Color4(
                     orangeColor.r * (1 - fadeAmount),
                     orangeColor.g * (1 - fadeAmount),
                     orangeColor.b * (1 - fadeAmount),
                     0.8 + (fadeAmount * 0.2) -- Gradually become more opaque/black
                  )

                  display:putBG(x, y, trailColor, math.huge)
               end
            end
         end
      end

      return false
   end)
end)
