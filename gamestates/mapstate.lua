local keybindings = require "keybindingschema"
local levelgen    = require "levelgen.levelgen"

-- Lightweight adapter to fix MapBuilder's getCell method
local function makeDisplayable(mapBuilder)
   return {
      getCell = function(self, x, y)
         local cell = mapBuilder:getCell(x, y)
         -- If we got a factory function, call it to get the actual cell
         if type(cell) == "function" then
            return cell()
         end
         return cell
      end,
      query = function(self, ...)
         return mapBuilder:query(...)
      end
   }
end

--- @class MapState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local MapState = spectrum.GameState:extend("MapState")
local Game     = require "game"

function MapState:__new(display)
   self.display = display
   self.builder = self:newBuilder()
end

function MapState:draw()
   self.display:clear()
   self.display:putLevel(makeDisplayable(self.builder))
   self.display:draw()
end

function MapState:keypressed(key, scancode, isrepeat)
   local action = keybindings:keypressed(key, "title")

   if action == "generate" then
      -- now put this in the display
      self.builder = self:newBuilder()
   elseif action == "quit" then
      love.event.quit()
   end
end

function MapState:newBuilder()
   local player = prism.actors.Player()
   return levelgen(prism.RNG(tostring(os.time())), player, 81, 41)
end

return MapState
