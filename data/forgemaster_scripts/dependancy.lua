mods.Forgemaster = {}
  --Creating a global variable with our addon's information,
  --so that dependancies can be checked when the game loads
FORGEMASTER_INFO = {
  VERSION = {
    MAJOR = 0,
    MINOR = 5,
    FEATURE = 0,
  },
}
if not INFERNO_CORE_INFO then 
  error("Warning! Inferno-Core was not patched before Forgemaster! Please re-patch your mods, or the game will not work!") 
end

