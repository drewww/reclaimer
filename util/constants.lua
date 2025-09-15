SCREEN_WIDTH = 31
SCREEN_HEIGHT = 20

WALL_COLLIDE_DAMAGE = 4
PLAYER_WALL_COLLIDE_DAMAGE = 2
BARREL_EXPLODE_DAMAGE = 4

CHEST_DURATION = 10

DASH_ENERGY_COST_PER_TILE = 1

START_DEPTH = -9

MAX_TURNS_IN_LEVEL = 200

DEPTHS = {
   { enemyOdds = 0.3, weights = "basic",   walls = "rock",   weapons = {} },
   { enemyOdds = 0.4, weights = "basic",   walls = "rock",   weapons = { "shotgun" } },
   { enemyOdds = 0.5, weights = "basic",   walls = "rock",   weapons = { "shotgun" } },
   { enemyOdds = 0.3, weights = "barrels", walls = "circle", weapons = { "shotgun" } },
   { enemyOdds = 0.4, weights = "barrels", walls = "circle", weapons = { "shotgun", "laser" } },
   { enemyOdds = 0.4, weights = "barrels", walls = "circle", weapons = { "laser" } },
   { enemyOdds = 0.4, weights = "end",     walls = "none",   weapons = { "laser", "rocket" } },
   { enemyOdds = 0.4, weights = "end",     walls = "none",   weapons = { "laser", "rocket" } },
   { enemyOdds = 0.4, weights = "end",     walls = "none",   weapons = { "rocket" } },
}

-- Enemy type spawn odds per depth (must sum to 1.0)
ENEMY_SPAWN_ODDS = {
   { basic = 1.0, big = 0.0, boom = 0.0 },   -- Depth 1: Only basic enemies
   { basic = 1.0, big = 0.0, boom = 0.0 },   -- Depth 2: Mostly basic, some big
   { basic = 1.0, big = 0.0, boom = 0.0 },   -- Depth 3: More big enemies
   { basic = 0.8, big = 0.2, boom = 0.0 },   -- Depth 4: Introduce boom enemies
   { basic = 0.8, big = 0.2, boom = 0.0 },   -- Depth 5: More variety
   { basic = 0.7, big = 0.3, boom = 0.0 },   -- Depth 6: Balanced mix
   { basic = 0.5, big = 0.2, boom = 0.3 },   -- Depth 7: Fewer basic
   { basic = 0.5, big = 0.2, boom = 0.3 },   -- Depth 8: Mostly big/boom
   { basic = 0.3, big = 0.3, boom = 0.4 },   -- Depth 9: Final level - mostly dangerous
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
ARROW = 16 * 16 + 16


-- COLORS
COLOR_TARGET = prism.Color4(0.5, 0.5, 1.0, 0.8)
COLOR_DASH = prism.Color4.LIME
COLOR_PLAYER = prism.Color4.fromHex(0x10FF79)
COLOR_ENEMY = prism.Color4.fromHex(0xBB0408)
COLOR_DAMAGE = prism.Color4.fromHex(0xFF0000)
