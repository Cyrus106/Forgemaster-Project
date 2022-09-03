script.on_load(
function()
  --Creating a global variable with our addon's information,
  --so that dependancies can be checked when the game loads
  _G["INFERNO_CORE_INFO"]={
      version="0.5",--No idea what number to put here
      }
  if _G["FORGEMASTER_INFO"] then
    Hyperspace.ErrorMessage("Forgemaster was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
  end
end
)
