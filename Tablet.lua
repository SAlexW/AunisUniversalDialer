--libraries--
local comp = require("component")
local event = require("event")
local pc = require("computer")
local gpu
if (comp.isAvailable("gpu")) then
 gpu = comp.gpu
 if(gpu.maxDepth() < 4) then
 gpu.set(1,10,"Please, install Graphics Card tier 2 or higher") 
 pc.beep(40, 0.5)
 pc.beep(40, 0.5)
 os.sleep(2)
 os.exit(false)
 end
else
pc.beep(40, 1)
os.exit(false)
end
local modem
local mod = comp.isAvailable("modem")
if (mod) then
 modem = comp.modem
 if(comp.modem.isWireless() == false) then
 pc.beep(40, 0.5)
 pc.beep(40, 0.5)
 gpu.set(1,10,"Please, install Wireless Card level 2")
 os.sleep(2) 
 os.exit(false)
 elseif (comp.modem.setStrength(400) == 16) then
 pc.beep(40, 0.5)
 pc.beep(40, 0.5)
 gpu.set(1,10,"Please, install Wireless Card level 2")
 os.sleep(2) 
 os.exit(false)
 end
else
pc.beep(40, 1)
os.exit(false)
end
local term = require("term")
local serial = require("serialization")
local math = require("math")
local string = require("string")
--libraries--

--global variables--
local iomessage = ""
local iocheck = true
local iolength = 0
local unf = {"Glyph 1", "Glyph 2", "Glyph 3", "Glyph 4", "Glyph 5", "Glyph 6", "Glyph 7", "Glyph 8", "Glyph 9", "Glyph 10", "Glyph 11", "Glyph 12", "Glyph 13", "Glyph 14", "Glyph 15", "Glyph 16", "Glyph 17", "Glyph 18", "Glyph 19", "Glyph 20", "Glyph 21", "Glyph 22", "Glyph 23", "Glyph 24", "Glyph 25", "Glyph 26", "Glyph 27", "Glyph 28", "Glyph 29", "Glyph 30", "Glyph 31", "Glyph 32", "Glyph 33", "Glyph 34", "Glyph 35", "Glyph 36"}
local pgf = {"Acjesis", "Lenchan", "Alura", "Ca Po", "Laylox", "Ecrumig", "Avoniv", "Bydo", "Aaxel", "Aldeni", "Setas", "Arami", "Danami", "Poco Re", "Robandus", "Recktic", "Zamilloz", "Subido", "Dawnre", "Salma", "Hamlinto", "Elenami", "Tahnan", "Zeo", "Roehi", "Once El", "Baselai", "Sandovi", "Illume", "Amiwill", "Sibbron", "Gilltin", "Abrin", "Ramnon", "Olavii", "Hacemill"}
local add = {}
local card, mode
card = ""
local stype = ""
local infflag = true
local adcheck = true
local xt, yt = 0
local madd, msg = ""
local abortm, gdial, gdialed = false
local diads = {}
local state, stateadd
local y = 0
local clsmsgtimerid = 0
local wake = false
local tun = comp.isAvailable("tunnel")
local linklist = {}
local tuntype
local tunnel
local sortmode
if (tun) then 
 tunnel = comp.tunnel
 tunnel.setWakeMessage("link", true)
 dofile("GI.ff")
end
--global variables--

--message read--
function keyadd(_,_,ch,code,_)
local posx, posy = term.getCursor()
 if (code == 28) then --enter
 iocheck = false
 goto ioend
 elseif (code == 14 and iomessage ~= "") then --backspace
 iomessage = iomessage:sub(1, #iomessage-1)
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 elseif (#iomessage < iolength and ch < 128) then
 iomessage = string.format("%s%s", iomessage, string.char(ch))
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 else
 pc.beep(40,0.1)
 end
 ::ioend::
end

function messread(length)
event.ignore("modem_message", maingateupdate)
iolength = length
iocheck = true
iomessage = ""
event.listen("key_down", keyadd)
 while (iocheck) do os.sleep(0) end
event.ignore("key_down", keyadd)
event.listen("modem_message", maingateupdate)
end
--message read--

--Milkyway glyph sorting method choose--
function sortchoose()
term.clear()
sortmode = io.open("sort.ff", "r")
 if (sortmode == nil or sortmode:seek("end") == 0) then
 sortmode = io.open("sort.ff", "w")
 term.write("Milkyway glyph sorting.\nChoose one: 1 - gate clockwise sorting, 2 - DHD clockwise sorting, 3 - alphabet sorting.\n")
 while (true) do
 local _, choose = pcall(io.read)
  if (choose == "1" or choose == "2" or choose == "3") then
  sortmode:write(string.format("sort = %s", choose))
  sortmode:close()
  break
  else
  term.write("Wrong value!\n")
  end
 end
 else
 sortmode:seek("set")
end
dofile("sort.ff")
end

sortchoose()

if(sort == 1) then dofile("MWGS.ff") elseif(sort == 2) then dofile("MWDS.ff") else dofile("MWAS.ff") end
--Milkyway glyph sorting method choose--

--checking address books--
function fopen()
local book
book = io.open("bookMW.ff", "r")
if book == nil then
    book = io.open("bookMW.ff", "w")
    book:close()
end
book = io.open("bookUN.ff", "r")
if book == nil then
    book = io.open("bookUN.ff", "w")
    book:close()
end
end
--checking address books--

--manual dialing glyph table reload--
function mwreload()
dofile("MWG.ff")
gpu.fill(1, 1, 23, 24, "　")
gpu.setForeground(0, true)
gpu.setBackground(15, true)
 for i, val in ipairs(mwf) do
 gpu.set(47+math.floor(i/20)*17, math.fmod(i+math.floor(i/20), 20), string.format("│%s", val))
 end
gpu.set(47, 20, "└────────────────┴────────────────")
end

function unreload()
dofile("UNG.ff")
gpu.fill(1, 1, 30, 24, "　")
gpu.setForeground(0, true)
gpu.setBackground(15, true)
 for i, val in ipairs(unf) do
 gpu.set(61+math.floor(i/19)*10, math.fmod(i+math.floor(i/19), 19), string.format("│%s", val))
 end
gpu.set(61, 19, "└─────────┴─────────")
end
--manual dialing glyph table reload--

--clear messages in manual dialing--
function clsmsg()
local a, _ = gpu.getBackground()
local b, _ = gpu.getForeground()
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,25,36,1,"　")
gpu.set(73, 25, "[RETURN]") 
gpu.setBackground(a, true)
gpu.setForeground(b, true)
end
--clear messages in manual dialing--

--clear messages in addressbook--
function clsmsgb()
local a, _ = gpu.getBackground()
local b, _ = gpu.getForeground()
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,25,40,1,"　")
gpu.setBackground(a, true)
gpu.setForeground(b, true)
end
--clear messages in addressbook--

