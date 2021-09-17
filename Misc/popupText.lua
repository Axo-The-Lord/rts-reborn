-- Pop-up Text

PopUpText = {}
local textCount = 0

local _textObject = Object.new("Text")
_textObject:addCallback("create", function(self)
  self:set("life", 60)
  self:set("text", "???")
  self:set("movement", 0)
  self:set("alpha", 1)
end)
_textObject:addCallback("draw", function(self)
  if self:get("life") <= 0 and self:get("alpha") > 0 then
    self:set("alpha", self:get("alpha") - 0.05)
  end
  graphics.alpha(self:get("alpha"))
  graphics.color(Color.fromRGB(255, 255, 255))
  graphics.printColor(self:get("text"), self.x - (graphics.textWidth(self:get("text"), graphics.FONT_DEFAULT) / 2), self.y - (graphics.textWidth(self:get("text"), graphics.FONT_DEFAULT) / 2))
end)
_textObject:addCallback("step", function(self, player)
  self:set("life", self:get("life") - 1)
  self:set("movement", self:get("movement") - 1)
  if self:get("alpha") <= 0 then
    self:destroy()
  return
  else
    if self:get("movement") <= 0 then
      self.y = self.y - 1
    end
  end
end)

PopUpText.new = function(text, life, movement, x, y)
  local t = _textObject:create(x, y)
  t:set("text", text)
  t:set("life", life)
  t:set("movement", movement)
  return t
end


export("PopUpText")
return PopUpText
