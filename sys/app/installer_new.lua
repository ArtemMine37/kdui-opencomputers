local component = require("component")
local gpu = component.gpu
local fs = require("filesystem")
local e = require("event")
local t = require("term")
local c = require("computer")

-- WARNING: the new update is coming...

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

function installer()
  print("Welcome to the DenisUI Installer! Choose a DenisUI branch:")
  print(" [1]  DenisUI Stable")
  print(" [2]  DenisUI Unstable") -- obv not working
  print(" [3]  Custom (or fork)") -- same as 2nd option
  -- Note: Custom one just runs your installer
  io.write("-> ")
  ver = io.read()
  if ver == "1" then
    installUi()
  elseif ver == "2" then
    installUi()
  end
end

function installUi()
  -- Setting some variables
  -- Now installing
  print("    [Checking for directories]")
  dirCheck("/sys/app")
  dirCheck("/sys/util")
  dirCheck("/sys/env")

  print("Creating reload file (KEEP EMPTY, THIS IS JUST TO RELOAD THE MAIN ENVIRONMENT)")
  os.execute("touch /sys/apps/reload.lua")

  local BaseLink="https://raw.githubusercontent.com/ArtemMine37/opencomputers-denisui/old-rel-1"
  
  print("    [Downloading DenisUI / Libraries]")
    wgetDownload(BaseLink.."/sys/lib/centerText.lua", "/lib/centerText.lua")
  
  print("    [Downloading DenisUI / Base]")
    wgetDownload(BaseLink.."/sys/env/main.lua", "/sys/env/main.lua")
    wgetDownload(BaseLink.."/sys/app/file_manager.lua", "/sys/app/FileManager.lua")
    wgetDownload(BaseLink.."/sys/app/updater.lua", "/sys/app/updater.lua")
    wgetDownload(BaseLink.."/sys/app/installer.lua", "/sys/app/installer.lua")
    wgetDownload(BaseLink.."/sys/app/term.lua", "/sys/app/Terminal.lua")
  
  print("    [Installing DenisUI / Boot]")
    print("Replacing shell startup script...")
    fs.remove("/boot/94_shell.lua")
    wgetDownload(BaseLink.."/sys/systempuller.lua", "/boot/94_shell.lua")
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
        installUi()
        -- Currently the Placeholder(TM)
    elseif choice == 2 then
        break
    end
    installer()
end
