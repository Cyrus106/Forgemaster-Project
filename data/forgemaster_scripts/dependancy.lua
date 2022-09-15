
mods.Forgemaster={} --[[
                        It's important to keep our values, functions,
                        and other data saved in a table specific to our mod,
                        to prevent conflicts with other mods that might use similar names.

                        This means we can use names like "Damage" and "Scrap"
                        without worrying that they are common terms.
                        It's still necessary to keep our OWN values seperate though!
                        ]]


--A more intuitive way of making sure the player patches dependancies first.

script.on_load(
function()
  --Creating a global variable with our addon's information,
  --so that dependancies can be checked when the game loads
  _G["FORGEMASTER_INFO"]={
      version="0.4.1",
      }
  if not _G["INFERNO_CORE_INFO"] then
    Hyperspace.ErrorMessage("Warning! Inferno-Core was not patched before Forgemaster! Please re-patch your mods, or the game will not work!")
  end
end
)
