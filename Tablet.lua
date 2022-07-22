--libraries--
local comp = require("component")
local event = require("event")
local pc = require("computer")
local math = require("math")
local tbl = require("table")
local term = require("term")
local serial = require("serialization")
local math = require("math")
local string = require("string")
local gpu
if (comp.isAvailable("gpu")) then
 gpu = comp.gpu
 if(gpu.maxDepth()<4) then
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
if (comp.isAvailable("modem")) then
 modem = comp.modem
 if(comp.modem.isWireless() == false) then
 pc.beep(40, 0.5)
 pc.beep(40, 0.5)
 gpu.set(1,10,"Please, install Wireless Card level 2")
 os.sleep(2) 
 os.exit(false)
 elseif (comp.modem.setStrength(50) == 16) then
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
--libraries--

--global variables--
sortm, sortp = 0
addbook = {}
local sym = "▩"
local tunfirst = false
local gatestate = {}
gatestate.gtype = ""
gatestate.state = ""
gatestate.ener = 0
gatestate.maxener = 0
gatestate.dialed = {}
gatestate.add = {}
gatestate.add.MILKYWAY = {}
gatestate.add.PEGASUS = {}
gatestate.add.UNIVERSE = {}
gatestate.itype = ""
gatestate.istate = ""
local iomessage = ""
local iocheck = true
local iolength = 0
mwf = {}
unf = {"Glyph 1", "Glyph 2", "Glyph 3", "Glyph 4", "Glyph 5", "Glyph 6", "Glyph 7", "Glyph 8", "Glyph 9", "Glyph 10", "Glyph 11", "Glyph 12", "Glyph 13", "Glyph 14", "Glyph 15", "Glyph 16", "Glyph 17", "Glyph 18", "Glyph 19", "Glyph 20", "Glyph 21", "Glyph 22", "Glyph 23", "Glyph 24", "Glyph 25", "Glyph 26", "Glyph 27", "Glyph 28", "Glyph 29", "Glyph 30", "Glyph 31", "Glyph 32", "Glyph 33", "Glyph 34", "Glyph 35", "Glyph 36"}
pgf = {}
local add = {}
local card, mode
card = ""
local stype = ""
local infflag = true
local glflag = true
local baseaddflag = true
local adcheck = true
local xt, yt = 0
local madd, msg = ""
local abortm, gdialed = false
local diads = {}
local state, stateadd
local y = 0
local clsmsgtimerid = 0
local wake = false
local tun = comp.isAvailable("tunnel")
local linklist = {}
local tuntype
local tunnel
if (tun) then 
 tunnel = comp.tunnel
 tunnel.setWakeMessage(tbl.concat({"link"}, sym), true)
  if (glflag) then
  dofile("GI.ff")
  glflag = false
  end
end
local latesnearby = nil
--global variables--

--decode messages--
function decode(mess)
local mass = {}
for str in mess:gmatch("[^"..sym.."]+") do
tbl.insert(mass, str) end
return mass
end
--decode messages--

--checking address book--
function fopen()
local book
book = io.open("book.ab", "r")
if (book == nil or book:seek("end")==0) then
    book = io.open("book.ab", "w")
    book:write("addbook = {\n}")
end
book:close()
dofile("book.ab")
end

fopen()
--checking address book--

--add address into address book--
function addadd(book, name, mw, pg, un, tp, gdo, aurd)
tbl.insert(book, {["name"]=name, ["MILKYWAY"]=mw, ["PEGASUS"]=pg, ["UNIVERSE"]=un, ["gtype"]=tp, ["gdo"]=gdo, ["AURD"]=aurd})
return book
end
--add address into address book--

