

---[[

function renderframe(imagepath, framenumber, numberofframes, position_x, position_y)
  local tex=Hyperspace.Resources:GetImageId(imagepath)
  Graphics.CSurface.GL_BlitImagePartial(tex, position_x, position_y, (tex.width)/(numberofframes), tex.height, framenumber/numberofframes, (framenumber+1)/(numberofframes), 1, 0, 1, Graphics.GL_Color(1, 1, 1, 1), false)
end



function renderanim(imagepath, numberofframes, position_x, position_y, seconds)
  if mods.vals.animbool then

    animtimer_seconds = (animtimer_seconds or 0) + (Hyperspace.FPS.SpeedFactor / 16)
    local framenumber=math.floor((animtimer_seconds*numberofframes)/seconds)

    local tex=Hyperspace.Resources:GetImageId(imagepath)
    local frame_width = (tex.width)/(numberofframes)
    local frame_height = tex.height
    local start_x = framenumber/numberofframes
    local end_x = (framenumber+1)/(numberofframes)
    local start_y = 1
    local end_y = 0
    local alpha = 1
    local color = Graphics.GL_Color(1, 1, 1, 1)
    local mirror = false

    Graphics.CSurface.GL_BlitImagePartial(tex, position_x, position_y, frame_width, frame_height, start_x, end_x, start_y, end_y, alpha, color, mirror)
    if animtimer_seconds > seconds then
        animtimer_seconds = nil
        mods.vals.animbool = false
    end
  end
end



function biganim(imagepath, numberofframes, frame_width, frame_height, position_x, position_y, seconds)
  if mods.vals.animbool then

    animtimer_seconds = (animtimer_seconds or 0) + (Hyperspace.FPS.SpeedFactor / 16)
    local framenumber=math.floor((animtimer_seconds*numberofframes)/seconds)

    local tex=Hyperspace.Resources:GetImageId(imagepath)

    local framesperrow=tex.width/frame_width
    local rows=tex.height/frame_height

    local current_row = math.floor(framenumber/framesperrow)
    local current_column = framenumber % framesperrow

    local start_x = current_column/framesperrow
    local end_x = (current_column+1)/(framesperrow)
    local start_y = ((current_row)/(rows))
    local end_y = ((current_row+1)/(rows))
    local alpha = 1
    local color = Graphics.GL_Color(1, 1, 1, 1)
    local mirror = false

    Graphics.CSurface.GL_BlitImagePartial(tex, position_x, position_y, frame_width, frame_height, start_x, end_x, start_y, end_y, alpha, color, mirror)
    if animtimer_seconds > seconds then
        animtimer_seconds = nil
        mods.vals.animbool = false
    end
  end
end







function newthing()
    if mods.vals.animbool then
      for i=0,25 do
        local room=Hyperspace.ships.enemy:GetRoomCenter(i)
        renderanim("effects/explosion_ancalagon_breach.png",14,room.x,room.y,10)
      end
    end
end


function morb()
  mods.vals.animbool = true
end

function big()
  if mods.vals.animbool then
    biganim("weapons_behemoth/big_boi.png",173, 132, 527, 500, 200, 10)
  end
end
script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, nothing, big)
--]]
