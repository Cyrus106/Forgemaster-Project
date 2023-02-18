mods.Forgemaster = {}
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
