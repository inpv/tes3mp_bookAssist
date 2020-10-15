--[[ 
-- heavily modelled after Atkana's decoratorsAid ( https://github.com/Atkana/ )
-- idea & placement calculations taken from Book Rotate by Cydine & Maboroshi Daikon ( http://mw.modhistory.com/download-11-6953) and Hephs Book Rotate System (http://morrowind.heph.org/)
-- author: Buntnessel / Falas on TES3MP discord 

-- functionality:
like a very lightweight BookRotate, this script places books vertically upright with the spines facing the player.
it basically allows you to put most books on a shelf neatly.

-- usage:
set a height value for bookAssist to get it working; I'd recommend 14. meaning: type /ba 14 in chat. This height offsets the problem that books get placed in the middle of shelfs instead of on them.  
--14 height works for most books, larger ones can require 20 or 21.
typing either /ba 0 or /bookassist 0 in the chat window will turn it off again.
it won't place scrolls or open books properly, for this functionality you'll have to look towards the aforementioned Book Rotate. When placing such books I'd recommend turning
bookAssist off by typing /ba 0 in chat.
 

-- how the script works:
listen for OnObjectPlace (so, if a player is placing something)
check if placedobject is book (stringcheck for common references that contain "book", "_Bk", and so on
if yes, save the book's UniqueID to a custom variable attached to the player
then calculate which direction the player is facing and according to this, place the book
by deleting the book the player placed and replacing it with a exact copy with different position & rotation values


0.7.0 installation:

  1. Place the script into server/scripts/custom directory.
  2. Add a line:
  bookAssist = require("custom.bookAssist") in server/scripts/customScripts.lua

]]

-- ported and modified by inpv for 0.7.0-alpha

local bookAssist = {}


function bookAssist.Command(pid,cmd) -- helper function to parse command arguments

  if (cmd[1] == "bookassist" or cmd[1] == "ba") then
    targetHeight = tonumber(cmd[2])
    bookAssist.OnCommand(pid, targetHeight)
  end
end


function bookAssist.OnCommand(pid, targetHeight)

  if targetHeight == 0 then
    --0 is used to turn the script off - its useless without height adjustment anyways
    Players[pid].data.customVariables.bookAssistState = 0
    Players[pid]:Save()
    message = "Turning bookAssist off\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
  else 

    Players[pid].data.customVariables.bookAssistState = 1
    Players[pid].data.customVariables.bookAssistHeight = targetHeight
    Players[pid]:Save()

    tes3mp.LogMessage(enumerations.log.INFO, "[bookAssist] setting height to " .. targetHeight)
    message = "bookAssist height set to: " .. targetHeight .. "\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)

  end 
end


--listen for object placement events, get their data, then check if they're concerning books
function bookAssist.OnObjectPlace (pid, cellDescription)
--check if the functionality is on

  local checkvariable = tonumber(Players[pid].data.customVariables.bookAssistState)

  if checkvariable == 1 then

    local refId = tes3mp.GetObjectRefId(0)
    local cellId = tes3mp.GetCell(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "[bookAssist] listening in for: refid = " .. tes3mp.GetObjectRefId(0))
    --check if object is a book
    if ((string.match(tes3mp.GetObjectRefId(0), "bk_")) or (string.match(tes3mp.GetObjectRefId(0), "mr_book_")) or (string.match(tes3mp.GetObjectRefId(0), "T_Bk_")) or (string.match(tes3mp.GetObjectRefId(0), "book")) or (string.match(tes3mp.GetObjectRefId(0), "Book"))) then

      --construct and append the unique index of the book
      bookUniqueIndex = tes3mp.GetObjectRefId(0) .. "-" .. tes3mp.GetObjectMpNum(0)

      --save the unique index to a custom variable on the player
      Players[pid].data.customVariables.bookAssistBook = bookUniqueIndex
      Players[pid]:Save()

      selectedBookRef = tes3mp.GetObjectRefId(0)
      selectedBookMpnum = tes3mp.GetObjectMpNum(0)

      bookAssist.objectsUpdate(pid)
    end
  end
end


function bookAssist.objectsUpdate (pid)
-- check if we're turned on

  local	checkvariable = tonumber(Players[pid].data.customVariables.bookAssistState)

  if checkvariable == 1 then

    -- unique id reference: 0-127 , 0 for placed by the server, -127 is the mpnum. 
    -- every object that's once picked up and placed by the player gets such an unique identifier, therefore when loading celldata
    -- we only care about this unique id

    local cell = tes3mp.GetCell(pid)
    local splitIndex = Players[pid].data.customVariables.bookAssistBook:split("-")
    local uid = "0-" .. splitIndex[2]

    tes3mp.LogMessage(enumerations.log.INFO, "[bookAssist] constructs the following unique identifier for it: " .. uid)
    tes3mp.LogMessage(enumerations.log.INFO, "[bookAssist] incidentially, bookAssits state is set to " .. Players[pid].data.customVariables.bookAssistState)

    --load the object
    local object = LoadedCells[cell].data.objectData[uid]

    local refId = object.refId
    local count = object.count or 1
    local charge = object.charge or -1
    local posX, posY, posZ = object.location.posX, object.location.posY, object.location.posZ
    local rotX, rotY, rotZ = object.location.rotX, object.location.rotY, object.location.rotZ
    local refIndex = uid


    --implementation of the book rotate script
    --tes3mp uses radians instead of degrees for positions and rotations

    playerZ = tes3mp.GetRotZ(pid)
    playerZ = math.deg(playerZ) 

    faceDirection = 0

    if playerZ < 0 then
      playerZ = 360 + playerZ
    end
    
    -- rotate the book so that the spine always faces the player
    
    rotX = 270
    rotY = 270 + playerZ
    rotZ = 0

    rotX = math.rad(rotX)
    rotY = math.rad(rotY)
    rotZ = math.rad(rotZ)

    if Players[pid].data.customVariables.bookAssistHeight then
      height = Players[pid].data.customVariables.bookAssistHeight
    else
      height = 13
    end

    for pid, pdata in pairs(Players) do
      if Players[pid]:IsLoggedIn() then
        --First, delete the original
        tes3mp.InitializeEvent(pid)
        tes3mp.SetEventCell(cell)
        tes3mp.SetObjectRefNumIndex(0)
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.AddWorldObject() --?
        tes3mp.SendObjectDelete()

        --Now remake it and send the information to the online players
        tes3mp.InitializeEvent(pid)
        tes3mp.SetEventCell(cell)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectCount(count)
        tes3mp.SetObjectCharge(charge)
        tes3mp.SetObjectPosition(posX, posY, posZ+height)
        tes3mp.SetObjectRotation(rotX, rotY, rotZ)
        tes3mp.SetObjectRefNumIndex(0)
        tes3mp.SetObjectMpNum(splitIndex[2])

        if inventory then
          for itemIndex, item in pairs(inventory) do
            tes3mp.SetContainerItemRefId(item.refId)
            tes3mp.SetContainerItemCount(item.count)
            tes3mp.SetContainerItemCharge(item.charge)

            tes3mp.AddContainerItem()
          end
        end

        tes3mp.AddWorldObject()
        tes3mp.SendObjectPlace()

        if inventory then
          tes3mp.SendContainer()
        end   
      end
    end

    -- save rotation and z values in the cell json

    LoadedCells[cell].data.objectData[uid].location.rotX = rotX
    LoadedCells[cell].data.objectData[uid].location.rotY = rotY
    LoadedCells[cell].data.objectData[uid].location.rotZ = rotZ
    LoadedCells[cell].data.objectData[uid].location.posZ = posZ+height

    LoadedCells[cell]:Save() 


    return objectsUpdate
  end
end


customEventHooks.registerHandler("OnObjectPlace", function(eventStatus, pid) -- registered handler for easy 0.7.0 usage
    if eventStatus.validCustomHandlers then
      bookAssist.OnObjectPlace(pid, cellDescription)
    end
  end)

customCommandHooks.registerCommand("ba", bookAssist.Command) -- added custom hooks for convenience
customCommandHooks.registerCommand("bookassist", bookAssist.Command)

return bookAssist

