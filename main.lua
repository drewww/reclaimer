require "debugger"
require "prism"

require "animations"

require "util.constants"

prism.loadModule("prism/spectrum")
prism.loadModule("prism/extra/sight")
prism.loadModule("prism/extra/log")
prism.loadModule("prism/extra/inventory")

prism.Collision.registerMovetype("walk", "movetypes0")
prism.Collision.registerMovetype("fly", "movetypes1")

prism.logger.info(" done registering move types ")

prism.loadModule("modules/game")

prism.defaultCell = prism.cells.Pit

-- Grab our level state and sprite atlas.
local GameLevelState = require "gamestates.gamelevelstate"
local TitleState = require "gamestates.titlestate"

local Game = require("game")
local cp437Map = require "display.reclaimer_tiles_map"

-- Load a sprite atlas and configure the terminal-style display,
-- local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 16, 16)

-- prism.logger.level = "debug"
prism.logger.info("Loaded TILE MAP: " .. #cp437Map .. " entries")
-- prism.logger.info(" location of `A`: " .. cp437Map[1150])

local spriteAtlas = spectrum.SpriteAtlas.fromGrid("display/reclaimer_tiles.png", 32, 32, cp437Map)
local display = spectrum.Display(41, 25, spriteAtlas, prism.Vector2(32, 32))

-- Automatically size the window to match the terminal dimensions
display:fitWindowToTerminal()

-- spin up our state machine
--- @type GameStateManager
local manager = spectrum.StateManager()

-- we put out levelstate on top here, but you could create a main menu
--- @diagnostic disable-next-line
function love.load()
   manager:push(TitleState(display))
   manager:hook()
   spectrum.Input:hook()
end
