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
