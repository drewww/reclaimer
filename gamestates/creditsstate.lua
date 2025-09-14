--- @class CreditsState : GameState
--- @field display Display
--- @field previousState GameState|nil
--- @overload fun(previousState?: GameState): CreditsState
local CreditsState = spectrum.GameState:extend("CreditsState")

function CreditsState:__new(previousState)
   self.previousState = previousState

   local cp437Atlas = require "display.cp437_atlas"

   self.display = spectrum.Display(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2, cp437Atlas, prism.Vector2(16, 16))
   self.display:fitWindowToTerminal()

   -- Load credits image
   self.creditsImage = love.graphics.newImage("display/images/credits_title.png")

   self.controls = spectrum.Input.Controls {
      controls = {
         restart = { "r" },
         quit = { "q" },
         back = { "escape" },
         credits = { "c" }
      }
   }
end

function CreditsState:draw()
   self.display:clear()

   self.display:draw()

   -- Draw credits image
   love.graphics.draw(self.creditsImage, 0, 0)
end

function CreditsState:update(dt)
   self.controls:update()

   if self.controls.restart.pressed then
      if love.getVersion() >= 12 then
         love.event.restart()
      else
         love.event.quit("restart")
      end
   end

   if self.controls.quit.pressed then
      love.event.quit()
   end

   if self.controls.back.pressed then
      -- Return to previous state, or title if none provided
      if self.previousState then
         self.manager:enter(self.previousState)
      end
   end
end

return CreditsState
