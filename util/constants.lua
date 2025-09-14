SCREEN_WIDTH = 31
SCREEN_HEIGHT = 20

WALL_COLLIDE_DAMAGE = 5
BARREL_EXPLODE_DAMAGE = 5

CHEST_DURATION = 10

DASH_ENERGY_COST_PER_TILE = 1

START_DEPTH = -9

MAX_TURNS_IN_LEVEL = 200

DEPTHS = {
   { enemyOdds = 0.3, weights = "basic",   weapons = {} },
   { enemyOdds = 0.4, weights = "basic",   weapons = { "shotgun" } },
   { enemyOdds = 0.5, weights = "basic",   weapons = { "shotgun" } },
   { enemyOdds = 0.3, weights = "barrels", weapons = { "shotgun" } },
   { enemyOdds = 0.4, weights = "barrels", weapons = { "shotgun", "laser" } },
   { enemyOdds = 0.5, weights = "barrels", weapons = { "laser" } },
   { enemyOdds = 0.5, weights = "end",     weapons = { "laser", "rocket" } },
   { enemyOdds = 0.7, weights = "end",     weapons = { "laser", "rocket" } },
   { enemyOdds = 0.9, weights = "end",     weapons = { "rocket" } },
}

-- sprite locations
PLAYER = 1
ENEMY = 2


DAMAGE_BASE = 15 * 16
EMPTY_BASE = 16 * 16 + 1
SELF_DESTRUCT_BASE = 16 * 16 + 4
RELOAD_BASE = 17 * 16 + 1
REMAINING_TURNS_BASE = 15 * 16 + 11

FLOOR_BASE = 10 * 16 + 1
FIRE_BASE = 14 * 16 + 1
WALL_BASE = 10 * 16 + 2
BARREL_BASE = 10 * 16 + 3



CHEST_BASE = 8 * 16 + 1
LOOT_BASE = 7 * 16 + 1
ROCKET_BASE = 11 * 16 + 1
BULLET_BASE = 12 * 16 + 1
AMMO = 13 * 16 + 1
GUN = 13 * 16 + 2
STAIRS = 13 * 16 + 3
BOT_HEAD = 5 * 16 + 1




-- these are for the BASE TILES sprites
HEART = 16 * 15 + 4 + 16 * 16
CENTS = 16 * 56 + 11 + 16 * 16
PUSH = 16 * 61 + 1 + 16 * 16
RANGE = 16 * 42 + 10 + 16 * 16
AMMO = 16 * 4 + 11 + 16 * 16

BLANK = 1 + 16 * 16
EXCLAMATION = 16 * 2 + 2
LIGHTNING = 16 * 23 + 4



-- COLORS
COLOR_TARGET = prism.Color4.RED
COLOR_DASH = prism.Color4(0.5, 0.5, 1.0, 1.0)
COLOR_PLAYER = prism.Color4.fromHex(0x10FF79)
COLOR_ENEMY = prism.Color4.fromHex(0xBB0408)
COLOR_DAMAGE = prism.Color4.fromHex(0xFF0000)
