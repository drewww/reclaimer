return spectrum.Keybinding {
   { key = "w",      action = "move up",         description = "Moves the character upward." },
   { key = "a",      action = "move left",       description = "Moves the character left." },
   { key = "s",      action = "move down",       description = "Moves the character downward." },
   { key = "d",      action = "move right",      description = "Moves the character right." },
   { key = "q",      action = "move up-left",    description = "Moves the character diagonally up-left." },
   { key = "e",      action = "move up-right",   description = "Moves the character diagonally up-right." },
   { key = "z",      action = "move down-left",  description = "Moves the character diagonally down-left." },
   { key = "c",      action = "move down-right", description = "Moves the character diagonally down-right." },
   { key = "x",      action = "wait",            description = "Character waits and does nothing." },
   { key = "lshift", action = "dash",            description = "Move quickly." },
   { key = "rshift", action = "dash",            description = "Move quickly." },
   { key = "q",      mode = "title",             action = "quit",                                           description = "Quit the game." },
   { key = "p",      mode = "title",             action = "start",                                          description = "Start the game." },
   { key = "r",      mode = "title",             action = "restart",                                        description = "Restart the game." },
   { key = "g",      mode = "title",             action = "generate",                                       description = "Load the map generator state." },
   { key = "g",      mode = "map",               action = "generate",                                       description = "Generate a new map." }
}