--similarity address check--
function addsim(add1, add2)
local check = true
local mn = math.min(#add1, #add2)
 for i = 1, mn do
 check = add1[i]==add2[i] and #add1 >= #add2 and check or false
 end
return check
end

function fulladdsim (add1, add2)
local mw, un, pg = false
mw = addsim(add1.MILKYWAY, add2.MILKYWAY)
pg = addsim(add1.PEGASUS, add2.PEGASUS)
un = addsim(add1.UNIVERSE, add2.UNIVERSE)
return mw, pg, un
end
--similarity address check--

--address book sort--
function addsort(book)
for i = 1, #book do if book[i].gtype == nil or book[i].gtype == "nil" or #book[i].MILKYWAY < 8 or #book[i].PEGASUS < 8 or #book[i].UNIVERSE < 8 then book[i].AURD = false book[i].gtype = "UNKNOWN" end end
 if #book > 1 then
  for i = 1, #book-1 do
   for j = i+1, #book do
    if book[i].gtype > book[j].gtype then
    local c = {}
    for name, val in pairs(book[i]) do c[name]=val end
    for name, val in pairs(book[j]) do book[i][name]=val end
    for name, val in pairs(c) do book[j][name]=val end
    end
   end
  end
  for i = 1, #book-1 do
   for j = i+1, #book do
    if book[i].name > book[j].name and book[j].gtype == book[i].gtype then
    local c = {}
    for name, val in pairs(book[i]) do c[name]=val end
    for name, val in pairs(book[j]) do book[i][name]=val end
    for name, val in pairs(c) do book[j][name]=val end
    end
   end
  end
 end
--tbl.sort(book, function (a, b) return(a.gtype ~= nil and b.gtype~= nil and a.gtype < b.gtype) end)
 if tun then
 tunnel.send("link")
 _, _, _, _, _, mess = event.pull("modem_message")
 _, stype, _, _, _, _, seradd = tbl.unpack(decode(mess))
 local add = {}
 add = serial.unserialize(seradd)
 local mw = tbl.concat(add.MILKYWAY)
 local pg = tbl.concat(add.PEGASUS)
 local un = tbl.concat(add.UNIVERSE)
  for i, v in ipairs(book) do 
   if tbl.concat(v.MILKYWAY) == mw and tbl.concat(v.PEGASUS) == pg and tbl.concat(v.UNIVERSE) == un then
   tbl.remove(book, i)
   tbl.insert(book, 1, v)
   break
   end
  end
 end
return book
end
--address book sort--

--address book update--
function abookupd(mass)
local book
book = io.open("book.ab", "w")
book:write(mass.name == "" and "addbook = {\n}" or "addbook = {\n")
 if mass.name ~= "" then
  for i, v in ipairs(mass) do
  if i < #mass then
  book:write(string.format("{[\"name\"]=\"%s\",\n [\"MILKYWAY\"]={\"%s\"},\n [\"PEGASUS\"]={\"%s\"},\n [\"UNIVERSE\"]={\"%s\"},\n [\"gtype\"]=\"%s\",\n [\"gdo\"]=\"%s\",\n [\"AURD\"]=%s},\n\n", v.name, tbl.concat(v.MILKYWAY, "\", \""), tbl.concat(v.PEGASUS, "\", \""), tbl.concat(v.UNIVERSE, "\", \""), v.gtype, tostring(v.gdo), tostring(v.AURD)))
  else
  book:write(string.format("{[\"name\"]=\"%s\",\n [\"MILKYWAY\"]={\"%s\"},\n [\"PEGASUS\"]={\"%s\"},\n [\"UNIVERSE\"]={\"%s\"},\n [\"gtype\"]=\"%s\",\n [\"gdo\"]=\"%s\",\n [\"AURD\"]=%s}\n", v.name, tbl.concat(v.MILKYWAY, "\", \""), tbl.concat(v.PEGASUS, "\", \""), tbl.concat(v.UNIVERSE, "\", \""), v.gtype, tostring(v.gdo), tostring(v.AURD)))
  end
  end
 book:write("}") 
 end
book:close()
dofile("book.ab")
end

function mainaddupd()
local flag = true
 tunnel.send("getmain")
 local _, _, _, _, _, mess = event.pull("modem_message")
 local tadd = {}
 local mwser, pgser, unser, gatetype = tbl.unpack(decode(mess))
 local mw = serial.unserialize(mwser)
 local pg = serial.unserialize(pgser)
 local un = serial.unserialize(unser)
 tadd.MILKYWAY = {tbl.unpack(mw)}
 tadd.PEGASUS = {tbl.unpack(pg)}
 tadd.UNIVERSE = {tbl.unpack(un)}
 tadd.gtype = gatetype
 tadd.gdo = ""
 tadd.AURD = true
 for i, v in ipairs(addbook) do
 local mw, pg, un = fulladdsim(tadd, v)
 local mwf = tbl.concat(tadd.MILKYWAY) == tbl.concat(v.MILKYWAY)
 local pgf = tbl.concat(tadd.PEGASUS) == tbl.concat(v.PEGASUS)
 local unf = tbl.concat(tadd.UNIVERSE) == tbl.concat(v.UNIVERSE)
 local gt = tadd.gtype == v.gtype
 local ac = tadd.AURD == v.AURD
  if mwf and pgf and unf and gt and ac then
  flag = false
  break
  elseif mw and pg and un then
  term.clear()
  flag = false
  print("Updating main gate data. Please, wait.")
  addbook[i].MILKYWAY = {tbl.unpack(tadd.MILKYWAY)}
  addbook[i].PEGASUS = {tbl.unpack(tadd.PEGASUS)}
  addbook[i].UNIVERSE = {tbl.unpack(tadd.UNIVERSE)}
  addbook[i].gtype = tadd.gtype
  addbook[i].gdo = tadd.gdo
  addbook[i].AURD = tadd.AURD
  abookupd(addbook)
  break
  end
 end
 if flag then 
 ::maingatenameloop::
 term.clear()
 print("Updating database.\nPlease write a name for main gate (English only. Max: 30).\nYou can change it in address book.")
 messread(30)
 if iomesage == "" then print("Name cannot be empty. Please, try again.") os.sleep(2) term.clear() goto maingatenameloop end
 addbook = addadd(addbook, iomessage, tadd.MILKYWAY, tadd.PEGASUS, tadd.UNIVERSE, tadd.gtype, tadd.gdo, tadd.AURD)
 end
term.clear()
local timed = addsort(addbook)
abookupd(timed)
end
--address book update--

--address update--
function addupd(book, tadd, screen)
local mass = {}
 for i, v in ipairs (book) do
 mass[1] = (addsim(v.MILKYWAY, tadd.MILKYWAY) and tbl.concat(tadd.MILKYWAY) ~= "" and tbl.concat(v.MILKYWAY) ~= "" and mass[1]==nil) and i or mass[1]
 mass[2] = (addsim(v.PEGASUS, tadd.PEGASUS) and tbl.concat(tadd.PEGASUS) ~= "" and tbl.concat(v.PEGASUS) ~= "" and mass[2]==nil) and i or mass[2]
 mass[3] = (addsim(v.UNIVERSE, tadd.UNIVERSE) and tbl.concat(tadd.UNIVERSE) ~= "" and tbl.concat(v.UNIVERSE) ~= "" and mass[3]==nil) and i or mass[3]
 end
local it = 1
 while it < #mass do
  if mass[it] == nil then 
  tbl.remove(mass, it) 
  it=it-1
  end
 it = it+1
 end
if (mass[1]==mass[3] or mass[2]==mass[3]) and #mass > 2 then tbl.remove(mass, 3) end
if (mass[1]==mass[2]) and #mass > 1 then tbl.remove(mass, 2) end
 if #mass == 1 then  
 local mw, pg, un = fulladdsim(book[mass[1]], tadd)
 local mwn = tbl.concat(book[mass[1]].MILKYWAY) == tbl.concat(tadd.MILKYWAY) or #book[mass[1]].MILKYWAY > #tadd.MILKYWAY
 local pgn = tbl.concat(book[mass[1]].PEGASUS) == tbl.concat(tadd.PEGASUS) or #book[mass[1]].PEGASUS > #tadd.PEGASUS
 local unn = tbl.concat(book[mass[1]].UNIVERSE) == tbl.concat(tadd.UNIVERSE) or #book[mass[1]].UNIVERSE > #tadd.UNIVERSE
 local gtn = tadd.gtype == book[mass[1]].gtype 
 term.clear()
  if mw and pg and un then
   if mwn and pgn and unn and gtn then
   print("No new gates found.")
   else
   print("Updating the database. Please, wait.")
   book[mass[1]].MILKYWAY = tadd.MILKYWAY
   book[mass[1]].PEGASUS = tadd.PEGASUS
   book[mass[1]].UNIVERSE = tadd.UNIVERSE 
   book[mass[1]].AURD = true
   book[mass[1]].gtype = tadd.gtype
   book[mass[1]].gdo = tadd.gdo
   end
  else
  print("WARNING! Database conflict detected.")
  print("Wrong entries detected. Saving incorrect addresses to the new [UNTITLED] gate.")
  local mwadd = mw and {} or book[mass[1]].MILKYWAY
  local pgadd = pg and {} or book[mass[1]].PEGASUS
  local unadd = un and {} or book[mass[1]].UNIVERSE
  book = addadd(book, "[UNTITLED]", mwadd, pgadd, unadd, "UNKNOWN", "", false)
  book[mass[1]].MILKYWAY = tadd.MILKYWAY
  book[mass[1]].PEGASUS = tadd.PEGASUS
  book[mass[1]].UNIVERSE = tadd.UNIVERSE
  book[mass[1]].AURD = true
  book[mass[1]].gdo = tadd.gdo
  book[mass[1]].gtype = tadd.gtype
  print("Success.")
  os.sleep(1)
  end
 else
 local mw = {}
 local pg = {}
 local un = {}
 for i = 1, #mass do mw[i] = tbl.concat(book[mass[i]].MILKYWAY) pg[i] = tbl.concat(book[mass[i]].MILKYWAY) un[i] = tbl.concat(book[mass[i]].MILKYWAY) end
 it = 1
 local check = false
  while it < #mass do
  check = true
  if mw[it] == "" then tbl.remove(mw, it) check = false end
  if pg[it] == "" then tbl.remove(pg, it) check = false end
  if un[it] == "" then tbl.remove(un, it) check = false end
  it = check and it+1 or it
  end
 ::addupdloop::
 term.clear()
  if #mw == 0 and #pg == 0 and #un == 0 then
  ::namegateloop::
  print("Updating database.\nPlease write a name for new gate (English only. Max: 30).")
  messread(30)
  if iomesage == "" then print("Name cannot be empty. Please, try again.") os.sleep(2) term.clear() goto namegateloop end
  book = addadd(book, iomessage, tadd.MILKYWAY == nil and {} or tadd.MILKYWAY, tadd.PEGASUS == nil and {} or tadd.PEGASUS, tadd.UNIVERSE == nil and {} or tadd.UNIVERSE, (tadd.gtype == nil or tadd.gtype == "nil") and "UNKNOWN" or tadd.gtype, (tadd.gdo == nil or tadd.gdo == "nil") and "" or tadd.gdo, tadd.AURD == nil and false or tadd.AURD)
  else
  print("WARNING! Database conflict detected.")
   if (#mw==1 or #mw==0) and (#pg==1 or #pg==0) and (#un==1 or #un==0) then
   print("Parts of the full gate address were divided between the following entries:")
   for i, v in ipairs(mass) do print(i, book[v].name) end
   print("These addresses will be merged.\nPlease write the number with the name of your choice (the remaining entries will be erased).")
   local datain = tonumber(io.read())
    if not datain then 
    print("Wrong value!")
    os.sleep(2)
    goto addupdloop
    else
    local num = mass[datain]
    book[num].MILKYWAY = tadd.MILKYWAY
    book[num].PEGASUS = tadd.PEGASUS
    book[num].UNIVERSE = tadd.UNIVERSE 
    book[num].AURD = true
    book[num].gtype = tadd.gtype
     for i = 1, #mass do
      if i ~= datain then
      book[mass[i]] = ""
      end
     local void = 1
      while void <= #book do
      if book[void] == "" then tbl.remove(book, void) void = void-1 end
      void = void+1
      end
     end
    end
   else
   print("The gate address was mixed with the addresses of other gates. A conflict of the following addresses was detected:")
   for i, v in ipairs(mass) do print(i, book[v].name) end
   print("These addresses cannot be combined.\nYou must select a gate to overwrite: the address of the selected gate will be overwritten with the address of the added gate,\nand the parts of the other gate's address found in it will be copied to the new [UNTITLED] addresses.\nFor the remaining gates, the corresponding conflicting parts of the address will be erased.\nPlease enter the number of the gate to overwrite.")  
   local datain = tonumber(io.read())
    if not datain then 
    print("Wrong value!")
    os.sleep(2)
    goto addupdloop
    else
    local mwch, pgch, unch = fulladdsim(book[mass[datain]], add)
     if mwch and pgch and unch then
     print("Overwritting in process. Please, wait.")
     local num = mass[datain]
     book[num].MILKYWAY = tadd.MILKYWAY
     book[num].PEGASUS = tadd.PEGASUS
     book[num].UNIVERSE = tadd.UNIVERSE 
     book[num].AURD = true
     book[num].gtype = tadd.gtype
     book[num].gdo = tadd.gdo
     else
     print("Wrong entries detected. Saving incorrect addresses to the new [UNTITLED] gate.")
     local mwadd = mwch and {} or book[mass[1]].MILKYWAY
     local pgadd = pgch and {} or book[mass[1]].PEGASUS
     local unadd = unch and {} or book[mass[1]].UNIVERSE
     book = addadd(book, "[UNTITLED]", mwadd, pgadd, unadd, "UNKNOWN", "", false)
     end
     for i = 1, #mass do
      if i ~= datain then 
      local mwchi, pgchi, unchi = fulladdsim(book[mass[i]], tadd)
      book[mass[i]].MILKYWAY = mwchi and {} or book[mass[i]].MILKYWAY
      book[mass[i]].PEGASUS = pgchi and {} or book[mass[i]].PEGASUS
      book[mass[i]].UNIVERSE = unchi and {} or book[mass[i]].UNIVERSE
      end
     end
    end
   end 
  end 
 print("Success.")  
 end
local timed = addsort(book)
abookupd(timed)
 if screen == "book" then
 print("Proceed to address book screen.")
 os.sleep(1)
 abookscreen()
 elseif screen == "dial" then
 print("Proceed to dialing screen.")
 os.sleep(1)
 mainMD(tadd[gatetype])
 end
end
--address update--

--manual dialing address adder--
function addinbook(mode, screen)
term.clear()
gpu.set(1,12,"The process of updating the address book has been started. Please wait.")
 if mode == "tunnel" then
 tunnel.send("get")
 elseif mode == "modem" then
 modem.broadcast(100, "get")
 end
local _,_,_,_,_,mess = event.pull("modem_message")
local addtimed = {}
 if mess == "None" then
 local addshort = {tbl.unpack(add)}
 if (addshort[#addshort] == "Point of Origin" or addshort[#addshort] == "Glyph 17" or addshort[#addshort] == "Subido") then tbl.remove(addshort) end
 addtimed.MILKYWAY = stype == "MILKYWAY" and {tbl.unpack(addshort)} or {}
 addtimed.PEGASUS = stype == "PEGASUS" and {tbl.unpack(addshort)} or {}
 addtimed.UNIVERSE = stype == "UNIVERSE" and {tbl.unpack(addshort)} or {}
 addtimed.gtype = "UNKNOWN"
 addtimed.AURD = false
 addtimed.gdo = ""
 else
 local mwser, pgser, unser, gatetype = tbl.unpack(decode(mess))
 local mw = serial.unserialize(mwser)
 local pg = serial.unserialize(pgser)
 local un = serial.unserialize(unser)
 addtimed.MILKYWAY = {tbl.unpack(mw)}
 addtimed.PEGASUS = {tbl.unpack(pg)}
 addtimed.UNIVERSE = {tbl.unpack(un)}
 addtimed.gtype = gatetype
 addtimed.AURD = true
 addtimed.gdo = ""
 end
addupd(addbook, addtimed, screen)
end
--manual dialing address adder--

--message read--
function keyadd(_,_,ch,code,_)
local posx, posy = term.getCursor()
 if (code == 28) then --enter
 iocheck = false
 goto ioend
 elseif (code == 14) then --backspace
 if iomessage ~= "" then iomessage = iomessage:sub(1, #iomessage-1) end
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 elseif (#iomessage<iolength and ch<128) then
 iomessage = string.format("%s%s", iomessage, string.char(ch))
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 else
 pc.beep(40,0.1)
 end
 ::ioend::
end

function messread(length)
local bool = event.ignore("modem_message", maingateupdate)
iolength = length
iocheck = true
iomessage = ""
event.listen("key_down", keyadd)
 while (iocheck) do os.sleep(0) end
event.ignore("key_down", keyadd)
if (bool) then event.listen("modem_message", maingateupdate) end
end
--message read--

--Milkyway/Pegasus glyph sorting method choose--
function sortchoose(mode)
term.clear()
gpu.setBackground(15, true)
gpu.setForeground(0, true)
local sortmode = io.open("sort.ff", "r")
 if (sortmode == nil or sortmode:seek("end") == 0 or mode) then
 sortmode = io.open("sort.ff", "w")
  while (true) do
  term.write("Milkyway glyph sorting.\nChoose one: 1 - gate clockwise sorting, 2 - DHD clockwise sorting, 3 - alphabet sorting.\n")
  local _, choose = pcall(io.read)
   if (choose == "1" or choose == "2" or choose == "3") then
   sortmode:write(string.format("sortm = %s\n", choose))
   term.write("Changes accepted.\n")
   break
   else
   term.write("Wrong value!\n")
   os.sleep(2)
   term.clear()
   end
  os.sleep(2)
  end
 term.clear()
  while (true) do
  term.write("Pegasus glyph sorting.\nChoose one: 1 - gate clockwise sorting, 2 - DHD clockwise sorting, 3 - alphabet sorting.\n")
  local _, choose = pcall(io.read)
   if (choose == "1" or choose == "2" or choose == "3") then
   sortmode:write(string.format("sortp = %s", choose))
   term.write("Changes accepted.\n")
   break
   else
   term.write("Wrong value!\n")
   os.sleep(2)
   term.clear()
   end
  sortmode:close()
  os.sleep(2)
  end
 else
 sortmode:seek("set")
 sortmode:close()
 end
sortmode:close()
dofile("sort.ff")
if sortm == nil or sortp == nil then sortchoose(true) end
dofile(sortm==1 and "MWGS.ff" or sortm==2 and "MWDS.ff" or "MWAS.ff")
dofile(sortp==1 and "PGGS.ff" or sortp==2 and "PGDS.ff" or "PGAS.ff")
end

sortchoose(false)
--Milkyway/Pegasus glyph sorting method choose--

--find nearby gates--
function linkbreak()
gpu.set(23, 12, "No gate detected within 20 blocks")
pc.beep(100, 2)
os.sleep(2)
term.clear()
mainscreen()
end

function nmdlink(_, lrec, lmadd, _, ldis, mess)
local lmsg, lstate, lstateadd, lgate = tbl.unpack(decode(mess))
 --if (lrec == modem.address) then
 tbl.insert(linklist, {["lmadd"] = lmadd, ["ldis"] = ldis, ["lmsg"] = lmsg, ["lstate"] = lstate, ["lstateadd"] = lstateadd, ["lgate"] = lgate})
 --end
end

function nearbyMDlink()
event.ignore("modem_message", maingateupdate)
 if (card == "modem") then
 modem.broadcast(100, "link")
 gpu.set(28, 12, "Waiting for connection")
 event.listen("modem_message", nmdlink)
 os.sleep(2)
 event.ignore("modem_message", nmdlink)
 local distance = 100
  if #linklist == 0 then
  linkbreak() 
  else
   for _, val in ipairs(linklist) do
    if val["ldis"]<distance then madd = val["lmadd"] distance = val["ldis"] msg = val["lmsg"] state = val["lstate"] stateadd = val["lstateadd"] end
   end
   if distance>20 then
   linkbreak()
   else
   pc.beep(500, 0.25)
   if (state == "open") then gdialed = true else gdialed = false end
   stateadd = (stateadd ~= "[]" and string.gsub(string.gsub(stateadd, "%[", ""), "%]", "")) or nil
   add = {}
    if stateadd ~= nil then
     for str in string.gmatch(stateadd, "%a%P+") do
     tbl.insert(add, str)
     end
    end
   end
  end
 stype = msg
 elseif (card == "tunnel") then
 tunnel.send("link")
 _, _, _, _, _, mess = event.pull("modem_message")
 _, stype, state, _, _, stateadd, _ = tbl.unpack(decode(mess))
 if (state == "open") then gdialed = true else gdialed = false end
 stateadd = (stateadd ~= "[]" and string.gsub(string.gsub(stateadd, "%[", ""), "%]", "")) or nil
 add = {}
  if stateadd ~= nil then
   for str in string.gmatch(stateadd, "%a%P+") do
   tbl.insert(add, str)
   end
  end
 end
os.sleep(0.01)
term.clear()
mainMD()
end
--find nearby gates--

--manual dialing glyph tbl reload--
function mwreload()
dofile("MWG.ff")
gpu.fill(1, 1, 23, 24, "　")
gpu.setForeground(0, true)
gpu.setBackground(15, true)
 for i, val in ipairs(mwf) do
 local str = string.format("│%s", val)
 while str:len() <= 18 do str = string.format("%s ", str) end
 gpu.set(47+math.floor(i/20)*17, math.fmod(i+math.floor(i/20), 20), str)
 end
gpu.set(47, 20, "└────────────────┴────────────────")
end

function unreload()
dofile("UNG.ff") 
gpu.fill(1, 1, 30, 24, "　")
gpu.setForeground(0, true)
gpu.setBackground(15, true)
 for i, val in ipairs(unf) do
 local str = string.format("│%s", val)
 while str:len() <= 11 do str = string.format("%s ", str) end
 gpu.set(61+math.floor(i/19)*10, math.fmod(i+math.floor(i/19), 19), str)
 end
gpu.set(61, 19, "└─────────┴─────────")
end

function pgreload()
dofile("PGG.ff")
gpu.fill(1, 1, 31, 24, "　")
gpu.setForeground(9, true)
for i = 1, 9 do
local y = 0
 for line in GlyphImages.Null:gmatch("[^\r\n]+") do   
 gpu.set((math.fmod(i-1, 3)*(stype == "PEGASUS" and 16 or 15))+1, math.floor((i-1)/3)*8+y+1, line)
 y=y+1
 end
end
gpu.setForeground(0, true)
gpu.setBackground(15, true)
 for i, val in ipairs(pgf) do
 local str = string.format("│%s", val)
 while str:len() <= 10 do str = string.format("%s ", str) end
 gpu.set(63+math.floor(i/19)*9, math.fmod(i+math.floor(i/19), 19), str)
 end
gpu.set(63, 19, "└────────┴────────")
end
--manual dialing glyph tbl reload--

--clear messages in manual dialing--
function clsmsg()
local a, _ = gpu.getBackground()
local b, _ = gpu.getForeground()
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,25,36,1,"　")
--gpu.set(73, 25, "[RETURN]") 
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
function sendmsg(mode)
gpu.setBackground(0, true)
gpu.setForeground(15, true)
gpu.fill(1,24,40,2,"　")
gpu.set(1,24, mode == "msg" and "Message:" or mode == "gdo" and "Code:")
term.setCursor(mode == "msg" and 9 or mode == "gdo" and 6, 24)
messread(mode == "msg" and 71 or mode == "gdo" and 30)
gpu.setBackground(15, true)
gpu.setForeground(0, true)
gpu.fill(1,24,40,2,"　")
gpu.set(73, 24, "[->BOOK]") 
gpu.set(73, 25, "[RETURN]")
 if (card == "modem") then
 modem.broadcast(100, mode == "msg" and "mess" or mode == "gdo" and "iopensend", iomessage, madd)
 elseif (card == "tunnel") then
 tunnel.send(mode == "msg" and "mess" or mode == "gdo" and "iopensend", iomessage)
 end
end
--send message in manual dialing--

--abort dialing / disengagge gate--
function abort(_, _, x, y)
 if (x>72 and y==22) then
 abortm = true
 event.ignore("touch", abort)
 if gdialed then 
  if (card == "modem") then
  modem.send(madd, 100, "abort")
  elseif (card == "tunnel") then
  gpu.set(50,22,card)
  end
 end
 add = {}
  if (stype == "MILKYWAY") then
  gpu.fill(1,1,22,24,"　")
  gpu.fill(45,1,1,24," ")
  mwreload()
  elseif (stype == "PEGASUS") then
  gpu.fill(1,1,30,24,"　")
  gpu.fill(45,1,1,24," ")
  pgreload()
  elseif (stype == "UNIVERSE") then
  gpu.fill(1,1,30,24,"　")
  gpu.fill(45,1,1,24," ")
  unreload()
  end
 clsmsg()
  if (gdialed) then 
  gpu.set(1, 25, "abort dial")
  gpu.set(68, 23, "             ")
  gpu.set(73, 24, "        ") 
  gdialed = false
  else
  gpu.set(1, 25, "address cleared")
  end
 clsmsgtimerid = event.timer(5, clsmsg)
 elseif (x>72 and y==23) then
 sendmsg()
 elseif (x==80 and y==1) then
 term.clear()
 os.exit()
 elseif (x>72 and y==24) then
 addinbook(card, "dial")
 elseif (x>72 and y==25) then
 event.ignore("touch", abort)
 term.clear()
 mainscreen()
 end
pc.beep(250, 0.5)
mainMD()
end
--abort dialing / disengagge gate--

--send message with address to dial and check dialing status--
function dial()
local ignor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
 end
local dmsg, size
event.listen("touch", abort)
 if (card == "modem") then
 modem.send(madd, 100, "add", serial.serialize(add))
 _, _, _, _, _, mess = event.pull("modem_message", modem.address)
 dmsg, size = tbl.unpack(decode(mess))
 elseif (card == "tunnel") then
 tunnel.send("add", serial.serialize(add))
 _, _, _, _, _, mess = event.pull("modem_message", tunnel.address)
 dmsg, size = tbl.unpack(decode(mess))
 end
os.sleep(0.1)
 if (dmsg == "dialing") then
 gpu.set(1, 25, dmsg)
 gpu.set(73, 22, "[ ABORT]") 
 gdialed = true
  for t = 1, tonumber(size) do
   if (abortm) then
   abortm = false
   goto abrtm
   else
   gpu.setForeground(stype == "MILKYWAY" and 4 or stype == "UNIVERSE" and 0 or stype == "PEGASUS" and 3, true)
   local diad, size, mess
   _, _, _, _, _, mess = event.pull("modem_message", card == "modem" and modem.address or card == "tunnel" and tunnel.address)
   diad, size = tbl.unpack(decode(mess))
   pc.beep(400, 0.1)
   os.sleep(0.01)
   if (diad == "abort") then abortm = true
   pc.beep(250, 0.25)
   elseif (diad == "dialed" or diad == "dialing") then goto continue
   pc.beep(600, 0.25)
   pc.beep(600, 0.25)
   else
   diads = serial.unserialize(diad)[1]
    for i, vali in ipairs(add) do
     if (diads[#diads] == vali) then
     local y = 0
      for line in GlyphImages[vali]:gmatch("[^\r\n]+") do
       if (stype == "MILKYWAY" or stype == "PEGASUS") then
       gpu.setForeground(stype == "MILKYWAY" and 4 or stype == "PEGASUS" and 3, true)
       gpu.set((math.fmod(i-1, 3)*(stype == "PEGASUS" and 16 or 15))+1, math.floor((i-1)/3)*8+y+1, line)
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
 diad = tbl.unpack(decode(diad))
 os.sleep(0.01)
 clsmsg()
 gpu.set(1, 25, diad)
  if (diad == "dialed") then
  os.sleep(0.01)
  gdialed = true
  gpu.set(68, 23, "[GDO][ SEND ]")
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
 elseif (stype == "PEGASUS") then
 pgreload()
 end
--mainMD()
end
--send message with address to dial and check dialing status--

--main manual dialing screen--
function mainMD(addr)
if addr ~= nil then add = addr end
local ignor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
 end
 if (stype == "MILKYWAY") then
 mwreload()
 dofile("MWG.ff")
 elseif (stype == "UNIVERSE") then
 unreload()
 dofile("UNG.ff")
 elseif (stype == "PEGASUS") then
 pgreload()
 dofile("PGG.ff")
 end
gpu.set(73, 21, "[ DIAL ]")
 if (gdialed) then
 gpu.set(73, 22, "[ ABORT]")  
 else
 gpu.set(73, 22, "[ CLEAR]")
 end
 gpu.set(73, 25, "[RETURN]") 
  if (add == {}) then
  gpu.set(68, 23, "             ")
  gpu.set(73, 24, "        ")
  else
  if (gdialed) then gpu.set(68, 23, "[GDO][ SEND ]") end
  if (add[#add] == "Point of Origin" or add[#add] == "Glyph 17" or add[#add] == "Subido") then gpu.set(73, 24, "[->BOOK]") end
  end
  if (gdialed and #add>0) or not gdialed then
  while (infflag) do
   for i = 1, #add do
   y = 0
   gpu.setForeground(stype == "MILKYWAY" and (gdialed and 4 or 12) or stype == "UNIVERSE" and (gdialed and 0 or 7) or stype == "PEGASUS" and (gdialed and 3 or 9), true)
    for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
     if (stype == "MILKYWAY" or stype == "PEGASUS") then
     gpu.set((math.fmod(i-1, 3)*(stype == "PEGASUS" and 16 or 15))+1, math.floor((i-1)/3)*8+y+1, line)
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
   pc.beep(500, 0.1)
   pc.beep(1000, 0.1)
   dial()
   goto mainloop
   elseif (x>72 and y==22) then
   abort(_, _, x, y)
   goto mainloop
   elseif (x>72 and y==24) then
   addinbook(card, "dial")
   goto mainloop
   elseif (x<=72 and x>=68 and y==23) then
    if (gdialed) then
    sendmsg("gdo")
    else
    gpu.set(1,25,"Not dialed")
    pc.beep(150, 0.25)
    clsmsgtimerid = event.timer(5, clsmsg)
    end
   elseif (x>72 and y==23) then
    if (gdialed) then
    sendmsg("msg")
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
   if (tun) then card = "tunnel" end
   mainscreen()
   else
    if (stype == "MILKYWAY") then
     if (x>46 and y<20 and #add<9) then
     adcheck = true
      for _, val in ipairs(add) do
       if (val == mwf[y+math.floor((x-47)/17)*19]) then adcheck = false end
      end
      if (adcheck) then
      add[#add+1] = mwf[y+math.floor((x-47)/17)*19]
      gpu.set(math.floor((x-47)/17)*17+47, y, tostring(#add))
      gpu.setForeground(1, true)
      gpu.setBackground(12, true)
       for i = 1, 17 do
       local cha = gpu.get((math.floor((x-46)/17)*17+46+i), y)
       gpu.set((math.floor((x-46)/17)*17+46+i), y, cha)
       end
      local yh = 0
	  gpu.setForeground(12, true)
	  gpu.setBackground(15, true)
       for line in GlyphImages[add[#add]]:gmatch("[^\r\n]+") do
       gpu.set((math.fmod(#add-1, 3)*15)+1, math.floor((#add-1)/3)*8+yh+1, line)
       yh = yh+1
       end
	  gpu.setForeground(0, true)
      gpu.setBackground(15, true)
      end
     pc.beep(300, 0.25)
     end
    elseif (stype == "UNIVERSE") then
     if (x>60 and y<19 and #add<9) then
     adcheck = true
      for _, val in ipairs(add) do
       if (val == unf[y+math.floor((x-61)/10)*18]) then adcheck = false end
      end
      if (adcheck) then
      add[#add+1] = unf[y+math.floor((x-61)/10)*18]
      gpu.set(math.floor((x-61)/10)*10+61, y, tostring(#add))
      gpu.setForeground(8, true)
      gpu.setBackground(7, true)
       for i = 1, 10 do
       local cha = gpu.get((math.floor((x-61)/10)*10+60+i), y)
       gpu.set((math.floor((x-61)/10)*10+60+i), y, cha)
       end
      local yh = 0
      gpu.setForeground(7, true)
	  gpu.setBackground(15, true)
       for line in GlyphImages[add[#add]]:gmatch("[^\r\n]+") do
       gpu.set((math.fmod(#add-1, 9)*6)+3, 4+yh, line)
       yh=yh+1
       end
      gpu.setForeground(0, true)
      gpu.setBackground(15, true)
      end
     pc.beep(300, 0.25)
     end
    elseif (stype == "PEGASUS") then
     if (x>62 and y<19 and #add<9) then
     adcheck = true
      for _, val in ipairs(add) do
       if (val == pgf[y+math.floor((x-63)/9)*18]) then adcheck = false end
      end
      if (adcheck) then
      add[#add+1] = pgf[y+math.floor((x-63)/9)*18]
      gpu.set(math.floor((x-63)/9)*9+63, y, tostring(#add))
      gpu.setForeground(3, true)
      gpu.setBackground(11, true)
       for i = 1, 9 do
       local cha = gpu.get((math.floor((x-63)/9)*9+62+i), y)
       gpu.set((math.floor((x-63)/9)*9+62+i), y, cha)
       end
      local yh = 0
      gpu.setForeground(9, true)
	  gpu.setBackground(15, true)
       for line in GlyphImages[add[#add]]:gmatch("[^\r\n]+") do
       gpu.set((math.fmod(#add-1, 3)*16)+1, math.floor((#add-1)/3)*8+yh+1, line)
       yh=yh+1
       end
	  gpu.setForeground(0, true)
      gpu.setBackground(15, true)
      end
     pc.beep(300, 0.25)
     end
    end
   goto mainloop
   end
  end
 end
end
--main manual dialing screen--

--main screen gate update--
function maingateupdate(_, recev, _, _, _, mess)
if tunfirst then gpu.fill(29, 10, 11, 1, "　") tunfirst = false end
local msg, tstype, state, energy, maxenergy, diaddress, gateaddress, itype, istate = tbl.unpack(decode(mess))
gatestate.itype=itype
gatestate.istate=istate
local ignor = true
 while ignor do
 ignor = event.ignore("modem_message", maingateupdate)
 end
os.sleep(0.2)
gpu.setForeground(8, true)
event.cancel(clsmsgtimerid)
if (tun and recev == tunnel.address) then
 if (msg == "link") then tunnel.send("link") event.listen("modem_message", maingateupdate)
 elseif (msg == "main") then 
 event.listen("modem_message", maingateupdate)
 local ybase = 0 
 local gateadd = serial.unserialize(gateaddress)
 local mainbook
 local addtype = ""
 local mainadd = {}
 local num = 1
 if baseaddflag then
 baseaddflag = false
 end
 local eneper = tostring(tonumber(energy) *100 / tonumber(maxenergy))
  if gatestate.ener ~= tonumber(energy) or gatestate.maxener ~= tonumber(maxenergy) then
  if (energy:find(".") == nil or energy:find(".") == 1) then energy = string.format("%s.000", energy) end
  if (energy:len() - energy:find(".") == 1) then energy = string.format("%s00", energy) end
  gpu.set(34,2, "Energy:")
  gpu.set(34,3, string.format("%s%%", string.sub(energy,1,string.find(energy,'.')+4)))
  gatestate.ener = tonumber(energy)
  gatestate.maxener = tonumber(maxenergy)
  end
 local dialedadd = {}
 local t = 1
 if (diaddress == "[]" and diaddress ~= nil and diaddress ~= "nil") then diaddress = nil else diaddress = string.gsub(string.gsub(diaddress, "%[", ""), "%]", "") end
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
gpu.setForeground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true) 
for line in GateImages["Base"]:gmatch("[^\r\n]+") do
 gpu.set(1, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
local cha = ""
 if (tostring(gatestate.istate) ~= "OPENED") then
 gpu.setForeground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true)
 gpu.setBackground(tostring(gatestate.itype) == "SHIELD" and 0 or tostring(gatestate.itype) == "IRIS_TRINIUM" and 7 or tostring(gatestate.itype) == "IRIS_TITANIUM" and 8, true)
 --local strtmas = {}
 local y = 1
  for line in GateImages.Wormhole:gmatch("[^\r\n]+") do
  gpu.set(math.floor(math.pow(y-9,2)/8+math.pow(y-9,4)/2000+1)+1, y+1, line)
  y=y+1
  end
 gpu.setForeground(0, true)
 gpu.setBackground(15, true)
 gpu.set(62,22,gatestate.istate)
 elseif (state == "open") then
 gpu.setForeground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true) 
 gpu.setBackground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 11 or tstype == "UNIVERSE" and 8, true) 
   local y = 1
  for line in GateImages.Wormhole:gmatch("[^\r\n]+") do
  gpu.set(math.floor(math.pow(y-9,2)/8+math.pow(y-9,4)/2000+1)+1, y+1, line)
  y=y+1
  end
 else
 gpu.setForeground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true) 
 gpu.setBackground(15, true)
 local y = 1
  for line in GateImages.Wormhole:gmatch("[^\r\n]+") do
  gpu.set(math.floor(math.pow(y-9,2)/8+math.pow(y-9,4)/2000+1)+1, y+1, line)
  y=y+1
  end
  if gatestate.itype  ~= "NULL" then 
  gpu.setForeground(0, true)
  gpu.setBackground(15, true) 
  gpu.set(62,22,gatestate.istate)
  end 
 end
 if (dialedadd[#dialedadd] == "Point of Origin" or dialedadd[#dialedadd] == "Glyph 17" or dialedadd[#dialedadd] == "Subido") then 
 ybase = 0
 gpu.setBackground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true) 
 gpu.setForeground(tstype == "MILKYWAY" and 4 or tstype == "PEGASUS" and 3 or tstype == "UNIVERSE" and 0, true)  
 for line in GateImages["ChevOrigin"]:gmatch("[^\r\n]+") do
 gpu.set(18, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
 dialedadd[#dialedadd] = nil
 else
ybase = 0
gpu.setBackground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true) 
gpu.setForeground(tstype == "MILKYWAY" and 12 or tstype == "PEGASUS" and 11 or tstype == "UNIVERSE" and 8, true)
 for line in GateImages["ChevOrigin"]:gmatch("[^\r\n]+") do
 gpu.set(18, ybase+1, line)
 ybase=ybase+1
 end
ybase = 0
 end
 for i = 1, 8 do
 gpu.setForeground(tstype == "MILKYWAY" and (#dialedadd<i and 12 or 4) or tstype == "PEGASUS" and (#dialedadd<i and 11 or 3) or tstype == "UNIVERSE" and (#dialedadd<i and 8 or 0), true) 
 gpu.setBackground((tstype == "MILKYWAY" or tstype == "PEGASUS") and 8 or tstype == "UNIVERSE" and 7, true)
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
 while (state:len()<16) do state = string.format("%s ", state) end
 while (tstype:len()<9) do tstype = string.format("%s ", tstype) end
 gpu.set(34,1, string.format("Type:%s Status:%s", tstype, state))
 if (eneper:find(".") == nil or eneper:find(".") == 1) then eneper = string.format("%s.000", eneper) end
 if (eneper:len() - eneper:find(".") == 1) then eneper = string.format("%s00", eneper) end
 gpu.set(34,2, "Energy:")
 gpu.set(34,3, string.format("%s%%", string.sub(eneper,1,string.find(eneper,'.')+4)))
 for key, val in ipairs(gateadd["UNIVERSE"]) do gateadd["UNIVERSE"][key] = val:gsub("Glyph ", "G") end
 gpu.setForeground(stype == "MILKYWAY" and 1 or stype == "PEGASUS" and 4 or stype == "UNIVERSE" and 8, true)
 gpu.set(46,2,"UNV:")
 gpu.set(51,2,"MILKYWAY:")
 gpu.set(46,11,"PEGASUS:")
 gpu.set(65,11,"DIALED:")
 gpu.setForeground(0, true)
 if (tbl.concat({tbl.concat(gateadd.MILKYWAY), tbl.concat(gateadd.PEGASUS), tbl.concat(gateadd.UNIVERSE)}) ~= tbl.concat({tbl.concat(gatestate.add.MILKYWAY), tbl.concat(gatestate.add.PEGASUS), tbl.concat(gatestate.add.UNIVERSE)})) then
   for key, val in ipairs(gateadd["MILKYWAY"]) do 
   gpu.set(50+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, string.format("│%u", key))
   gpu.set(50+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "│")
    if (val == "Serpens Caput") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Serpens     ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Caput       ")
    elseif (val == "Corona Australis") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Corona      ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Australis   ")
    elseif (val == "Piscis Austrinus") then gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, "Piscis      ") gpu.set(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, "Austrinus   ")
    else
    local vallong = val
    while vallong:len()<12 do vallong = string.format("%s ", vallong) end
    gpu.set(53+math.floor((key-1)/4)*15, 3+math.fmod(key-1, 4)*2, vallong)
    gpu.fill(53+math.floor((key-1)/4)*15, 4+math.fmod(key-1, 4)*2, 6, 1, "　")
    end
   end
   for key, val in ipairs(gateadd["UNIVERSE"]) do
   gpu.set(46,2+key,string.format("│%s",val))
   end
   for key, val in ipairs(gateadd["PEGASUS"]) do
   local vallong = val
   while vallong:len()<8 do vallong = string.format("%s ", vallong) end
   gpu.set(46, 11+key, string.format("│%s", vallong))
   end
   for i = 1, 8 do
   gpu.set(65, 11+i, "│")
   end
  gpu.fill(66,12,14,8," ")
  gatestate.MILKYWAY = {table.unpack(gateadd.MILKYWAY)}
  gatestate.PEGASUS = {table.unpack(gateadd.PEGASUS)}
  gatestate.UNIVERSE = {table.unpack(gateadd.UNIVERSE)}
  end
  if table.concat(gatestate.dialed) ~= table.concat(dialedadd) then
   for key, val in ipairs (dialedadd) do
   if (val ~= "Point of Origin" or val ~= "G17") then
   gpu.set(66, 11+key, val)
   end
  gatestate.dialed = {table.unpack(dialedadd)}
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

--address book screens--
function addglyphshow(gnum, gtype, add)
term.clear()
gpu.set(75,25,"[BACK]")
dofile(gtype == "mw" and "MWG.ff" or gtype == "pg" and "PGG.ff" or gtype == "un" and "UNG.ff")
gpu.setForeground(7, true)
 if gtype == "un" then
 gpu.setForeground(0, true)
 local pos = 0
  for i, v in ipairs(add) do 
  gpu.set((i-1)*8+42-4*(#add+1), 1, tostring(i))
  pos = i
  local hglyph = 1
   for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
   gpu.set((i-1)*8+40-4*(#add+1), hglyph+1, line)
   hglyph=hglyph+1
   end
  end
 gpu.set(pos*8+42-4*(#add+1), 1, tostring(pos+1))
 local hglyph = 1
  for line in GlyphImages["Glyph 17"]:gmatch("[^\r\n]+") do
  gpu.set(pos*8+40-4*(#add+1), hglyph+1, line)
  hglyph=hglyph+1
  end
 else
  for i = 1, 4 do
  local chck = math.floor(math.fmod(i-1, 4)/2) 
  gpu.set(math.fmod(i-1, 4)*20+2+chck*17, 1, "▼││││││▲▼││││││▲", true)
  gpu.set(math.fmod(i-1, 4)*20+1+(1-chck)*19, 1, "▼││││││▲▼││││││▲", true)
  end
 gpu.setForeground(0, true)
  for i = 1, 8 do 
  local chck = math.floor(math.fmod(i-1, 4)/2)
  gpu.set(math.fmod(i-1, 4)*20+1+chck*19, math.floor((i-1)/4)*8+1, tostring(i))
  if add[i] ~= "" and add[i] ~= nil then
   local hglyph = 1
    for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
    gpu.set(math.fmod(i-1, 4)*20+3-chck*1, math.floor((i-1)/4)*8+hglyph, line)
    hglyph=hglyph+1
    end
   end
  end
 local hglyph = 1
  for line in GlyphImages[gtype == "mw" and "Point of Origin" or gtype == "pg" and "Subido"]:gmatch("[^\r\n]+") do
  gpu.set(34, 17+hglyph, line)
  hglyph=hglyph+1
  end
 end
::glshowloop::
local _, _, x, y = event.pull("touch")
 if x >=75 and y == 25 then
 fulladdscreen(gnum)
 else
 goto glshowloop
 end
end

function customdraw(add, gtype)
gpu.fill(1,1,46,25," ")
gpu.fill(1,1,gtype == "mw" and 46 or gtype == "un" and 60 or gtype == "pg" and 62, 25," ")
 for i, v in ipairs(add) do
 local hglyph = 1
  for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
   if gtype == "mw" or gtype == "pg" then
   gpu.setForeground(gtype == "mw" and 4 or gtype == "pg" and 3, true)
   gpu.set((math.fmod(i-1, 3)*(gtype == "pg" and 16 or 15))+1, math.floor((i-1)/3)*8+hglyph+1, line)
   else
   gpu.setForeground(0, true)
   gpu.set((math.fmod(i-1, 9)*6)+3, 4+hglyph, line)
   end
  hglyph=hglyph+1
  end
 end
 if (gtype == "mw") then
 gpu.setForeground(0, true)
 gpu.setBackground(15, true)
  for i, val in ipairs(mwf) do
  local str = string.format("│%s", val)
  while str:len() <= 18 do str = string.format("%s ", str) end
  gpu.set(47+math.floor(i/20)*17, math.fmod(i+math.floor(i/20), 20), str)
  end
 gpu.set(47, 20, "└────────────────┴────────────────")
  for i, v in ipairs(add) do
   for num, glyph in ipairs(mwf) do
    if glyph == v then
    local x = math.floor(((num-1)/19))*17+47
    local y = math.fmod(num-1, 19)+1
    gpu.setForeground(1, true)
    gpu.setBackground(12, true)
    gpu.set(x, y, string.format("%u%s",i,v))
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    break
    end
   end
  end
 elseif (gtype == "un") then
 gpu.setForeground(0, true)
 gpu.setBackground(15, true)
  for i, val in ipairs(unf) do
  local str = string.format("│%s", val)
  while str:len() <= 11 do str = string.format("%s ", str) end
  gpu.set(61+math.floor(i/19)*10, math.fmod(i+math.floor(i/19), 19), str)
  end
 gpu.set(61, 19, "└─────────┴─────────")
  for i, v in ipairs(add) do
   for num, glyph in ipairs(unf) do
    if glyph == v then
    local x = math.floor(((num-1)/18))*10+61
    local y = math.fmod(num-1, 18)+1
    gpu.setForeground(8, true)
    gpu.setBackground(7, true)
    gpu.set(x, y, string.format("%u%s",i,v))
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    break
    end
   end
  end
 elseif (gtype == "pg") then
 gpu.setForeground(0, true)
 gpu.setBackground(15, true)
  for i, val in ipairs(pgf) do
  local str = string.format("│%s", val)
  while str:len() <= 10 do str = string.format("%s ", str) end
  gpu.set(63+math.floor(i/19)*9, math.fmod(i+math.floor(i/19), 19), str)
  end
 gpu.set(63, 19, "└────────┴────────")
  for i, v in ipairs(add) do
   for num, glyph in ipairs(pgf) do
    if glyph == v then
    local x = math.floor(((num-1)/18))*9+63
    local y = math.fmod(num-1, 18)+1
    gpu.setForeground(3, true)
    gpu.setBackground(11, true)
    gpu.set(x, y, string.format("%u%s",i,v))
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    break
    end
   end
  end
 end
end

function customadd(gnum, gtype)
term.clear()
if (gtype == "mw") then
 mwreload()
 dofile("MWG.ff")
 elseif (gtype == "un") then
 unreload()
 dofile("UNG.ff")
 elseif (gtype == "pg") then
 pgreload()
 dofile("PGG.ff")
 end
dofile(gtype == "mw" and "MWG.ff" or gtype == "pg" and "PGG.ff" or gtype == "un" and "UNG.ff")
local add = {}
 for i, v in ipairs(addbook[gnum][gtype == "mw" and "MILKYWAY" or gtype == "pg" and "PEGASUS" or gtype == "un" and "UNIVERSE"]) do
 add[i]=v
 end
 add[#add+1] = (gtype == "mw" and "Point of Origin" or gtype == "pg" and "Subido" or gtype == "un" and "Glyph 17")
 for i, v in ipairs(add) do
 local hglyph = 1
   for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
    if gtype == "mw" or gtype == "pg" then
    gpu.setForeground(gtype == "mw" and 4 or gtype == "pg" and 3, true)
    gpu.set((math.fmod(i-1, 3)*(gtype == "pg" and 16 or 15))+1, math.floor((i-1)/3)*8+hglyph+1, line)
    else
    gpu.setForeground(0, true)
    gpu.set((math.fmod(i-1, 9)*6)+3, 4+hglyph, line)
    end
   hglyph=hglyph+1
   end
 end
customdraw(add, gtype)
gpu.set(68,23,"[REMOVE LAST]")
gpu.set(66,24,"[EXIT W/O SAVE]")
gpu.set(68,25,"[SAVE & EXIT]")
::customloop::
local _, _, x, y = event.pull("touch")
 if x >=66 and y == 24 then
 fulladdscreen(gnum)
 elseif x >=68 and y == 25 then
  if add[#add] == "Point of Origin" or add[#add] == "Subido" or add[#add] == "Glyph 17" then
  tbl.remove(add)
  addbook[gnum][gtype == "mw" and "MILKYWAY" or gtype == "pg" and "PEGASUS" or gtype == "un" and "UNIVERSE"]={tbl.unpack(add)}
  fulladdscreen(gnum)
  else
  gpu.set(1,25,"Missed PoO")
  os.sleep(1)
  gpu.set(1,25,"          ")
  goto customloop
  end
 elseif x >=68 and y == 23 and #add > 0 then
 tbl.remove(add)
 customdraw(add, gtype)
 goto customloop
 else
  if (gtype == "mw") then
   if (x>46 and y<20 and #add<9) then
   adcheck = true
    for _, val in ipairs(add) do
     if (val == mwf[y+math.floor((x-47)/17)*19]) then adcheck = false end
    end
    if (adcheck) then
    add[#add+1] = mwf[y+math.floor((x-47)/17)*19]
    gpu.set(math.floor((x-47)/17)*17+47, y, tostring(#add))
    gpu.setForeground(1, true)
    gpu.setBackground(12, true)
     for i = 1, 17 do
     local cha = gpu.get((math.floor((x-46)/17)*17+46+i), y)
     gpu.set((math.floor((x-46)/17)*17+46+i), y, cha)
     end
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    end
    for i, v in ipairs(add) do
    local hglyph = 1
     for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
     gpu.setForeground(4, true)
     gpu.set((math.fmod(i-1, 3)*15)+1, math.floor((i-1)/3)*8+hglyph+1, line)
     hglyph=hglyph+1
     end
    end
   pc.beep(300, 0.25)
   end
  elseif (gtype == "un") then
   if (x>60 and y<19 and #add<9) then
   adcheck = true
    for _, val in ipairs(add) do
     if (val == unf[y+math.floor((x-61)/10)*18]) then adcheck = false end
    end
    if (adcheck) then
    add[#add+1] = unf[y+math.floor((x-61)/10)*18]
    gpu.set(math.floor((x-61)/10)*10+61, y, tostring(#add))
    gpu.setForeground(8, true)
    gpu.setBackground(7, true)
     for i = 1, 10 do
     local cha = gpu.get((math.floor((x-61)/10)*10+60+i), y)
     gpu.set((math.floor((x-61)/10)*10+60+i), y, cha)
     end
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    end
    for i, v in ipairs(add) do
    local hglyph = 1
     for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
     gpu.setForeground(0, true)
     gpu.set((math.fmod(i-1, 9)*6)+3, 4+hglyph, line)
     hglyph=hglyph+1
     end
    end
   pc.beep(300, 0.25)
   end
   elseif (gtype == "pg") then
   if (x>62 and y<19 and #add<9) then
   adcheck = true
    for _, val in ipairs(add) do
     if (val == pgf[y+math.floor((x-63)/9)*18]) then adcheck = false end
    end
    if (adcheck) then
    add[#add+1] = pgf[y+math.floor((x-63)/9)*18]
    gpu.set(math.floor((x-63)/9)*9+63, y, tostring(#add))
    gpu.setForeground(3, true)
    gpu.setBackground(11, true)
     for i = 1, 9 do
     local cha = gpu.get((math.floor((x-63)/9)*9+62+i), y)
     gpu.set((math.floor((x-63)/9)*9+62+i), y, cha)
     end
    gpu.setForeground(0, true)
    gpu.setBackground(15, true)
    end
    for i, v in ipairs(add) do
    local hglyph = 1
     for line in GlyphImages[add[i]]:gmatch("[^\r\n]+") do
     gpu.setForeground(3, true)
     gpu.set((math.fmod(i-1, 3)*16)+1, math.floor((i-1)/3)*8+hglyph+1, line)
     hglyph=hglyph+1
     end
    end
   pc.beep(300, 0.25)
   end
  else
  goto customloop
  end
 goto customloop
 end
end

function fulladdscreen(gnum)
term.clear()
gpu.setForeground(0, true)
gpu.setBackground(15, true)
gpu.set(80,1,"╳")
local ginfo = {}
ginfo.name = addbook[gnum].name
ginfo.MILKYWAY = addbook[gnum].MILKYWAY
ginfo.PEGASUS = addbook[gnum].PEGASUS
ginfo.UNIVERSE = addbook[gnum].UNIVERSE
ginfo.AURD = addbook[gnum].AURD
ginfo.gtype = addbook[gnum].gtype
ginfo.gdo = addbook[gnum].gdo
local nm = ginfo.name
gpu.set(41-math.floor(#nm/2),1,nm)
gpu.set(22,1,"[◄]")
gpu.set(57,1,"[►]")
gpu.fill(1,2,80,1,"━")
gpu.fill(1,23,80,1,"━")
gpu.fill(1,14,37,1,"━")
gpu.fill(1,4,37,1,"━")
gpu.set(17,4,"┯│││││││││┷", true)
gpu.set(27,4,"┯│││││││││┷", true)
gpu.set(37,2,"┳┃┫┃┃┃┃┃┃┃┃┃┛", true) --REPAIR
gpu.set(1,3,"Address:")
gpu.set(1,5,"MILKYWAY:")
gpu.set(18,5,"PEGASUS:")
gpu.set(28,5,"UNIVERSE:")
 if tbl.concat(ginfo.MILKYWAY) == "" then
 gpu.set(7, 9, "NULL")
 else
  for i, v in ipairs(ginfo.MILKYWAY) do
  gpu.set(1, i+5, v)
  end
 end
 if tbl.concat(ginfo.PEGASUS) == "" then
 gpu.set(21, 9, "NULL")
 else
  for i, v in ipairs(ginfo.PEGASUS) do
  gpu.set(18, i+5, v)
  end
 end
 if tbl.concat(ginfo.UNIVERSE) == "" then
 gpu.set(30, 9, "NULL")
 else
  for i, v in ipairs(ginfo.UNIVERSE) do
  gpu.set(28, i+5, v)
  end
 end
gpu.set(6,15,"[SHOW]")
gpu.set(20,15,"[SHOW]")
gpu.set(29,15,"[SHOW]")
 if not ginfo.AURD then
 gpu.set(6,16,"[EDIT]")
 gpu.set(20,16,"[EDIT]")
 gpu.set(29,16,"[EDIT]")
 end
gpu.set(51,20,"Latest GDO code:") 
gpu.set(51,22,tostring(ginfo.gdo))
gpu.set(68,19,string.format("SEND%s[NEARBY]", tun and "┬" or "─"))
if tun then gpu.set(72,20,"└[ MAIN ]") end
gpu.fill(51,18,30,1,"━")
gpu.fill(51,21,30,1,"━")
gpu.fill(51,23,30,1,"━")
gpu.set(50,18,"┏┃┃┣┃┻",true)
gpu.set(38, 3, string.format("Gate type: %s", ginfo.gtype))
gpu.set(38, 4, string.format("AURD status: %s", ginfo.AURD and "CONNECTED" or "NOT CONNECTED"))
gpu.set(1, 20,"Nearby gate: [DIAL] [ABORT] [GDO]")
 if tun then
 gpu.set(1, 21,"Main gate: [DIAL] [ABORT] [GDO]")
 end
gpu.set(73,3,"[RENAME]")
gpu.set(73,4,"[DELETE]")
::fulladdloop::
local _, _, xmenu, ymenu = event.pull("touch")
 if (xmenu==80 and ymenu== 1) then
 addscreen(1, false)
 elseif (xmenu >=75 and ymenu == 19) then
 modem.send(madd, 100, "iopensend", addbook[gnum].gdo)
 gpu.set(1,25,"Good luck.")
 os.sleep(1)
 gpu.fill(1,25,10,1," ")
 elseif (xmenu >=75 and ymenu == 20 and tun) then
 tunnel.send("iopensend", addbook[gnum].gdo)
 gpu.set(1,25,"Good luck.")
 os.sleep(1)
 gpu.fill(1,25,10,1," ")
 elseif (xmenu >=14 and xmenu <=33 and xmenu ~= 20 and xmenu ~= 28 and ymenu == 20) then
 term.clear()
 linklist = {}
 modem.broadcast(100, "link")
 gpu.set(28, 12, "Waiting for connection")
 event.listen("modem_message", nmdlink)
 os.sleep(2)
 event.ignore("modem_message", nmdlink)
 local distance = 100
  if #linklist == 0 then
  gpu.set(23, 12, "No gate detected within 20 blocks")
  pc.beep(100, 2)
  os.sleep(2)
  term.clear()
  fulladdscreen(gnum)
  else
   local madd, msg, state, stateadd
   for _, val in ipairs(linklist) do
    if val["ldis"]<distance then madd = val["lmadd"] distance = val["ldis"] msg = val["lmsg"] state = val["lstate"] stateadd = val["lstateadd"] end
   end
   if distance>20 then
   gpu.set(23, 12, "No gate detected within 20 blocks")
   pc.beep(100, 2)
   os.sleep(2)
   term.clear()
   fulladdscreen(gnum)
   else
   pc.beep(500, 0.25)
   os.sleep(2)
    if state == nil then
    term.clear()
    gpu.set(14, 12, "ERROR. Something wrong. Going back to previous screen.")
    os.sleep(2)
    fulladdscreen(gnum)
    elseif (xmenu >=14 and xmenu <=19 and state == "idle") then
    local add = {}
     for i, v in ipairs(addbook[gnum][msg]) do
     add[i]=v
     end
    add[#add+1] = msg == "MILKYWAY" and "Point of Origin" or msg == "PEGASUS" and "Subido" or msg == "UNIVERSE" and "Glyph 17"
    os.sleep(0.2)
    modem.send(madd, 100, "add", serial.serialize(add))
    _, _, _, _, _, mess = event.pull("modem_message")
    dmsg, size = tbl.unpack(decode(mess))
     if dmsg ~= "dialing" then
     term.clear()
     gpu.set(14, 12, string.format("ERROR. %s", dmsg))
     os.sleep(2)
     end
    fulladdscreen(gnum)
    elseif (xmenu >=21 and xmenu <=27) then
    modem.send(madd, 100, "abort")
    fulladdscreen(gnum)
    elseif (xmenu >=29 and xmenu <=33 and state == "open") then
    term.clear()
    gpu.set(29,12,"Write GDO code. Max: 30.")
    term.setCursor(1,13)
    messread(30)
    modem.send(madd, 100, "iopensend", iomessage)
    addbook[gnum].gdo = iomessage
    gpu.set(36,14,"Good luck.")
    os.sleep(2)
    fulladdscreen(gnum)
    else 
    term.clear()
    gpu.set(15,12,"ERROR. Gate is busy. Going back to previous screen.")
    os.sleep(2)
    fulladdscreen(gnum)
    end
   end
  end
 fulladdscreen(gnum)
 elseif (xmenu >=12 and xmenu <=31 and xmenu ~= 18 and xmenu ~= 26 and ymenu == 21) then
 term.clear()
 tunnel.send("link")
 local _, _, _, _, _, mess = event.pull("modem_message")
 local _, stype, state, _, _, stateadd, _ = tbl.unpack(decode(mess))
  if state == nil then
  term.clear()
  gpu.set(14, 12, "ERROR. Something wrong. Going back to previous screen.")
  os.sleep(2)
  fulladdscreen(gnum)
  elseif (xmenu >=12 and xmenu <=17 and state == "idle") then
  local add = {}
   for i, v in ipairs(addbook[gnum][stype]) do
   add[i]=v
   end
  add[#add+1] = stype == "MILKYWAY" and "Point of Origin" or stype == "PEGASUS" and "Subido" or stype == "UNIVERSE" and "Glyph 17"
  os.sleep(0.2)
  tunnel.send("add", serial.serialize(add))
  _, _, _, _, _, mess = event.pull("modem_message", tunnel.address)
  dmsg, size = tbl.unpack(decode(mess))
   if dmsg ~= "dialing" then
   term.clear()
   gpu.set(14, 12, string.format("ERROR. %s", dmsg))
   os.sleep(2)
   end
  fulladdscreen(gnum)
  elseif (xmenu >=19 and xmenu <=25) then
  tunnel.send("abort")
  fulladdscreen(gnum)
  elseif (xmenu >=27 and xmenu <=31 and state == "open") then
  term.clear()
  gpu.set(29,12,"Write GDO code. Max: 30.")
  term.setCursor(1,13)
  messread(30)
  tunnel.send("iopensend", iomessage)
  addbook[gnum].gdo = iomessage
  gpu.set(36,14,"Good luck.")
  os.sleep(2)
  fulladdscreen(gnum)
  else 
  term.clear()
  gpu.set(15,12,"ERROR. Gate is busy. Going back to previous screen.")
  os.sleep(2)
  fulladdscreen(gnum)
  end
 fulladdscreen(gnum)
 elseif (xmenu >=73 and ymenu == 3) then
 ::fullinforenameloop::
 gpu.set(1,24,"Write new name (English only. Max: 30): ")
 term.setCursor(41, 24)
 messread(30)
  if iomessage == "" then
  gpu.fill(1,24,80,1," ")
  gpu.set(1,24,"Name cannot be empty")
  os.sleep(1)
  gpu.fill(1,24,40,1," ")
  goto fullinforenameloop
  else
  addbook[gnum]["name"] = iomessage
  abookupd(addbook)
  fulladdscreen(math.min(gnum, #addbook))
  end
 elseif (xmenu >=73 and ymenu == 4) then
 gpu.set(1,24,"Are you sure? Y/N: ")
 term.setCursor(20, 24)
 messread(1)
 gpu.fill(1,24,80,1," ")
  if iomessage == "Y" or iomessage == "y" then
  tbl.remove(addbook, gnum)
  abookupd(addbook)
  fulladdscreen(gnum)
  end
 elseif (xmenu >=6 and xmenu <=11 and ymenu == 15) then
 addglyphshow(gnum, "mw", addbook[gnum]["MILKYWAY"])
 elseif (xmenu >=20 and xmenu <=25 and ymenu == 15) then
 addglyphshow(gnum, "pg", addbook[gnum]["PEGASUS"])
 elseif (xmenu >=29 and xmenu <=34 and ymenu == 15) then
 addglyphshow(gnum, "un", addbook[gnum]["UNIVERSE"])
 elseif (xmenu >=6 and xmenu <=11 and ymenu == 16 and not ginfo.AURD) then
 customadd(gnum, "mw")
 elseif (xmenu >=20 and xmenu <=25 and ymenu == 16 and not ginfo.AURD) then
 customadd(gnum, "pg")
 elseif (xmenu >=29 and xmenu <=34 and ymenu == 16 and not ginfo.AURD) then
 customadd(gnum, "un")
 elseif (xmenu <=24 and xmenu >=22 and ymenu == 1) then
 fulladdscreen(math.max(1, gnum-1))
 elseif (xmenu <=59 and xmenu >=57 and ymenu == 1) then
 fulladdscreen(math.min(gnum+1, #addbook))
 else
 goto fulladdloop
 end
end

function addscreen(p, bool)
term.clear()
while(event.ignore("modem_message", maingateupdate)) do os.sleep(0) end
if bool then mainaddupd() end
gpu.setForeground(0, true)
gpu.setBackground(15, true)
gpu.fill(1,2,80,1,"━")
gpu.fill(1,23,80,1,"━")
gpu.fill(40,3,1,20,"┃")
gpu.set(40,2,"┳")
gpu.set(80,2,"⣶")
gpu.set(80,23,"⠿")
gpu.set(80,3,"△")
gpu.set(80,22,"▽")
gpu.set(35,1,"ADDRESS BOOK")
gpu.set(1,1, string.format("Shown: %04u-%04u from %04u", p*2-1, math.min(p*2+12, #addbook), #addbook))
local n = p
gpu.fill(40,3,1,20,"┃")
 for i = 1, math.min(#addbook-(n-1)*2, 14) do
 gpu.fill(math.fmod(i-1, 2)*40+1, math.floor((i-1)/2)*3+5, 39, 1, "━")
 gpu.set((math.fmod(i-1, 2)+1)*40, math.floor((i-1)/2)*3+5, math.fmod(i, 2) == 1 and "┫" or "")
 if math.fmod(i-1, 2) == 1 then gpu.set(40, math.floor(i/2)*3+2, "╋") end
 gpu.set(40,23,"┻")
 gpu.set(math.fmod(i-1, 2)*40+33, math.floor((i-1)/2)*3+2, i<3 and "┯││┷" or "┿││┷", true)
 gpu.set(math.fmod(i-1, 2)*40+34, math.floor((i-1)/2)*3+3, "RENAME")
 gpu.set(math.fmod(i-1, 2)*40+34, math.floor((i-1)/2)*3+4, "DELETE")
 local str = addbook[i+(n-1)*2]["name"]
 local gt = addbook[i+(n-1)*2]["gtype"]
 gpu.setForeground(gt == "MILKYWAY" and 1 or gt == "PEGASUS" and 3 or gt == "UNIVERSE" and 8 or 0, true)
  while #str < 30 do
  str = string.format(math.fmod(#str, 2) == 0 and "%s " or " %s", str)
  end
 gpu.set(math.fmod(i-1, 2)*40+1, math.floor((i-1)/2)*3+3, str)
 gpu.set(math.fmod(i-1, 2)*40+1, math.floor((i-1)/2)*3+4, string.format("Type: %s", gt))
 gpu.setForeground(0, true)
 end
local ns = math.min(14/#addbook, 1)
local nh = math.floor((1-ns)*72*(n-1)/(math.max(math.floor((#addbook-13)/2), 1)))
local nl = nh + ns * 72
 for i = 1, 18 do
  if i*4 <= nh or i*4 > nl then gpu.set(80, i+3, " ")
  elseif i*4-nh >= 4 and i*4-nl <= 0 then gpu.set(80, i+3, "⣿")
  elseif i*4-nl <= 0 then gpu.set(80, i+3, i*4-nh == 3 and "⣶" or i*4-nh == 2 and "⣤" or "⣀")
  elseif i*4-nh >= 4 then gpu.set(80, i+3, i*4-nl == 1 and "⠿" or i*4-nl == 2 and "⠛" or "⠉")
  elseif i*4-nh == 1 and i*4-nl == 2  then gpu.set(80, i+3, "⠒")
  elseif i*4-nh == 1 and i*4-nl == 1  then gpu.set(80, i+3, "⠶")
  elseif i*4-nh == 2 and i*4-nl == 1  then gpu.set(80, i+3, "⠤")
  end
 end
 gpu.setBackground(15, true)
gpu.set(80,1,"╳")
::scrollloop::
local _, _, xmain, ymain = event.pull("touch")
 if (xmain==80 and ymain == 1) then
 term.clear()
 event.listen("modem_message", maingateupdate)
 mainscreen()
 elseif (xmain==80 and ymain == 3) then
 n=math.max(1, n-1)
 addscreen(n, false)
 elseif (xmain==80 and ymain == 22) then
 n=math.min(n+1, math.floor((#addbook-11)/2))
 addscreen(n, false)
 elseif (math.fmod(xmain, 40)<=39 and math.fmod(xmain, 40)>33 and ymain > 2 and ymain <23) then
  if math.fmod(ymain, 3) == 0 then
  ::bookrenameloop::
  gpu.set(1,24,"Write new name (English only. Max: 30): ")
  term.setCursor(41, 24)
  messread(30)
   if iomessage == "" then
   gpu.fill(1,24,80,1," ")
   gpu.set(1,24,"Name cannot be empty")
   os.sleep(1)
   gpu.fill(1,24,40,1," ")
   goto bookrenameloop
   else
   addbook[math.floor(xmain/40)+2*(math.floor(ymain/3)-1)+2*p-1]["name"] = iomessage
   abookupd(addbook)
   addscreen(p, false)
   end
  elseif math.fmod(ymain, 3) == 1 then
  gpu.set(1,24,"Are you sure? Y/N: ")
  term.setCursor(20, 24)
  messread(1)
  gpu.fill(1,24,80,1," ")
   if iomessage == "Y" or iomessage == "y" then
   tbl.remove(addbook, math.floor(xmain/40)+2*(math.floor(ymain/3)-1)+2*p-1)
   abookupd(addbook)
   addscreen(p, false)
   end
  end
 goto scrollloop
 elseif (math.fmod(xmain, 40)<33 and math.fmod(xmain, 40)>0 and ymain > 2 and ymain <23 and math.fmod(ymain, 3) < 2) then
 fulladdscreen(math.floor(xmain/40)+2*(math.floor(ymain/3)-1)+2*p-1)
 else
 goto scrollloop
 end
end
--address book screens--

--main screen--
function mainscreen()
 while true do
 os.sleep(0)
 term.clear()
 linklist = {}
 event.ignore("touch", abort)
 add = {}
  if (tun) then
  while(event.ignore("modem_message", maingateupdate)) do os.sleep(0) end
  tunnel.send("link")
  gpu.set(29, 10, "Stabilising connection")
  tunfirst = true
  event.listen("modem_message", maingateupdate)
  end
 gpu.setForeground(0, true)
 gpu.fill(1,20,80,1,"─")
 gpu.fill(1,23,80,1,"─")
 local str = "┬││┴"
 gpu.set(15,20,str,true)
 gpu.set(25,20,str,true)
 gpu.set(43,20,str,true)
 gpu.set(1,21,"►SORT CHANGE◄")
 gpu.set(16,21,"◣ADDRESS◢")
 gpu.set(16,22,"◤ BOOK  ◥")
 gpu.setForeground(8, true)
 gpu.set(26,21,"MANUAL")
 gpu.set(27,22,"DIAL")
 gpu.setForeground(0,true)
 gpu.set(33,21,"►NEARBY◄")
  if tun then 
  gpu.set(1,22,"►SEND MESSAGE◄")
  gpu.set(32,22,"►MAIN GATE◄")
  gpu.setForeground(8,true)
   if tostring(gatestate.itype) == "NULL" or gatestate.itype == nil then
   gpu.set(51,21,"MAIN GATE IRIS")
   gpu.set(52,22,"NOT DETECTED")
   else
   gpu.set(44,21,"MAIN GATE")
   gpu.set(46,22,"IRIS")
   gpu.setForeground(0,true)
   gpu.set(54,21,"►OPEN◄")
   gpu.set(53,22,"►CLOSE◄")
   gpu.set(60,20,str,true)
   gpu.setForeground(8,true)
   gpu.set(61,21,"IRIS STATE")
   end
  else
  gpu.setForeground(8,true)
  gpu.set(53,21,"MAIN GATE")
  gpu.set(52,22,"NOT DETECTED")
  end
 gpu.set(80,1,"╳")
 gpu.setForeground(0,true)
 gpu.set(71,20,str,true)
 ::mainscreenbutton::
 os.sleep(0)
 card = ""
 local _, _, xmain, ymain = event.pull("touch")
  if (xmain<13 and ymain == 21) then
  sortchoose(true)
  mainscreen()
  elseif (xmain==80 and ymain == 1) then
  term.clear()
  event.ignore("modem_message", maingateupdate)
  os.exit()
  elseif (xmain<13 and ymain == 22 and tun) then
  gpu.setBackground(0, true)
  gpu.setForeground(15, true)
  gpu.fill(1,24,80,2,"　")
  gpu.set(1,24,"Message:")
  term.setCursor(9,24)
  local msgtimed
  messread(56)
  gpu.setBackground(15, true)
  gpu.setForeground(0, true)
  gpu.fill(1,24,80,2,"　")
  tunnel.send("mess", iomessage)
  goto mainscreenbutton
  elseif (xmain>31 and xmain<43 and ymain == 22) then
  term.clear()
  event.ignore("modem_message", maingateupdate)
  gpu.setForeground(0, true)
  card = "tunnel"
  nearbyMDlink()
  elseif (xmain>31 and xmain<43 and ymain == 21) then
  term.clear()
  event.ignore("modem_message", maingateupdate)
  gpu.setForeground(0, true)
  card = "modem"
  nearbyMDlink()
  elseif (xmain<25 and xmain>15 and ymain<23 and ymain>20) then
  term.clear()
  addscreen(1, tun)
  elseif (xmain>53 and xmain<60 and ymain == 21 and tun and not (tostring(gatestate.itype) == "NULL" or gatestate.itype == nil)) then
  tunnel.send("iopen")
  elseif (xmain>53 and xmain<61 and ymain == 22 and tun and not (tostring(gatestate.itype) == "NULL" or gatestate.itype == nil)) then
  tunnel.send("iclose")
  else
  goto mainscreenbutton
  end
 event.listen("modem_message", maingateupdate)
 end
end
--main screen--

--start program--
if (infflag) then
modem.open(100)
modem.setStrength(50)
term.clear()
mainscreen()
end
--start program--
