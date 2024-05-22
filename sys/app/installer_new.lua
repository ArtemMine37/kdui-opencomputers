local component = require("component")
local gpu = component.gpu
local fs = require("filesystem")
local e = require("event")
local t = require("term")
local c = require("computer")

local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ")

local function centerText(y, text, color)
    local x = math.floor(w / 2 - #text / 2)
    gpu.setForeground(color)
    gpu.set(x, y, text)
end

local function dirCheck(dir)
  if fs.exists(dir) and fs.isDirectory(dir) then
    print(dir.." exists. Skipping...")
  else
    print(dir.." does not exist. Creating...")
    fs.makeDirectory(dir)
  end
end

local function wgetDownload(link, destination)
  print("Downloading a file [to: " .. destination .. "]")
  os.execute("wget -f "..link.." "..destination.."")
end
-- New installer which has a simpler UI

local function installer()
  print("Welcome to the DenisUI Installer! Choose a DenisUI branch:")
  print(" [1]  DenisUI Stable")
  print(" [2]  DenisUI Unstable")
  print(" [3]  Custom (or fork)")
  -- Note: Custom one just runs your installer
  io.write("-> ")
  ver = io.read()
  if ver == "1" then
    install()
  elseif ver == "2" then
    install()
  end
end

local function install()
  -- Setting some variables
  -- Now installing
  print("    [Checking for directories]")
  dirCheck("/sys/apps")
  dirCheck("/sys/util")
  dirCheck("/sys/env")

  print("Creating reload file (KEEP EMPTY, THIS IS JUST TO RELOAD THE MAIN ENVIRONMENT)")
  os.execute("touch /sys/apps/reload.lua")
  
  print("    [Downloading DenisUI / Libraries]")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/lib/centerText.lua", "/lib/centertext.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/lib/desktopIcons.lua", "/lib/desktopicons.lua")
  
  print("    [Downloading DenisUI / Base]")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/env/main.lua", "/sys/env/main.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/app/file_manager.lua", "/sys/app/file_manager.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/app/updater.lua", "/sys/app/updater.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/app/installer.lua", "/sys/app/installer.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/util/term.lua", "/sys/util/term.lua")
  
  print("    [Installing DenisUI / Boot]")
    print("Replacing shell startup script...")
    fs.remove("/boot/94_shell.lua")
    wgetDownload("https://raw.githubusercontent.com/Tavyza/TherOS/main/sys/systempuller.lua", "/boot/94_bootloader.lua")
    print("Installation finished! A reboot is required to get the system set up. Would you like to reboot now?")
    io.write("y/n -> ")
    rb = io.read()
    if rb == "y" then
      c.shutdown(true)
    else
      os.exit()
    end
end

installer()


while true do
    local _, _, _, y, _, _ = e.pull("touch")
    local choice = math.floor((y - 3) / 2) + 1
    if choice == 1 then
        install()
        -- Currently the Placeholder(TM)
    elseif choice == 2 then
        break
    end
    installer()
end
