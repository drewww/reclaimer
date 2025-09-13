local levelgen = require "levelgen.levelgen"
local Stats = require "modules.game.stats"

--- @class Game : Object
--- @field depth integer
--- @field rng RNG
--- @field stats Stats
--- @overload fun(seed: string): Game
local Game = prism.Object:extend("Game")

--- @param seed string
function Game:__new(seed, player)
   self.depth = START_DEPTH
   self.rng = prism.RNG(seed)
   self.stats = Stats()
   self.player = player
end

--- @return string
function Game:getLevelSeed()
   return tostring(self.rng:random())
end

--- @param player Actor
--- @return LevelBuilder builder
function Game:generateNextFloor()
   local genRNG = prism.RNG(self:getLevelSeed())
   return levelgen(self.depth, genRNG, self.player, 35, 35)
end

return Game(tostring(os.time()))
