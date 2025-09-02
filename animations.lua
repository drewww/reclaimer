spectrum.registerAnimation("Projectile", function(owner, targetPosition)
   --- @cast owner Actor
   --- @cast targetPosition Vector2
   local x, y = owner:expectPosition():decompose()
   local line = prism.Bresenham(x, y, targetPosition.x, targetPosition.y)

   return spectrum.Animation(function(t, display)
      local index = math.floor(t / 0.05) + 1
      display:put(line[index][1], line[index][2], "*", prism.Color4.ORANGE)

      if index == #line then return true end

      return false
   end)
end)

spectrum.registerAnimation("BarrelExplode", function(owner)
   local centerX, centerY = owner:expectPosition():decompose()
   prism.logger.info("center: " .. tostring(owner:expectPosition()))

   return spectrum.Animation(function(t, display)
      local totalDuration = 0.5
      local maxRadius = 5

      local progress = math.min(t / totalDuration, 1.0)
      local currentRadius = progress * maxRadius

      if progress >= 1 then
         return true
      end

      local colors = {
         prism.Color4(1.0, 0.3, 0.0, 1.0), -- Bright orange/red center
         prism.Color4(1.0, 0.5, 0.1, 1.0), -- Orange
         prism.Color4(1.0, 0.7, 0.2, 1.0), -- Light orange
         prism.Color4(1.0, 0.8, 0.4, 1.0), -- Yellow-orange edge
         prism.Color4(1.0, 0.9, 0.6, 1.0), -- Faint yellow edge
      }

      for radius = 0, math.floor(currentRadius) do
         local colorIndex = math.min(radius + 1, #colors)
         local color = colors[colorIndex]

         -- Draw circle at this radius
         for dx = -radius, radius do
            for dy = -radius, radius do
               local distance = math.sqrt(dx * dx + dy * dy)

               -- Check if this point is within the current radius and roughly on the circle edge
               if distance <= currentRadius and distance >= radius - 0.7 then
                  local x = centerX + dx
                  local y = centerY + dy

                  -- Add some randomness for more organic look
                  local intensity = 1.0 - (distance / maxRadius) * 0.5
                  local randomFactor = (math.random() * 0.3 + 0.7) -- 0.7 to 1.0

                  local finalColor = prism.Color4(
                     color.r,
                     color.g,
                     color.b,
                     color.a * intensity * randomFactor
                  )

                  -- local offsetX, offsetY = display.camera:decompose()
                  local offsetX, offsetY = 0, 0
                  local displayX, displayY = x + offsetX, y + offsetY
                  -- prism.logger.info("radius: " ..
                  --    tostring(radius) .. " " ..
                  --    tostring(displayX) .. "," .. tostring(displayY) .. " color: " .. tostring(finalColor))
                  -- display:putBG(displayX, displayY, finalColor, math.huge) -- High layer to appear on top
                  display:putBG(displayX, displayY, finalColor, math.huge)
                  -- display:put(displayX, displayY, "B", finalColor)
               end
            end
         end
      end

      return false
   end)
end)
