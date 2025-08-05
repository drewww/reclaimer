--- @diagnostic disable-next-line
function love.conf(t)
    t.window.vsync = 0 -- Enable vsync (1 by default)
    t.window.width = 960
    t.window.height = 540
    t.window.title = "exterminator"
    t.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.usedpiscale = false -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    t.version = "12.0"           -- The LÖVE version this game was made for (string)
    -- Other configurations...
end