--send message in manual dialing--
function sendmsg()
gpu.setBackground(0, true)
gpu.setForeground(15, true)
gpu.fill(1,24,40,2,"　")
gpu.set(1,24,"Message:")
term.setCursor(9,24)
messread(71)
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,24,40,2,"　")
gpu.set(73, 24, "[->BOOK]") 
gpu.set(73, 25, "[RETURN]")
 if (card == "modem") then
 modem.broadcast(1, "mess", iomessage, madd)
 elseif (card == "tunnel") then
 tunnel.send("mess", iomessage)
 end
end
--send message in manual dialing--

--abort dialing / disengagge gate--
function abort(_, _, x, y)
 if (x>72 and y==22) then
 pc.beep(250, 0.5)
 abortm = true
 event.ignore("touch", abort)
 if (card == "modem") then
 modem.send(madd, 1, "abort")
 elseif (card == "tunnel") then
 tunnel.send("abort")
 end
 add = {}
  if (stype == "MILKYWAY") then
  gpu.fill(1,1,22,24,"　")
  gpu.fill(45,1,1,24," ")
  mwreload()
  elseif (stype == "UNIVERSE") then
  gpu.fill(1,1,30,24,"　")
  unreload()
  end
 clsmsg()
  if (gdial) then
  gpu.set(1, 25, "abort dialing")
  gpu.set(73, 23, "        ")
  gpu.set(73, 24, "        ") 
  gdial = false
  gdialed = false 
  elseif (gdialed) then 
  gpu.set(1, 25, "abort dial")
  gpu.set(73, 23, "        ")
  gpu.set(73, 24, "        ") 
  gdialed = false
  else
  gpu.set(1, 25, "address cleared")
  end
 clsmsgtimerid = event.timer(5, clsmsg)
 elseif (x>72 and y==23) then
 sendmsg()
 elseif (x>72 and y==24) then
 abook()
 elseif (x>72 and y==25) then
 event.ignore("touch", abort)
 term.clear()
 mainscreen()
 end
 mainMD()
end

function abortbook(_, _, x, y)
event.cancel(clsmsgtimerid)
if (x > 59 and x < 73 and y == 1) then
 pc.beep(250, 0.5)
 abortm = true
 event.ignore("touch", abortbook)
 if (card == "modem") then
 modem.send(madd, 1, "abort")
 elseif (card == "tunnel") then
 tunnel.send("abort")
 end
 add = {}
 end
  if (gdial) then
  gpu.set(1, 25, "abort dialing")
  gdial = false
  gdialed = false 
  elseif (gdialed) then 
  gpu.set(1, 25, "abort dial")
  gdialed = false
  end
 clsmsgtimerid = event.timer(5, addressbookwork)
 os.sleep(0.1)
end
--abort dialing / disengagge gate--

--add address to address book--
function abook()
local book
local rewcheck = true
local addbook = {}
local msgt = ""
local num = 0
 if (stype == "MILKYWAY") then
 book = io.open("bookMW.ff", "r")
 elseif (stype == "UNIVERSE") then
 book = io.open("bookUN.ff", "r")
 end
num = 0
 for l in book:lines() do
 num = num+1
 if (l == "") then goto listend end
 addbook[num] = {}
 addbook[num][l:sub(1, l:find("=")-2)] = {}
  for t in string.gmatch(l:sub(l:find("=")+2), "([^,]+)") do
  table.insert(addbook[num][l:sub(1, l:find("=")-2)], t)
  end
 end
::listend::
for i = 1, #addbook do
 for _, val in pairs(addbook[i]) do
   if (serial.serialize(val) == serial.serialize(add)) then
   gpu.setBackground(15, true)
   gpu.setForeground(0, true)
   gpu.set(1,25, "Address already in address book")
   clsmsgtimerid = event.timer(5, clsmsg)
   goto bookend
  end
 end 
end
gpu.setBackground(0, true)
gpu.setForeground(15, true)
::namechoose::
gpu.fill(1,24,80,2," ")
gpu.set(1,24,"Write gate name (8 symbols max, no spaces):")
term.setCursor(44,24)
messread(8)
msgt = iomessage
gpu.setBackground(0, true)
gpu.setForeground(15, true)
 if msgt:len() > 8 then
 gpu.set(1,25, "Name too long")
 clsmsgtimerid = event.timer(5, clsmsg)
 goto namechoose
 elseif msgt == "Base" or msgt == "Base " or msgt == "Base  " or msgt == "Base   " or msgt == "Base    " then
 gpu.set(1,25, "This name is reserved. Please enter another name")
 clsmsgtimerid = event.timer(5, clsmsg)
 goto namechoose
 end
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,24,36,2,"　")
gpu.set(73, 25, "[RETURN]") 
if (msgt == "") then
 gpu.setBackground(15, true)
 gpu.setForeground(0, true)
 gpu.fill(1,25,40,1,"　")
 gpu.set(73, 24, "[->BOOK]") 
 goto bookend
 else
 for i = 1, #addbook do
 if (addbook[i][msgt] ~= nil) then
 gpu.setBackground(0, true)
 gpu.setForeground(15, true)
 gpu.fill(1,24,40,2,"　")
 gpu.set(1,24,"You want to rewrite this gate? \"Y\" = yes, other = cancel")
 term.setCursor(60,24)
 messread(1)
 local rewrite = iomessage
 gpu.setBackground(15, true)
 gpu.setForeground(0, true)
 gpu.fill(1,24,36,2,"　")
 gpu.set(73, 25, "[RETURN]")
  if (rewrite == "Y" or rewrite == "y") then
  addbook[i][msgt] = add
  gpu.setBackground(15, true)
  gpu.setForeground(0, true)
  gpu.fill(1,25,40,1,"　")
  gpu.set(73, 24, "[->BOOK]") 
  gpu.set(1,25, "Address rewrited")
  rewcheck = false
  goto bookend
  else
  gpu.set(1,25, "Canceled")
  end
 clsmsgtimerid = event.timer(5, clsmsg)
 gpu.setBackground(0, true)
 gpu.setForeground(15, true)
 goto namechoose
 end
 end
