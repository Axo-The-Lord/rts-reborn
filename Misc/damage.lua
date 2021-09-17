-- Damage Font and Numbers

NewDamageFont = graphics.fontFromSprite(Sprite.load("Misc/resources/font.png", 81, 0, 1), [[ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789/!”#¤%&()=?+-§@£$€{[]}\’*.,_<>^~¨ÜÏËŸ¿¡:;|]], -1, false)
export("NewDamageFont")

local damage = Object.new("FakeDamageNumbers")

damage:addCallback("create", function(this)
  local data = this:getData()
  this.alpha = 1
  this.sprite = Sprite.find("Empty")
  this.blendColor = Color.LIGHT_GRAY
  data.font = NewDamageFont
  data.text = "0"
  data.life = 30
  data.step = 1
  data.speed = 0.2
  data.alphaStep = 0.1
  data.parent = nil
end)
damage:addCallback("step", function(this)
  local data = this:getData()
  this.y = this.y - data.speed
  if data.life > 0 then
    data.life = data.life - data.step
  else
    this.alpha = this.alpha - data.alphaStep
    if this.alpha <= 0 then this:destroy() return end
  end
end)
damage:addCallback("draw", function(this)
  local data = this:getData()
  graphics.alpha(this.alpha)
  graphics.color(this.blendColor)
  graphics.print(data.text, this.x, this.y, data.font, graphics.ALIGN_MIDDLE, graphics.ALIGN_MIDDLE)
  graphics.alpha(1)
  graphics.color(Color.WHITE)
end)
