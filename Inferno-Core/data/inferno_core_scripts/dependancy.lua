INFERNO_CORE_INFO = {
  VERSION = {
    MAJOR = 0,
    MINOR = 5,
    FEATURE = 0,
  },
}
if FORGEMASTER_INFO then
   error("Forgemaster was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!") 
end

if TCC_INFO then
  error("Trash Compactor Collection was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
end

if CNC_WEAPONS_INFO then
  error("C&C Weapons was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
end

if BAG_OF_DUMB_INFO then
  error("Bag of Dumb was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!") 
end