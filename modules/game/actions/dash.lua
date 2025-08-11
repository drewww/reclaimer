--- @class Dash : Action
local Dash = prism.Action:extend("Dash")

function Dash:perform(level)
   if self.owner:has(prism.components.Dashing) then
      self.owner:remove(prism.components.Dashing)

      -- now look up all the cells that have dashing and remove them as well.
      for cellX, cellY, cell in level:eachCell() do
         if cell:has(prism.components.Dashing) then cell:remove(prism.components.Dashing) end
      end
   else
      self.owner:give(prism.components.Dashing())

      local cell = level:getCell(self.owner:getPosition():decompose())
      if cell then cell:give(prism.components.Dashing()) end
   end
end

return Dash
