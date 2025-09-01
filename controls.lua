return spectrum.Input.Controls {
   -- stylua: ignore
   controls = {
      move_upleft    = { "q", "y" },
      move_up        = { "w", "k" },
      move_upright   = { "e", "u" },
      move_left      = { "a", "h" },
      move_right     = { "d", "l" },
      move_downleft  = { "z", "b" },
      move_down      = { "s", "j" },
      move_downright = { "c", "n" },
      pickup         = { "p", "g" },
      wait           = { "x" },
      dash           = { "lshift", "rshift" },

      -- dash_upleft    = { "lshift q", "lshift y" },
      -- dash_up        = { "lshift w", "lshift k" },
      -- dash_upright   = { "lshift e", "lshift u" },
      -- dash_left      = { "lshift a", "lshift h" },
      -- dash_right     = { "lshift d", "lshift l" },
      -- dash_downleft  = { "lshift z", "lshift b" },
      -- dash_down      = { "lshift s", "lshift j" },
      -- dash_downright = { "lshift c", "lshift n" },

      weapon_1       = { "1" },
      weapon_2       = { "2" },
      weapon_3       = { "3" },
      weapon_4       = { "4" },
      weapon_5       = { "5" },
      weapon_6       = { "6" },
      weapon_7       = { "7" },
      weapon_8       = { "8" },
      weapon_9       = { "9" },


      play = { "p" }
   },
   pairs = {
      -- stylua: ignore
      move = {
         "move_upleft", "move_up", "move_upright",
         "move_left", "move_right",
         "move_downleft", "move_down", "move_downright"
      },

      -- dash = {
      --    "dash_upleft", "dash_up", "dash_upright",
      --    "dash_left", "dash_right",
      --    "dash_downleft", "dash_down", "dash_downright"
      -- }
   },
}

-- TODO merge the other modes over: title and map which have conflicting mappings and I'm not sure yet
-- how that should work.

-- { key = "lshift", action = "dash", description = "Move quickly." },
-- { key = "rshift", action = "dash", description = "Move quickly." },
-- { key = "q", mode = "title", action = "quit", description = "Quit the game." },
-- { key = "p", mode = "title", action = "start", description = "Start the game." },
-- { key = "r", mode = "title", action = "restart", description = "Restart the game." },
-- { key = "g", mode = "title", action = "generate", description = "Load the map generator state." },
-- { key = "g", mode = "map", action = "generate", description = "Generate a new map." }

-- return spectrum.Keybinding {
--    { key = "w", action = "move up",         description = "Moves the character upward." },
--    { key = "a", action = "move left",       description = "Moves the character left." },
--    { key = "s", action = "move down",       description = "Moves the character downward." },
--    { key = "d", action = "move right",      description = "Moves the character right." },
--    { key = "q", action = "move up-left",    description = "Moves the character diagonally up-left." },
--    { key = "e", action = "move up-right",   description = "Moves the character diagonally up-right." },
--    { key = "z", action = "move down-left",  description = "Moves the character diagonally down-left." },
--    { key = "c", action = "move down-right", description = "Moves the character diagonally down-right." },
--    { key = "x", action = "wait",            description = "Character waits and does nothing." },

-- }
