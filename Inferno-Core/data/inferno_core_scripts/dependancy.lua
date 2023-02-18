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
