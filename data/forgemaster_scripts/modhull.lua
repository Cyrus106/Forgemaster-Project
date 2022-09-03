--Utility functions, will likely be built into Hyperspace in one form or another. Replace with standardized version later.

--IT WILL BE A LOT EASIER TO READ THIS WITH A LUA FORMATTING PACKAGE

--Line comment
--[[
Block comment

]]
--Useful Trick:

--[[
This forms a block commment
--]]

---[[This forms two line comments, so anything in between will not be commented out

--]]
mods.Forgemaster={} --[[
                        It's important to keep our values, functions,
                        and other data saved in a table specific to our mod,
                        to prevent conflicts with other mods that might use similar names.

                        This means we can use names like "Damage" and "Scrap"
                        without worrying that they are common terms.
                        It's still necessary to keep our OWN values seperate though!
                        ]]
mods.Forgemaster.Utility={} --For functions that make life easier, will be moved to another file later
mods.Forgemaster.Utility.randomInt=function(min,max)
  if math.floor(min)~=min or math.floor(max)~=max then --Checking for some easy-to-predict mistakes...
    error("randomInt function recieved non-integer inputs!") --so we can give a helpful error message when they occur!
  end
  if max<min then
    error("randomInt function error: max is less than min!")
  end
  return (Hyperspace.random32() % (max-min+1)) + min
  --[[Hyperspace.random32() returns a random 32 bit integer.
      "%" is the modulo operation. Doing A % B means you get the remainder of A/B as a result
          For example,
          951%100=51
          7%5=2
          12%3=0
        ]]
end



--Overcharmed
script.on_game_event("FMCORE_ONDAMAGE",false,
function()--[[You can declare a function inside of script hooks like this,
  which is usually better if you don't need to deal with any variables external to the function]]
  local damageQuantity=Hyperspace.ships.player:HasEquipment("FM_HULL_UPGRADE_POINTS")-15--This checks a req, in this case a variable.
  --"local" means that the variable stays within the scope of the function, and goes away after the function is over. Remember to use locals whenever possible!
  local damage=Hyperspace.Damage() --The constructor for a Damage argument,
  damage.fireChance = 5 --Set the parameters of the damage like this, just like with a weapon.
  damage.breachChance = 10
  for i =1,damageQuantity do --This is iteration, so if you want to do something multiple times you do it like this.
                              --If we wanted, we could use "i" as an argument, so each loop does something different.
    local roomCenter =  Hyperspace.ships.player:GetRandomRoomCenter() --this returns a value of type "Pointf" which has an x and y value. You can access the x and y values like "roomCenter.x" and "roomCenter.y"
    Hyperspace.ships.player:DamageArea(roomCenter, damage, true) --This applies the damage we set up earlier to the position we generated on the previous line. The "True" value might mean that you will still be damaged while jumping, but it might mean something else.
  end
end
) --Could be changed to trigger on an event queued from FMCORE_ONDAMAGE if that feels more organized

--Murals
script.on_game_event("FMCORE_ONDAMAGE",false,
function()
  local augValue=Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_HULL_MURAL") --This will get the value of an augmentation. If you have many of the augment that you pass to the function, it will take the sum of their values.
                                                                                      --This works with both the <value> tag in the augBlueprint, AND with custom hyperspace augs that use the <function> syntax. VERY useful for custom augments.
  local guaranteedDamage=math.floor(augValue)
  local damage=Hyperspace.Damage()
  damage.iDamage=1
  for i=1,guaranteedDamage do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRandomRoomCenter(), damage, true)--You can also pass the Pointf argument directly, but readability is important!
  end
  local damageChance=math.floor((augValue%1)*100)
  local randomNumber=Hyperspace.random32()%100
  if randomNumber<=damageChance then
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRandomRoomCenter(), damage, true)
  end

end
)
--Self Arm (Twisted Rock)
mods.Forgemaster.selfArm={--Here, we will be using a lot of the same values together, so they're all going to be in a table.
    queuedScrap=0,--a table can hold numbers,
    counterFrame=Hyperspace.Resources:CreateImagePrimitiveString(--custom data types,
                "statusUI/rage_counter.png",
                373,--x
                 42,--y (This box will not shift like normal variable boxes because the position is predefined. This is mostly for example purposes.)
                  0,
                  Graphics.GL_Color(1, 1, 1, 1.0),
                1.0,
                false),
    render=function(self)--and even functions! by having (self) as an argument, the function will be able to access the other values in its table
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM")~=0 then--HasAugmentation returns a number that tells you how many of the augment you have. ~= means "not equals".
                                                                              --We could also use > (greater than) because this function does not return negative values
          Graphics.CSurface.GL_RenderPrimitive(self.counterFrame)--Here we are passing the "counterFrame" parameter to our function. This is useful because we don't have to worry about this variable affecting other functions
          Graphics.freetype.easy_printCenter(0,424,58,string.format("%i",self.queuedScrap))    --string.format formats it as an integer ("%i" argument)
          --The first argument is the font type, the next arguments are the x and y positions. The final argument is the text to render
      end
    end,

    onDamage=function(self)
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM")~=0 then
        local scrapGain=mods.Forgemaster.Utility.randomInt(10,20)
        self.queuedScrap=self.queuedScrap+scrapGain
      end
    end,


    redeem=function(self)
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM")~=0 then
        Hyperspace.ships.player:ModifyScrapCount(self.queuedScrap,false)--"false" means this isn't affected by scrap arms
        self.queuedScrap=0
      end
    end,
}

script.on_render_event(Defines.RenderEvents.LAYER_PLAYER,
function() end,--Nothing happens before the render event (below the layer)
function()
  mods.Forgemaster.selfArm:render() --This is how you call a method with a "self" argument.
end)

script.on_game_event("FMCORE_ONDAMAGE",false,function() mods.Forgemaster.selfArm:onDamage() end)
script.on_game_event("FM_HULLKILL_TRACKER_EVENT",false,function() mods.Forgemaster.selfArm:redeem() end) --We can find a better check for kills later.
script.on_game_event("FM_CREWKILL_TRACKER_EVENT",false,function() mods.Forgemaster.selfArm:redeem() end)
