local errorScreen = Hyperspace.Resources:CreateImagePrimitiveString("misc/WrongPatch.png", -1280, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
local timer = 0

local timeToTroll = 5

script.on_render_event(Defines.RenderEvents.MAIN_MENU,
function()
  if shouldTroll then
    if timer <=  timeToTroll then
      timer = timer + Hyperspace.FPS.SpeedFactor / 16
    end
    local translation = (timer / timeToTroll) * 1280
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_Translate(translation, 0)
    Graphics.CSurface.GL_RenderPrimitive(errorScreen)
  end
end,
function()
  if shouldTroll then 
    Graphics.CSurface.GL_PopMatrix()
  end
end)