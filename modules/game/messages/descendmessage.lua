--- @class DescendMessage : Message
--- @overload fun(): DescendMessage
local DescendMessage = prism.Message:extend("DescendMessage")

--- @param descender Actor
function DescendMessage:__new(descender)
   self.descender = descender
end

return DescendMessage
