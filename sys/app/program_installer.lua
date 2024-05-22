local t = require("term")
local ct = require("centerText")
local e = require("event")

t.clear()

local function menu()
  local options = {"Install from Pastebin", "Install from external source"}
  t.clear()
  ct(1, "-- Program installer --", 0xFFFFFF)
  for i, options in ipairs(options) do
    ct(5 + (i - 1) * 2, options, 0xFFFFFF)
  end
end

local function pastebin()
  print("Enter PasteBin code")
  io.write("-> ")
  code = io.read()
  print("Enter file name (leave blank to keep original name)")
  name = io.read()
  os.execute("pastebin get " .. code .. " " .. name)
  os.exit()
end
local function github()
  print("Enter raw download link:")
  io.write("-> ")
  link = io.read()
  print("Enter file name (leave blank to keep original name)")
  gName = io.read()
  os.execute("wget " .. link .. " " .. gName)
  os.exit()
end


while true do
  menu()
  local _, _, _, y, _, _ = e.pull("touch")
  local choice = math.floor((y - 5) / 2) + 1
  if choice == 1 then
    pastebin()
  elseif choice == 2 then
    github()
  end
  menu()
end