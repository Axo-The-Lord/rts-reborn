-- Vignette

local vignette = Object.new("Vignette")

local sprite = Sprite.load("Vignette", "Graphics/vignette.png", 1, 0, 0)

local DrawVignette = function(obj)
  local w, h = graphics.getHUDResolution()
  graphics.drawImage{
    image = sprite,
    alpha = obj.alpha,
    color = obj.blendColor,
    x = 0,
    y = 0,
    width = w,
    height = h
  }
end

callback.register("preHUDDraw", function()
  if not misc.hud:get("vignette") then
    local c = vignette:create(0, 0)
    c.depth = misc.hud.depth + 1
    c.alpha = 0
    misc.hud:set("vignette", c.id)
  end
  for _, v in ipairs(vignette:findAll()) do
    if v and v:isValid() then
      local data = v:getData()
      if v.alpha > 0 then
        v.alpha = v.alpha - data.rate
      end
      if misc.hud:get("show_skills") == 1 then
        DrawVignette(v)
      end
    end
  end
end)

vignette:addCallback("create", function(self)
  local data = self:getData()
  data.rate = 0.01
end)