addbook[#addbook+1] = {[msgt] = add}
end
 if (stype == "MILKYWAY") then
 book = io.open("bookMW.ff", "w")
 elseif (stype == "UNIVERSE") then
 book = io.open("bookUN.ff", "w")
 end
 for i = 1, #addbook do
 for key, val in pairs(addbook[i]) do
 book:write(tostring(key), " = ", string.format("%s", string.gsub(string.gsub(string.gsub(serial.serialize(val), "\"", ""), "{", ""), "}", "")), "\n")
 end
 end
 if (msgt ~= "") then
 gpu.setBackground(15, true)
 gpu.setForeground(0, true)
 if (rewcheck) then gpu.set(1,25, "Address added") book:close() gpu.set(73, 24, "[->BOOK]") end
end
::bookend::
clsmsgtimerid = event.timer(2, clsmsg)
end
--add address to address book--

--address book work--
function addressbookwork()
local bookstate
local ingor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
  end
gpu.setForeground(0, true)
local booksel
 if (mode == "work") then
 booksel = "MILKYWAY"
 elseif (mode == "MILKYWAY" or mode == "UNIVERSE") then
 booksel = mode
  if (card == "modem") then
  modem.send(madd, 1, "link")
  _, _, _, _, _, _, bookstate = event.pull("modem_message", modem.address)
  elseif (card == "tunnel") then
  tunnel.send("link")
  _, _, _, _, _, _, _, bookstate = event.pull("modem_message", tunnel.address)
  end
 else
 term.clear()
 gpu.set(28,12,"ERROR! Please, try again")
 pc.beep(50,1)
 os.sleep(1)
 term.clear()
 event.cancel(clsmsgtimerid)
 event.listen("modem_message", maingateupdate)
 mainscreen()
 end
if bookstate == "open" then gdialed = true end
::addbookstart::
local book
local addbook = {}
local num = 0
local shown = 0
term.clear()
gpu.setForeground(7, true)
gpu.fill(1,2, 80, 1, "━")  
gpu.fill(1,22, 80, 1, "━")
 for i = 1, 5 do
 gpu.fill(9+(i-1)*16, 5, 1, 15, "│")
 gpu.fill(1, 4*i, 80, 1, "━")
 end
 for i = 1, 5 do
  if i ==1 or i == 5 then
  if i == 5 then gpu.set(9+(i-1)*16, 2, "╋") gpu.set(9+(i-1)*16, 1, "┃") else gpu.set(9+(i-1)*16, 2, "┳") end
  gpu.set(9+(i-1)*16, 3, "┃")
  gpu.set(9+(i-1)*16, 4, "╇")
  else
  gpu.set(9+(i-1)*16, 4, "┯")
  end
 gpu.set(9+(i-1)*16, 20, "┷")
 end
 gpu.setForeground(0, true)
 gpu.set(2,3,"Name")
 gpu.set(24,3,"Address (Without Point of Origin)")
 gpu.set(74,3,"Action")
 gpu.setForeground(7, true)
 for i = 1, 5 do
  for j = 1, 3 do
  gpu.set(9+(i-1)*16, 4*(j+1),"┿")
  end
 end
 for i = 1, 4 do
 gpu.fill(10, 2*(2*i+1), 63, 1, "─")
 gpu.set(9, 2*(2*i+1), "├")
 gpu.set(73, 2*(2*i+1), "┤")
  for j = 1, 3 do
  gpu.set(9+16*j, 2*(2*i+1), "┼")
  end
 end
gpu.setForeground(0, true)
gpu.set(2,21,"<──") 
gpu.set(77,21,"──>")
gpu.set(5,1,string.format("Gate type: %s", booksel))
if mode == "work" then
gpu.set(60,1,"[CHANGE TYPE]")
else
gpu.set(60,1,"[ABORT  DIAL]")
end
::bookworkloop::
gpu.setBackground(15, true)
gpu.setForeground(0, true)
 if (booksel == "MILKYWAY") then
 book = io.open("bookMW.ff", "r")
 elseif (booksel == "UNIVERSE") then
 book = io.open("bookUN.ff", "r")
 end
num = 0
 for l in book:lines() do
 num = num+1
 if (l == "") then goto bookworkend end
 addbook[num] = {}
 addbook[num][l:sub(1, l:find("=")-2)] = {}
  for t in string.gmatch(l:sub(l:find("=")+2), "([^,]+)") do
  table.insert(addbook[num][l:sub(1, l:find("=")-2)], t)
  end
 end
::bookworkend::
 for i = 1+shown, shown+4 do
  if addbook[i] == nil then 
  gpu.fill(1, 4*(i-shown)+2, 8, 1, " ")
   for ind = 1, 8 do
   gpu.fill(10+math.fmod(ind-1, 4)*16, 4*(i-shown)+1+math.floor((ind-1)/4)*2, 15, 1, " ")
   end
  else
   for key, val in pairs(addbook[i]) do
   local keylong = key
   while #keylong < 8 do
   keylong = string.format("%s ", keylong)
   end
   gpu.set(1, 4*(i-shown)+2, keylong)
    for ind = 1, 8 do
	 if val[ind] ~= "Point of Origin" and val[ind] ~= "Glyph 17" and val[ind] ~= nil and val[ind] ~= "" then 
	 local vallong = val[ind]
	  while #vallong < 15 do
      vallong = string.format("%s ", vallong)
      end
	 gpu.set(10+math.fmod(ind-1, 4)*16, 4*(i-shown)+1+math.floor((ind-1)/4)*2, string.format("%s", vallong))
	 else
	 gpu.fill(10+math.fmod(ind-1, 4)*16, 4*(i-shown)+1+math.floor((ind-1)/4)*2, 15, 1, " ")
	 end
    end
   end
  end
    if(mode == "work") then
	 if (addbook[i] ~= nil) then
     if not (i == 1 and tun) then
     gpu.set(74,4*(i-shown)+1,"RENAME")
     gpu.set(74,4*(i-shown)+3,"DELETE")
     end
	 else
     gpu.fill(74,4*(i-shown)+1, 7, 3, " ")
	 end 
	else
     if (addbook[i] ~= nil) then
	 gpu.set(74,4*(i-shown)+2,"[DIAL]")
	 else
     gpu.fill(74,4*(i-shown)+1, 7, 3, " ")
	 end 
	end
 end
gpu.set(40-math.floor((tostring(#addbook):len()+tostring(shown):len()+tostring(math.min(shown+4, #addbook)):len()+11)/2),21,string.format("Shown: %u-%u / %u", shown+1, math.min(shown+4, #addbook), #addbook)) 
gpu.set(74,1,"RETURN")
 ::bookworktouch::
local ignor = true
while ignor do
ignor = event.ignore("modem_message", maingateupdate)
end
local _, _, xmain, ymain = event.pull("touch")
 if (xmain > 73 and ymain == 1) then
 term.clear()
 event.cancel(clsmsgtimerid)
 event.listen("modem_message", maingateupdate)
 mainscreen()
 elseif (xmain > 1 and xmain < 5 and ymain == 21 and shown > 0) then
 shown = shown - 4
 goto bookworkend
 elseif (xmain > 76 and xmain < 80 and ymain == 21 and shown+4 < #addbook) then
 shown = shown + 4
 goto bookworkend
 elseif (xmain > 59 and xmain < 73 and ymain == 1) then
  if (mode == "work") then
   if booksel == "MILKYWAY" then booksel = "UNIVERSE" elseif booksel == "UNIVERSE" then booksel = "MILKYWAY" end
   goto addbookstart
  else
  abortbook(1, 2, xmain, ymain)
  goto bookworktouch
  end
 elseif (xmain > 73 and ymain > 4 and ymain < 20) then
  if (mode == "work") then
   if (math.fmod(ymain-5, 4) == 0 and addbook[(ymain-1)/4+shown] ~= nil and not((ymain-1)/4+shown == 1 and tun)) then
   gpu.setBackground(0, true)
   gpu.setForeground(15, true)
   ::namebookchoose::
   gpu.fill(1,24,80,2," ")
   gpu.set(1,24,"Write gate name (8 symbols max, no spaces):")
   term.setCursor(44,24)
   messread(8)
   local mst = iomessage
   gpu.setBackground(0, true)
   gpu.setForeground(15, true)
    if mst:len() > 8 then
    gpu.set(1,25, "Name too long")
    clsmsgtimerid = event.timer(5, clsmsgb)
    goto namebookchoose
    elseif msgt == "Base" or msgt == "Base " or msgt == "Base  " or msgt == "Base   " or msgt == "Base    " then
    gpu.set(1,25, "This name is reserved. Please enter another name.")
    clsmsgtimerid = event.timer(5, clsmsgb)
    goto namebookchoose
    end
   gpu.setBackground(15, true)
   gpu.setForeground(0, true)
   gpu.fill(1,24,40,2,"　")
    if (mst == "") then
    gpu.setBackground(15, true)
    gpu.setForeground(0, true)
    gpu.fill(1,25,40,1,"　")
    goto bookworktouch
    else
    gpu.setBackground(0, true)
    gpu.setForeground(15, true)
    end
   local timedadd = addbook[(ymain-1)/4+shown]
   addbook[(ymain-1)/4+shown] = {}
   addbook[(ymain-1)/4+shown][mst] = {}
    for _, val in pairs (timedadd) do
	addbook[(ymain-1)/4+shown][mst] = val
    end
	::bookchoiseend::	
    if (booksel == "MILKYWAY") then
    book = io.open("bookMW.ff", "w")
    elseif (booksel == "UNIVERSE") then
    book = io.open("bookUN.ff", "w")
    end
    for _, v in ipairs(addbook) do
    for key, val in pairs(v) do
    book:write(tostring(key), " = ", string.format("%s", string.gsub(string.gsub(string.gsub(serial.serialize(val), "\"", ""), "{", ""), "}", "")), "\n")
    end
    end
	book:close()
	goto bookworkloop
  elseif(math.fmod(ymain-7, 4) == 0 and addbook[(ymain-3)/4+shown] ~= nil and not((ymain-3)/4+shown == 1 and tun)) then
   gpu.setBackground(0, true)
   gpu.setForeground(15, true)
   gpu.fill(1,24,80,2," ")
   gpu.set(1,24,"Are you sure? \"Y\" = yes, other = cancel")
   term.setCursor(41,24)
   messread(1)
   local mst = iomessage
   gpu.setBackground(0, true)
   gpu.setForeground(15, true)
   gpu.set(73, 25, "[RETURN]")
    if (mst == "Y" or mst == "y") then
	 for i = (ymain-3)/4+shown, #addbook-1 do
	 addbook[i]=addbook[i+1]
	 end
	addbook[#addbook] = nil
    gpu.setBackground(15, true)
    gpu.setForeground(0, true)
    gpu.fill(1,24,40,2,"　") 
    gpu.set(1,25, "Address deleted")
	clsmsgtimerid = event.timer(5, clsmsgb)
    goto deletebookchoose
    else
    gpu.set(1,25, "Canceled")
	clsmsgtimerid = event.timer(5, clsmsgb)
    end
	::deletebookchoose::
    if (booksel == "MILKYWAY") then
    book = io.open("bookMW.ff", "w")
    elseif (booksel == "UNIVERSE") then
    book = io.open("bookUN.ff", "w")
    end
    for _, v in ipairs(addbook) do
    for key, val in pairs(v) do
    book:write(tostring(key), " = ", string.format("%s", string.gsub(string.gsub(string.gsub(serial.serialize(val), "\"", ""), "{", ""), "}", "")), "\n")
    end
    end
	book:close()
	goto bookworkloop
   else goto bookworktouch
   end
  else
   if (math.fmod(ymain-6, 4) == 0 and addbook[(ymain-2)/4+shown] ~= nil) then
   pc.beep(500, 0.25)
   pc.beep(600, 0.25)
   if (gdialed ~= true) then
	for _, val in pairs(addbook[(ymain-2)/4+shown]) do
	add = val
	end
   local ignor = true
    while ignor do
    ignor = event.ignore("modem_message", maingateupdate)
	end
   local dmsg, size
   event.listen("touch", abortbook)
    if (card == "modem") then
    modem.send(madd, 1, "add", serial.serialize(add))
    _, _, _, _, _, dmsg, size = event.pull("modem_message", modem.address)
    elseif (card == "tunnel") then
    tunnel.send("add", serial.serialize(add))
    _, _, _, _, _, dmsg, size = event.pull("modem_message", tunnel.address)
    end
   os.sleep(0.1)
    if (dmsg == "dialing") then
    gpu.set(1, 25, dmsg) 
    gdial = true
     for t = 1, tonumber(size) do
      if (abortm) then
      abortm = false
      goto abrtm
      else
      local diad
      if (card == "modem") then _, _, _, _, _, diad = event.pull("modem_message", modem.address) elseif (card == "tunnel") then _, _, _, _, _, diad = event.pull("modem_message", tunnel.address) end
      os.sleep(0.01)
       if (diad == "abort") then abortm = true
       elseif (diad == "dialed") then goto continuebook
       end
      ::continuebook::
      end
     diads = {}
     end
    ::abrtm::
    gpu.setForeground(0, true)
    local diad
    if (card == "modem") then _, _, _, _, _, diad = event.pull("modem_message", modem.address) elseif (card == "tunnel") then  _, _, _, _, _, diad = event.pull("modem_message", tunnel.address) end
    os.sleep(0.01)
    clsmsgb()
    --gpu.set(1, 25, diad)
     if (diad == "dialed") then
	 gpu.set(1, 25, diad)
     os.sleep(0.01)
     gdialed = true
     end
    clsmsgtimerid = event.timer(5, clsmsgb)
    else
    gpu.set(1, 25, dmsg)
    clsmsgtimerid = event.timer(5, clsmsgb)
    os.sleep(0.1)
    end
   goto bookworktouch
   else goto bookworktouch
   end
   else goto bookworktouch
   end
  goto bookworktouch
  end
 else
 goto bookworktouch
 end

end
--address book work--

--send message with address to dial and check dialing status--
function dial()
local ignor = true
while ignor do
ignor = event.ignore("modem_message", maingateupdate)
end
local dmsg, size
event.listen("touch", abort)
if (card == "modem") then
modem.send(madd, 1, "add", serial.serialize(add))
_, _, _, _, _, dmsg, size = event.pull("modem_message", modem.address)
elseif (card == "tunnel") then
tunnel.send("add", serial.serialize(add))
_, _, _, _, _, dmsg, size = event.pull("modem_message", tunnel.address)
end
os.sleep(0.1)
 if (dmsg == "dialing") then
 gpu.set(1, 25, dmsg)
 gpu.set(73, 22, "[ ABORT]") 
 gdial = true
  for t = 1, tonumber(size) do
   if (abortm) then
   abortm = false
   goto abrtm
   else
   gpu.setForeground(4, true)
   local diad
   if (card == "modem") then _, _, _, _, _, diad = event.pull("modem_message", modem.address) elseif (card == "tunnel") then _, _, _, _, _, diad = event.pull("modem_message", tunnel.address) end
   pc.beep(400, 0.1)
   os.sleep(0.01)
   if (diad == "abort") then abortm = true
   pc.beep(250, 0.25)
   elseif (diad == "dialed") then goto continue
   pc.beep(600, 0.25)
   pc.beep(600, 0.25)
   else
   diads = serial.unserialize(diad)
    for i, vali in ipairs(add) do
     if (diads[#diads] == vali) then
     local y = 0
      for line in GlyphImages[vali]:gmatch("[^\r\n]+") do
	   if (stype == "MILKYWAY") then
	   gpu.setForeground(4, true)
       gpu.set((math.fmod(i-1, 3)*15)+1, math.floor((i-1)/3)*8+y+1, line)
       elseif (stype == "UNIVERSE") then
       gpu.setForeground(0, true)
       gpu.set((math.fmod(i-1, 9)*6)+3, 4+y, line)
      end
      y = y+1
      os.sleep(0)
      end
     end
    end
   end
   ::continue::
   end
   diads = {}
  end
 ::abrtm::
 gpu.setForeground(0, true)
 local diad
 if (card == "modem") then _, _, _, _, _, diad = event.pull("modem_message", modem.address) elseif (card == "tunnel") then  _, _, _, _, _, diad = event.pull("modem_message", tunnel.address) end
 os.sleep(0.01)
 clsmsg()
 gpu.set(1, 25, diad)
  if (diad == "dialed") then
  os.sleep(0.01)
  gdialed = true
  gpu.set(73, 23, "[ SEND ]")
  gpu.set(73, 24, "[->BOOK]")
  end
  clsmsgtimerid = event.timer(5, clsmsg)
 else
 gpu.set(1, 25, dmsg)
 os.sleep(0.01)
 clsmsgtimerid = event.timer(5, clsmsg)
 end
 if (stype == "MILKYWAY") then
 mwreload()
 elseif (stype == "UNIVERSE") then
 unreload()
 end
end
--send message with address to dial and check dialing status--

--main manual dialing screen--
function mainMD()
local ignor = true
while ignor do
ignor = event.ignore("modem_message", maingateupdate)
end
 if (stype == "MILKYWAY") then
 mwreload()
 elseif (stype == "UNIVERSE") then
 unreload()
 end
gpu.set(73, 21, "[ DIAL ]")
 if (gdialed) then
 gpu.set(73, 22, "[ ABORT]")  
 else gpu.set(73, 22, "[ CLEAR]")
 end
 gpu.set(73, 25, "[RETURN]") 
  if (add == {}) then
  gpu.set(73, 23, "        ")
  gpu.set(73, 24, "        ")
  else
  if (gdialed) then gpu.set(73, 23, "[ SEND ]") end
  if (add[#add] == "Point of Origin" or add[#add] == "Glyph 17") then gpu.set(73, 24, "[->BOOK]") end
  end
  while (infflag) do
   for i = 1, #add do
   y = 0
   if (gdialed) then
    if (stype == "MILKYWAY") then
    gpu.setForeground(4, true)
    elseif (stype == "UNIVERSE") then
	gpu.setForeground(0, true)
    end
   else
    if (stype == "MILKYWAY") then
    gpu.setForeground(12, true)
    elseif (stype == "UNIVERSE") then
    gpu.setForeground(7, true)
    end
   end
    for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
     if (stype == "MILKYWAY") then
     gpu.set((math.fmod(i-1, 3)*15)+1, math.floor((i-1)/3)*8+y+1, line)
     elseif (stype == "UNIVERSE") then
     gpu.set((math.fmod(i-1, 9)*6)+3, 4+y, line)
     end
    y=y+1
    end
   gpu.setForeground(0, true)
   end
  os.sleep(0)
  ::mainloop::
  _, _, x, y = event.pull("touch")
   if (x>72 and y==21) then
   abortm = false
   dial()
   pc.beep(500, 0.1)
   pc.beep(1000, 0.1)
   elseif (x>72 and y==22) then
   abort(_, _, x, y)
   pc.beep(250, 0.5)
   elseif (x>72 and y==24) then
    if ((add[#add] == "Point of Origin" or add[#add] == "Glyph 17") and #add > 6) then
    abook()
    else
    gpu.set(1,25, "Wrong address")
    pc.beep(150, 0.1)
    pc.beep(150, 0.1)
    clsmsgtimerid = event.timer(5, clsmsg)
    end
   elseif (x>72 and y==23) then
    if (gdialed) then
    sendmsg()
    else
    gpu.set(1,25,"Not dialed")
    pc.beep(150, 0.25)
    clsmsgtimerid = event.timer(5, clsmsg)
    end
   elseif (x>72 and y==25) then
   event.ignore("touch", abort)
   term.clear()
   event.cancel(clsmsgtimerid)
   event.listen("modem_message", maingateupdate)
   pc.beep(250, 0.25)
   mainscreen()
   else
    if (stype == "MILKYWAY") then
     if (x>46 and y < 20 and #add < 9) then
     adcheck = true
      for _, val in ipairs(add) do
       if (val == mwf[y+math.floor((x-47)/17)*19]) then adcheck = false end
      end
      if (adcheck) then
      add[#add+1] = mwf[y+math.floor((x-47)/17)*19]
      gpu.set(math.floor((x-47)/17)*17+47, y, tostring(#add))
      gpu.setForeground(1, true)
       for i = 1, 17 do
       local cha = gpu.get((math.floor((x-46)/17)*17+46+i), y)
       gpu.set((math.floor((x-46)/17)*17+46+i), y, cha)
       end
      gpu.setForeground(0, true)
      end
     pc.beep(300, 0.25)
     end
    elseif (stype == "UNIVERSE") then
     if (x>60 and y < 19 and #add < 9) then
     adcheck = true
      for _, val in ipairs(add) do
       if (val == unf[y+math.floor((x-61)/10)*18]) then adcheck = false end
      end
      if (adcheck) then
      add[#add+1] = unf[y+math.floor((x-61)/10)*18]
      gpu.set(math.floor((x-61)/10)*10+61, y, tostring(#add))
      gpu.setForeground(1, true)
       for i = 1, 10 do
       local cha = gpu.get((math.floor((x-61)/10)*10+60+i), y)
       gpu.set((math.floor((x-61)/10)*10+60+i), y, cha)
       end
      gpu.setForeground(0, true)
      end
     pc.beep(300, 0.25)
     end
   end
   	--goto mainloop
  end
 end
end
--main manual dialing screen--

--find nearby gates--
function linkbreak()
gpu.set(23, 12, "No gate detected within 20 blocks")
pc.beep(100, 2)
os.sleep(2)
term.clear()
mainscreen()
end

function nmdlink(_, lrec, lmadd, _, ldis, lmsg, lstate, lstateadd)
 if (lrec == modem.address) then
 linklist[#linklist+1] = {["lmadd"] = lmadd, ["ldis"] = ldis, ["lmsg"] = lmsg, ["lstate"] = lstate, ["lstateadd"] = lstateadd}
 end
end

function nearbyMDlink()
event.ignore("modem_message", maingateupdate)
 if (card == "modem") then
 modem.broadcast(1, "link")
 gpu.set(28, 12, "Waiting for connection")
 event.listen("modem_message", nmdlink)
 os.sleep(2)
 event.ignore("modem_message", nmdlink)
 local distance = 100
 if #linklist == 0 then linkbreak() else
 for _, val in ipairs(linklist) do
  if val["ldis"] < distance then madd = val["lmadd"] distance = val["ldis"] msg = val["lmsg"] state = val["lstate"] stateadd = val["lstateadd"] end
 end
 if distance > 20 then linkbreak()
 else
 pc.beep(500, 0.25)
 if (state == "open") then gdialed = true else gdialed = false end
 local t = 1
 if (stateadd == "[]") then stateadd = nil else stateadd = string.gsub(string.gsub(stateadd, "%[", ""), "%]", "") end
  while (stateadd ~= nil) do
   if(string.find(stateadd, ", ") ~= nil) then
   add[t] = string.sub(stateadd, 1, string.find(stateadd, ", ")-1)
   stateadd = string.sub(stateadd, string.find(stateadd, ", ")+2, string.len(stateadd))
   else
   add[t] = stateadd
   stateadd = nil
   end
  t = t+1
  end
 end
 end
 stype = msg
 elseif (card == "tunnel") then
 tunnel.send("link")
 _, _, _, _, _, _, stype, state, _, _, stateadd, _ = event.pull("modem_message")
 if (state == "open") then gdialed = true else gdialed = false end
 local t = 1
 if (stateadd == "[]") then stateadd = nil else stateadd = string.gsub(string.gsub(stateadd, "%[", ""), "%]", "") end
  while (stateadd ~= nil) do
   if(string.find(stateadd, ", ") ~= nil) then
   add[t] = string.sub(stateadd, 1, string.find(stateadd, ", ")-1)
   stateadd = string.sub(stateadd, string.find(stateadd, ", ")+2, string.len(stateadd))
   else
   add[t] = stateadd
   stateadd = nil
   end
  t = t+1
  end
 end
 os.sleep(0.01)
 term.clear()
 fopen()
 mainMD()
end
--find nearby gates--

--main screen gate update--
function maingateupdate(_, recev, _, _, _, msg, tstype, state, energy, maxenergy, diaddress, gateaddress)
local ignor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
 end
os.sleep(0.2)
gpu.fill(29, 10, 11, 1, "　")
gpu.setForeground(8, true)
event.cancel(clsmsgtimerid)
if (tun and recev == tunnel.address) then
 if (msg == "link") then tunnel.send("link") event.listen("modem_message", maingateupdate)
 elseif (msg == "ener") then
  local energy = tostring(tonumber(tstype) *100 / tonumber(state))
  if (energy:find(".") == nil or energy:find(".") == 1) then energy = string.format("%s.000", energy) end
  if (energy:len() - energy:find(".") == 1) then energy = string.format("%s00", energy) end
  gpu.set(34,2, "Energy:")
  gpu.set(34,3, string.format("%s%%", string.sub(energy,1,string.find(energy,'.')+4)))
 elseif (msg == "main") then 
 event.listen("modem_message", maingateupdate)
 local ybase = 0 
 local gateadd = serial.unserialize(gateaddress)
 local mainbook
 local addtype = ""
 local mainadd = {}
 local num = 1
  for k = 1, 2 do
  num = 1
  mainadd = {}
   if (k == 1) then
   mainbook = io.open("bookMW.ff", "r")
   addtype = "MILKYWAY"
   else
   mainbook = io.open("bookUN.ff", "r")
   addtype = "UNIVERSE"
   end
  if (mainbook:seek("end") == 0) then mainadd[1] = {"#"} else
  mainbook:seek("set")
  for l in mainbook:lines() do
    if (l == "") then goto mainbookend end
   mainadd[num] = {}
   mainadd[num][l:sub(1, l:find("=")-2)] = {}
    for t in string.gmatch(l:sub(l:find("=")+2), "([^,]+)") do
    table.insert(mainadd[num][l:sub(1, l:find("=")-2)], t)
    end
	num = num+1
   end
  ::mainbookend::
  end
  local mainaddtimed = mainadd[1]
   if (table.concat(mainadd[1]) == "#") then
   mainadd[1] = {}
   mainadd[1].Base = {}
   local basegateadd = gateadd[addtype]
    for ii = 1, 8 do
    mainadd[1]["Base"][ii] = basegateadd[ii]
    end
	if (addtype == "MILKYWAY") then
      table.insert(mainadd[1]["Base"], "Point of Origin")
      elseif (addtype == "UNIVERSE") then
      table.insert(mainadd[1]["Base"], "Glyph 17")
      end
   else
    for key, val in pairs(mainaddtimed) do
    local valshort = val
    if (key ~= "Base") then
	local size = #mainadd
	 --if val ~= {} then
      for i = 1, size do
      mainadd[size+2-i] = {}
	   for kk, vv in pairs(mainadd[size-i+1]) do
	   mainadd[size-i+2][kk] = vv
	   end
	 end
	  --else mainadd = {}
     end
    mainadd[1] = {}
	mainadd[1].Base = {}
	local basegateadd = gateadd[addtype]
	for ii = 1, 8 do
    mainadd[1]["Base"][ii] = basegateadd[ii]
	end
      if (addtype == "MILKYWAY") then
      table.insert(mainadd[1]["Base"], "Point of Origin")
      elseif (addtype == "UNIVERSE") then
      table.insert(mainadd[1]["Base"], "Glyph 17")
      end
    end
   end
    if (addtype == "MILKYWAY") then
    mainbook = io.open("bookMW.ff", "w")
    elseif (addtype == "UNIVERSE") then
    mainbook = io.open("bookUN.ff", "w")
    end
   for _, v in ipairs(mainadd) do
    for key, val in pairs(v) do
    mainbook:write(tostring(key), " = ", string.format("%s", string.gsub(string.gsub(string.gsub(serial.serialize(val), "\"", ""), "{", ""), "}", "")), "\n")
    end
   end
  mainbook:close()
  end
 local eneper = tostring(tonumber(energy) *100 / tonumber(maxenergy))
 local dialedadd = {}
 local t = 1
 if (diaddress == "[]") then diaddress = nil else diaddress = string.gsub(string.gsub(diaddress, "%[", ""), "%]", "") end
  while (diaddress ~= nil) do
   if(string.find(diaddress, ", ") ~= nil) then
   dialedadd[t] = string.sub(diaddress, 1, string.find(diaddress, ", ")-1)
   diaddress = string.sub(diaddress, string.find(diaddress, ", ")+2, string.len(diaddress))
   else
   dialedadd[t] = diaddress
   diaddress = nil
   end
  t = t+1
  end
add = dialedadd
tuntype = tstype
stype = tstype
 if (tstype == "MILKYWAY") then
 gpu.setForeground(8, true)
 elseif (tstype == "UNIVERSE") then
 gpu.setForeground(7, true)
 end
 for line in GateImages["BaseUP"]:gmatch("[^\r\n]+") do
 gpu.set(6, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
 for line in GateImages["BaseDN"]:gmatch("[^\r\n]+") do
 gpu.set(6, ybase+17, line)
 ybase=ybase+1
 end
ybase = 0
 for line in GateImages["BaseLF"]:gmatch("[^\r\n]+") do
 gpu.set(1, ybase+4, line)
 ybase=ybase+1
 end
ybase = 0
 for line in GateImages["BaseRG"]:gmatch("[^\r\n]+") do
 gpu.set(31, ybase+4, line)
 ybase=ybase+1
 end
ybase = 0
local cha = ""
 if (state == "open") then
  if (tstype == "MILKYWAY") then
  gpu.setForeground(8, true)
  gpu.setBackground(11, true) 
  elseif (tstype == "UNIVERSE") then
  gpu.setForeground(7, true)
  gpu.setBackground(8, true)
  end
 for j = 1, 17 do
  for i = 1, 34 do
   if (math.pow(math.floor(math.abs(i-17.5)+1)/2, 2)+math.pow(math.abs(j-9), 2) < 81) then
   cha = gpu.get(i+2, j+1)
   gpu.set(i+2, j+1, cha)
   end
  end
 end 
 else
  if (tstype == "MILKYWAY") then
  gpu.setForeground(8, true)
  elseif (tstype == "UNIVERSE") then
  gpu.setForeground(7, true)
  end
 gpu.setBackground(15, true)
 for j = 1, 17 do
  for i = 1, 34 do
   if (math.pow(math.floor(math.abs(i-17.5)+1)/2, 2)+math.pow(math.abs(j-9), 2) < 81) then
   cha = gpu.get(i+2, j+1)
   gpu.set(i+2, j+1, cha)
   end
  end
 end 
 end
 if (dialedadd[#dialedadd] == "Point of Origin" or dialedadd[#dialedadd] == "Glyph 17") then 
 ybase = 0
 if (tstype == "MILKYWAY") then
 gpu.setBackground(8, true) 
 gpu.setForeground(4, true)
 elseif (tstype == "UNIVERSE") then
 gpu.setBackground(7, true)
 gpu.setForeground(0, true)
 end
 for line in GateImages["ChevOrigin"]:gmatch("[^\r\n]+") do
 gpu.set(18, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
 dialedadd[#dialedadd] = nil
 else
ybase = 0
 if (tstype == "MILKYWAY") then
 gpu.setBackground(8, true) 
 gpu.setForeground(12, true)
 elseif (tstype == "UNIVERSE") then
 gpu.setBackground(7, true)
 gpu.setForeground(8, true)
 end
 for line in GateImages["ChevOrigin"]:gmatch("[^\r\n]+") do
 gpu.set(18, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
 end
 for i = 1, 8 do
  if (tstype == "MILKYWAY") then
  gpu.setBackground(8, true)
  if (#dialedadd < i) then gpu.setForeground(12, true)  else gpu.setForeground(4, true) end 
  elseif (tstype == "UNIVERSE") then
  gpu.setBackground(7, true)
  if (#dialedadd < i) then gpu.setForeground(8, true) else gpu.setForeground(0, true) end
  end
  for line in GateImages["Chev"]:gmatch("[^\r\n]+") do
   if (i == 1 or i == 6) then
   gpu.set(30-math.floor(i/6)*22, ybase+3, line)
   elseif (i == 2 or i == 5) then
   gpu.set(36-math.floor(i/5)*34, ybase+7, line)
   elseif (i == 3 or i == 4) then
   gpu.set(34-math.floor(i/4)*30, ybase+15, line)
   else
   gpu.set(27-math.floor(i/8)*16, ybase+18, line)
   end
  ybase=ybase+1
  end
  ybase = 0
 end
 gpu.setBackground(15, true)
 gpu.setForeground(0, true)
 while (state:len() < 16) do state = string.format("%s ", state) end
 while (tstype:len() < 9) do tstype = string.format("%s ", tstype) end
 gpu.set(34,1, string.format("Type:%s Status:%s", tstype, state))
 if (eneper:find(".") == nil or eneper:find(".") == 1) then eneper = string.format("%s.000", eneper) end
 if (eneper:len() - eneper:find(".") == 1) then eneper = string.format("%s00", eneper) end
 gpu.set(34,2, "Energy:")
 gpu.set(34,3, string.format("%s%%", string.sub(eneper,1,string.find(eneper,'.')+4)))
 for key, val in ipairs(gateadd["UNIVERSE"]) do gateadd["UNIVERSE"][key] = val:gsub("Glyph ", "G") end
 if (stype == "MILKYWAY") then
  gpu.setForeground(1, true)
  elseif (stype == "UNIVERSE") then
  gpu.setForeground(8, true)
 end
 gpu.set(46,2,"UNV:")
 gpu.set(51,2,"MILKYWAY:")
 gpu.set(46,11,"PEGASUS:")
 gpu.set(65,11,"DIALED:")
 gpu.setForeground(0, true)
  for key, val in ipairs(gateadd["MILKYWAY"]) do 
  gpu.set(50+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, string.format("│%u", key))
  gpu.set(50+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "│")
   if (val == "Serpens Caput") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Serpens     ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Caput       ")
   elseif (val == "Corona Australis") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Corona      ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Australis   ")
   elseif (val == "Piscis Austrinus") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Piscis      ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Austrinus   ")
   else
   local vallong = val
   while vallong:len() < 12 do vallong = string.format("%s ", vallong) end
   gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, vallong)
   gpu.fill(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, 6, 1, "　")
   end
  end
  for key, val in ipairs(gateadd["UNIVERSE"]) do
  gpu.set(46,2+key,string.format("│%s",val))
  end
  for key, val in ipairs(gateadd["PEGASUS"]) do
  local vallong = val
  while vallong:len() < 8 do vallong = string.format("%s ", vallong) end
  gpu.set(46, 11+key, string.format("│%s", vallong))
  end
  for i = 1, 8 do
  gpu.set(65, 11+i, "│")
  end
  gpu.fill(66,12,14,8," ")
  for key, val in ipairs (dialedadd) do
  if (val ~= "Point of Origin" or val ~= "G17") then
  gpu.set(66, 11+key, val)
  end
  end
 pc.beep(150, 0.25)
 pc.beep(200, 0.125)
 pc.beep(300, 0.125)
 end
else
gpu.setForeground(8, true)
gpu.set(30, 9, "Main gate is not found")
gpu.set(20, 11, "A connection to nearest gates is available")
event.cancel(clsmsgtimerid)
end
 if (tun) then
 event.listen("modem_message", maingateupdate)
 end
end
--main screen gate update--

--main screen--
function mainscreen()
term.clear()
gpu.set(1, 25, tostring(card))
linklist = {}
gpu.setBackground(15, true)
gpu.setForeground(0, true)
event.ignore("touch", abort)
add = {}
if (tun) then
tunnel.send("link")
gpu.set(29, 10, "Stabilising connection")
event.listen("modem_message", maingateupdate)
end
gpu.setForeground(0, true)
gpu.fill(1,20,80,1,"─")
gpu.fill(1,23,80,1,"─")
gpu.set(13,20,"┬")
gpu.set(29,20,"┬")
gpu.set(39,20,"┬")
gpu.set(54,20,"┬")
gpu.set(65,20,"┬")
gpu.set(13,21,"│")
gpu.set(29,21,"│")
gpu.set(39,21,"│")
gpu.set(54,21,"│")
gpu.set(65,21,"│")
gpu.set(13,22,"│")
gpu.set(29,22,"│")
gpu.set(39,22,"│")
gpu.set(54,22,"│")
gpu.set(65,22,"│")
gpu.set(13,23,"┴")
gpu.set(29,23,"┴")
gpu.set(39,23,"┴")
gpu.set(54,23,"┴")
gpu.set(65,23,"┴")
gpu.set(1,22,"SEND MESSAGE")
gpu.set(1,21,"SORT CHANGE")
gpu.set(17,21,"┌ADDRESS┐")
gpu.set(17,22,"└─BOOKS─┘")
gpu.setForeground(8, true)
gpu.set(31,21,"NEARBY")
gpu.set(31,22,"DIALING")
 if (tun) then
 gpu.set(55,21,"MAIN GATE")
 gpu.set(55,22,"DIALING")
 end
gpu.setForeground(0, true)
gpu.set(40,21,"[ADDRESS BOOK]")
gpu.set(40,22,"[MANUAL DIAL ]")
 if (tun) then 
 gpu.set(66,21,"[ADDRESS BOOK]")
 gpu.set(66,22,"[MANUAL DIAL ]")
 else
 gpu.set(66,21,"MAIN GATE")
 gpu.set(66,22,"NOT DETECTED")
 end
::mainscreenbutton::
card = ""
local _, _, xmain, ymain = event.pull("touch")
 if (xmain<55 and xmain>39 and  (ymain == 22 or ymain == 23)) then
 term.clear()
 event.ignore("modem_message", maingateupdate)
  gpu.setForeground(0, true)
 card = "modem"
 nearbyMDlink()
 elseif (xmain>64 and (ymain == 22 or ymain == 23)) then
 term.clear()
 event.ignore("modem_message", maingateupdate)
  gpu.setForeground(0, true)
 card = "tunnel"
 nearbyMDlink()
 elseif (xmain>13 and xmain<29 and (ymain < 24 or ymain > 19)) then
 mode = "work"
 addressbookwork()
 elseif (xmain>65 and (ymain == 20 or ymain == 21) and tun) then --main--
 mode = stype
 card = "tunnel"
 addressbookwork()
 elseif (xmain>39 and xmain<54 and (ymain == 20 or ymain == 21)) then --nearby--
 local ignor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
  end
 term.clear() 
 linklist = {}
 modem.broadcast(1, "link")
 gpu.set(28, 12, "Waiting for connection")
 event.listen("modem_message", nmdlink)
 os.sleep(2)
 event.ignore("modem_message", nmdlink)
 local distance = 100
 if #linklist == 0 then linkbreak() else
 for _, val in ipairs(linklist) do
  if val["ldis"] < distance then madd = val["lmadd"] distance = val["ldis"] msg = val["lmsg"] state = val["lstate"] stateadd = val["lstateadd"] end
 end
  if distance > 20 then
  linkbreak()
  else
  mode = msg
  card = "modem"
  addressbookwork()
  end
 end
 elseif (xmain<13 and (ymain == 20 or ymain == 21)) then
 local repchoose = true
 while (repchoose) do
 term.clear()
 gpu.set(1, 12, "Milkyway glyph sorting.")
 gpu.set(1, 13, "Choose one: 1 - gate clockwise sorting, 2 - DHD clockwise sorting, 3 - alphabet sorting.")
 term.setCursor(1,14)
 local choose = io.read()
  if (choose == "1" or choose == "2" or choose == "3") then
  sortmode = io.open("sort.ff", "w")
  sortmode:write(string.format("sort = %s", choose))
  sortmode:close()
  repchoose = false
  else
  gpu.set(1,25,"Wrong value!")
  os.sleep(2)
  end
 end
 dofile("sort.ff")
 if(sort == 1) then dofile("MWGS.ff") elseif(sort == 2) then dofile("MWDS.ff") else dofile("MWAS.ff") end
 mainscreen()
 elseif (xmain<13 and (ymain == 22 or ymain == 23)) then
 gpu.setBackground(0, true)
 gpu.setForeground(15, true)
 gpu.fill(1,24,80,2,"　")
 gpu.set(1,24,"Message:")
 term.setCursor(9,24)
 local msgtimed
 --msgtimed = io.read()
 messread(56)
 gpu.setBackground(15, true)
 gpu.setForeground(0, true)
 gpu.fill(1,24,80,2,"　")
 tunnel.send("mess", iomessage)
 goto mainscreenbutton
 else
 goto mainscreenbutton
 end
event.listen("modem_message", maingateupdate)
term.clear()
end
--main screen--

--start program--
if (infflag) then
modem.open(1)
modem.setStrength(50)
term.clear()
mainscreen()
--while (infflag) do os.sleep(10) end
end
--start program--
