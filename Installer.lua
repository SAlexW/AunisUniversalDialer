--[[
Creator: Ragog/SALexW
Installer ver: v1.0.0.0
]]--
 
 
local comp = require("component")
local serial = require("serialization")
local fsys = require("filesystem")
local shell = require("shell")
local term = require("term")
local gpu = comp.gpu
local wwweb = nil
local webconnect = comp.isAvailable("internet")
if webconnect then wwweb = require("internet") else io.stderr:write("No internet connection. Please install an Internet Card") os.exit(false) end
local type = false
 
function dircreate()
 if not fsys.isDirectory("/aurd") then
  local sccs, msg = fsys.makeDirectory("/aurd")
  if sccs == nil then
   io.stderr:write("ERROR: Failed to create directory")
   os.exit(false)
  end
 end
 selecttype()
end
 
function selecttype()
 print("Please select the device type for the program you are installing:")
 print("1 - Tablet, 2 - Computer/Server, Other - Cancel installation")
 local input = io.read()
 if (input == "1" or input == "2") then
  if input == "1" then type = true else type = false end
  download()
 else
 io.stderr:write("Instalation canceled")
 os.exit(false)
 end
end
 
function download()
 print("Downloading files...")
 if type then
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/Tablet.lua /aurd/AURD.lua -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/MWAS.ff /aurd/MWAS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/MWDS.ff /aurd/MWDS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/MWGS.ff /aurd/MWGS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/MWG.ff /aurd/MWG.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/PGAS.ff /aurd/PGAS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/PGDS.ff /aurd/PGDS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/PGGS.ff /aurd/PGGS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/PGG.ff /aurd/PGG.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/UNG.ff /aurd/UNG.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/GI.ff /aurd/GI.ff -fQ")
 else
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalRemoteDialer/main/PC.lua /aurd/AURD.lua -fQ") 
 end
local autorunFile = [[
local shell = require("shell")
do
shell.setWorkingDirectory("/aurd/")
shell.execute("AURD.lua")
end
]]
local file = io.open("/autorun.lua", "w")
file:write(autorunFile)
file:close()
print("Download completed.\n Please, restart your PC/Tablet.\n Programm will run automatically")
end
 
dircreate()
