require "debugger"
require "prism"

prism.loadModule("prism/spectrum")
prism.loadModule("prism/extra/sight")
prism.loadModule("prism/extra/log")
prism.loadModule("prism/extra/inventory")

prism.loadModule("modules/game")

-- Grab our level state and sprite atlas.
local MyGameLevelState = require "gamestates.gamelevelstate"

Game = require("game")

-- Load a sprite atlas and configure the terminal-style display,
local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 16, 16)
local display = spectrum.Display(81, 41, spriteAtlas, prism.Vector2(16, 16))

-- Automatically size the window to match the terminal dimensions
display:fitWindowToTerminal()

-- spin up our state machine
--- @type GameStateManager
local manager = spectrum.StateManager()

-- we put out levelstate on top here, but you could create a main menu
--- @diagnostic disable-next-line
function love.load()
    local builder = Game:generateNextFloor(prism.actors.Player())
    manager:push(MyGameLevelState(display, builder, Game:getLevelSeed()))
    manager:hook()
end

-- set up my custom turn logic

---@param level Level
---@param actor Actor
---@param controller Controller
---@diagnostic disable-next-line
function prism.turn(level, actor, controller)
    local continueTurn = false
    repeat
        local action = controller:act(level, actor)

        -- we make sure we got an action back from the controller for sanity's sake
        assert(action, "Actor " .. actor:getName() .. " returned nil from act()")

        level:perform(action)

        continueTurn = actor:has(prism.components.Dashing) and action.className == "Move"

        print("action class:", action.className)
        print("action prototype:", action.__class)
        print("prism.actions.Move:", prism.actions.Move)
        print("Are they the same?", action.__class == prism.actions.Move)
        print("Action type:", type(action))
        print("Move type:", type(prism.actions.Move))
    until not continueTurn
end
