INFERNO_CORE_INFO = {
  VERSION = {
    MAJOR = 0,
    MINOR = 6,
    FEATURE = 0,
  },
}
if FORGEMASTER_INFO then
  shouldTroll = true
   error("Forgemaster was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!") 
end

if TCC_INFO then
  shouldTroll = true
  error("Trash Compactor Collection was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
end

if CNC_WEAPONS_INFO then
  shouldTroll = true
  error("C&C Weapons was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
end

if BAG_OF_DUMB_INFO then
  shouldTroll = true
  error("Bag of Dumb was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!") 
end