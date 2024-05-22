local component = require("component")
local gpu = component.gpu
local fs = require("filesystem")
local e = require("event")
local t = require("term")
local keyboard = require("keyboard")
local centerText = require("centerText")

local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ")

local function listFiles(currentPath)
    local files = {"../", "./"}
    for file in fs.list(currentPath) do
        table.insert(files, file)
    end
    return files
end

local function displayFiles(files, currentPath)
    t.clear()
    gpu.fill(1, 1, w, h, " ")
    centerText(1, "File Manager - " .. currentPath, 0xFFFFFF)
    for i, file in ipairs(files) do
        if fs.isDirectory(currentPath .. file) or file == "../" or file == "./" then
          color = 0x0000FF
        else
          color = 0x00FF00
        end
        centerText(3 + (i - 1) * 1, file, color)
    end
end

local function getFullPath(currentPath, file)
    if file == "../" then
        return fs.path(currentPath)
    elseif file == "./" then
        return currentPath
    else
        return fs.concat(currentPath, file)
    end
end

local currentPath = "/"
optionsDisplayed = false

local function displayCloseButton()
    local closeButton = "Close"
    centerText(h - 1, closeButton, 0xFFFFFF)
end

while true do
    ::loop::
    local files = listFiles(currentPath)
    displayFiles(files, currentPath)
    displayCloseButton()

    local _, _, _, y, _, _ = e.pull("touch")
    if y >= h - 1 then
        break
    end
    local choice = math.floor((y - 3) / 1) + 1

    if choice >= 1 and choice <= #files and not optionsDisplayed then
        local selectedFile = getFullPath(currentPath, files[choice])
        print(selectedFile)
        if fs.isDirectory(selectedFile) then
          if keyboard.isKeyDown(0x2A) == true then
            optionsDisplayed = true
            local options = {"Open", "Copy", "Delete"}
            local optionSpacing = 2
            local startLine = h / 2 - (#options * optionSpacing) / 2
            for i, option in ipairs(options) do
              centerText(startLine + (i - 1) * optionSpacing, option, 0xFFFFFF)
            end
            local _, _, _, yOption, _, _ = e.pull("touch")
            local option = math.floor((yOption - startLine) / optionSpacing) + 1
            print("Selected option: " .. option)

            if option == 1 then
              print("Opening directory")
              currentPath = selectedFile
            elseif option == 2 then
              print("Where would you like to copy this directory? This will copy all files within it.")
              io.write("LOCATION -> ")
              copDes = io.read()
              fs.copy(selectedFile, copDes)
            elseif option == 3 then
              print("Are you sure you want to delete this directory? This will also remove all items inside of it!")
              io.write("y/n -> ")
              confirm = io.read()
              if confirm == "y" then
                fs.remove(selectedFile)
              else
                print("Removal cancelled")
              end
              optionsDisplayed = false
            end
          else
          currentPath = selectedFile
          end
        else
            optionsDisplayed = true
            local options = {"Run", "Edit", "Delete", "Move/Rename", "Copy", "Cancel"}
            local optionSpacing = 2
            local startLine = h / 2 - (#options * optionSpacing) / 2
            for i, option in ipairs(options) do
                centerText(startLine + (i - 1) * optionSpacing, option, 0xFFFFFF)

            end

            local _, _, _, yOption, _, _ = e.pull("touch")

            local option = math.floor((yOption - startLine) / optionSpacing) + 1
            print("Selected option: " .. option)

            if option == 1 then
                print("Executing file: " .. selectedFile) -- Debug print
                os.execute(selectedFile)
            elseif option == 2 then
                print("Editing file: " .. selectedFile) -- Debug print
                os.execute("edit " .. selectedFile)
            elseif option == 3 then
                print("Delete " .. selectedFile) -- Debug print
                print("Are you sure you want to remove this file?")
                io.write("y/n -> ")
                if io.read() == "y" then
                    os.execute("rm " .. selectedFile)
                else
                    print("File not deleted.")
                end
            elseif option == 4 then
                print("Enter new path/name: ") -- Debug print
                local newPath = io.read()
                print("Moving/renaming to: " .. newPath) -- Debug print
                os.execute("mv " .. selectedFile .. " " .. newPath)
            elseif option == 5 then
                print("Enter copy destination: ") -- Debug print
                local copdes = io.read()
                print("Copying to: " .. copdes) -- Debug print
                os.execute("cp " .. selectedFile .. " " .. copdes)
            end
            optionsDisplayed = false
        end
    else
      optionsDisplayed = true
      local options = {"New file", "New directory"}
      local optionSpacing = 2
      local startLine = h / 2 - (#options * optionSpacing) / 2
      for i, option in ipairs(options) do
        centerText(startLine + (i - 1) * optionSpacing, option, 0xFFFFFF)
      end

      local _, _, _, yOption, _, _ = e.pull("touch")
      local option = math.floor((yOption - startLine) / optionSpacing) + 1
      print("Selected option " .. option)
      if option == 1 then
        print("New file name (INCLUDE EXTENTION)")
        io.write("-> ")
        newFile = io.read()
        os.execute("touch " .. currentPath .. "/" .. newFile)
      elseif option == 2 then
        print("New directory name")
        io.write("-> ")
        newDir = io.read()
        os.execute("mkdir " .. currentPath .. "/" .. newDir)
        -- os.sleep(2) debug
      end
      optionsDisplayed = false                
    end
end