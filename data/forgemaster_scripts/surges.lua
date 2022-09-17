script.on_game_event("TERMINUS_SURGE_AFTER",false,
function()
  local projectileCount=Hyperspace.ships.player.superBarrage:size()
  local deleteCount=0
  for i=0,projectileCount-1 do
    local position=Hyperspace.ships.enemy:GetRoomCenter(i)
    local projectile=Hyperspace.ships.player.superBarrage[i]
    if position.x==-1 then
      deleteCount=deleteCount+1
    else
      projectile.target=position
      projectile.speed_magnitude=1/0
      projectile:ComputeHeading()
    end
  end
  for i=1,deleteCount do
    Hyperspace.ships.player.superBarrage:pop_back()
  end
end)
