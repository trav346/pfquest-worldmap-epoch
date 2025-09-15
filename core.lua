-- Completely separate pin system for continent view to avoid conflicts with pfQuest's zone pins

local original_UpdateNodes = pfMap.UpdateNodes
local continentPins = {}  -- Our own separate pin pool
local maxContinentPins = 500

-- Zone boundary data - Updated for better Kalimdor accuracy
local mapData = {
  -- Eastern Kingdoms zones (instance 0)
  [1429] = {3470.83, 2314.58, 1535.42, -7939.58},  -- Elwynn Forest
  [1436] = {3500.00, 2333.33, 3016.67, -9400.00},  -- Westfall
  [1433] = {2170.83, 1447.92, -1570.83, -8575.00}, -- Redridge Mountains  
  [1431] = {2700.00, 1800.00, 833.33, -9716.67},   -- Duskwood
  [1434] = {6381.25, 4254.17, 2220.83, -11516.67}, -- Stranglethorn Vale
  [1453] = {1344.27, 896.35, 1725.00, -8177.08},   -- Stormwind City
  [1426] = {4925.00, 3283.33, 1802.08, -3877.08},  -- Dun Morogh
  [1455] = {790.63, 527.60, 1674.17, -4502.91},    -- Ironforge
  [1432] = {2758.33, 1839.58, -1993.75, -4487.50}, -- Loch Modan
  [1437] = {4135.42, 2756.25, -2147.92, -2314.58}, -- Wetlands
  [1424] = {3200.00, 2133.33, 1066.67, 400.00},    -- Hillsbrad Foothills
  [1416] = {2800.00, 1866.67, 1850.00, 1666.67},   -- Alterac Mountains
  [1417] = {3600.00, 2400.00, -866.67, -133.33},   -- Arathi Highlands
  [1425] = {3850.00, 2566.67, -1575.00, 1466.67},  -- The Hinterlands
  [1420] = {4518.75, 3012.50, 3033.33, 3837.50},   -- Tirisfal Glades
  [1421] = {4200.00, 2800.00, 3450.00, 1666.67},   -- Silverpine Forest
  [1458] = {959.38, 640.10, 2341.67, 3620.83},     -- Undercity
  [1422] = {4300.00, 2866.67, 416.67, 3366.67},    -- Western Plaguelands
  [1423] = {3870.83, 2581.25, -2185.42, 3800.00},  -- Eastern Plaguelands
  [1418] = {2487.50, 1658.33, -2079.17, -5889.58}, -- Badlands
  [1427] = {2231.25, 1487.50, -322.92, -6100.00},  -- Searing Gorge
  [1428] = {2929.17, 1952.08, -266.67, -7031.25},  -- Burning Steppes
  [1435] = {2293.75, 1529.17, -1993.75, -10075.00},-- Swamp of Sorrows
  [1419] = {3350.00, 2233.33, -1241.67, -10566.67},-- Blasted Lands
  [1430] = {2500.00, 1666.67, -833.33, -9866.67},  -- Deadwind Pass
  
  -- Kalimdor zones (instance 1)
  -- Format: {width, height, left, top} in world coordinates
  -- These coordinates from Questie might not match pfQuest's zone layout
  [1438] = {5091.67, 3393.75, 3902.08, 10764.58},  -- Teldrassil (zone 141)
  [1457] = {1058.33, 705.71, 3966.15, 9439.58},    -- Darnassus (zone 1657)
  [1439] = {6550.00, 4366.67, 3016.67, 7416.67},   -- Darkshore (zone 148)
  [1440] = {5766.67, 3843.75, 1699.99, 4466.67},   -- Ashenvale (zone 331)
  [1442] = {4883.33, 3256.25, 966.66, 1570.83},    -- Stonetalon Mountains (zone 406)
  [1413] = {10133.33, 6756.25, 2622.92, 747.91},   -- The Barrens (zone 17)
  [1411] = {5287.50, 3525.00, -1962.49, 1481.25},  -- Durotar (zone 14)
  [1454] = {1402.60, 935.42, -1304.17, 200.00},    -- Orgrimmar (zone 1637)
  [1412] = {5137.50, 3425.00, 2047.91, -635.42},   -- Mulgore (zone 215)
  [1456] = {1043.75, 695.83, 107.08, -1220.83},    -- Thunder Bluff (zone 1638)
  [1443] = {4495.83, 2997.92, 2537.50, -262.50},   -- Desolace (zone 405)
  [1444] = {6950.00, 4633.33, 3441.66, -2366.66},  -- Feralas (zone 357)
  [1441] = {4400.00, 2933.33, 595.83, -3216.66},   -- Thousand Needles (zone 400)
  [1446] = {6900.00, 4600.00, 164.58, -5625.00},   -- Tanaris (zone 440)
  [1449] = {3700.00, 2466.67, -618.75, -5302.08},  -- Un'Goro Crater (zone 490)
  [1451] = {3483.33, 2322.92, -2983.33, -7100.00}, -- Silithus (zone 1377)
  [1445] = {5250.00, 3500.00, -975.00, -200.00},   -- Dustwallow Marsh (zone 15)
  [1452] = {7100.00, 4733.33, 1739.58, 7793.75},   -- Winterspring (zone 618)
  [1447] = {5070.83, 3381.25, -2137.50, 3245.83},  -- Azshara (zone 16)
  [1448] = {5750.00, 3833.33, 1641.67, 6516.67},   -- Felwood (zone 361)
  [1450] = {2308.33, 1539.58, 377.08, 8491.67},    -- Moonglade (zone 493)
  
  -- Continent maps (width, height, left, top in world coordinates)
  -- Eastern Kingdoms works well with these values
  [1415] = {40741.18, 27149.69, 18171.97, 11176.34}, -- Eastern Kingdoms continent
  -- Kalimdor continent
  [1414] = {36799.81, 24533.20, 17066.60, 12799.90}, -- Kalimdor continent
}

local zoneToUiMapID = {
  -- Eastern Kingdoms
  [12] = 1429, [40] = 1436, [44] = 1433, [10] = 1431, [33] = 1434,
  [1519] = 1453, [1] = 1426, [1537] = 1455, [38] = 1432, [11] = 1437,
  [267] = 1424, [36] = 1416, [45] = 1417, [47] = 1425, [85] = 1420,
  [130] = 1421, [1497] = 1458, [28] = 1422, [139] = 1423, [3] = 1418,
  [51] = 1427, [46] = 1428, [8] = 1435, [4] = 1419, [41] = 1430,
  
  -- Kalimdor - Check if any zones are missing
  [141] = 1438, [1657] = 1457, [148] = 1439, [331] = 1440, [406] = 1442,
  [17] = 1413, [14] = 1411, [1637] = 1454, [215] = 1412, [1638] = 1456,
  [405] = 1443, [357] = 1444, [400] = 1441, [440] = 1446, [490] = 1449,
  [1377] = 1451, [15] = 1445, [618] = 1452, [16] = 1447, [361] = 1448,
  [493] = 1450,
}

-- Get zone data from either main or epoch databases
local function GetZoneData(zoneID)
  local zoneData = pfDB and pfDB["zones"] and pfDB["zones"]["data"] and pfDB["zones"]["data"][zoneID]
  if not zoneData then
    zoneData = pfDB and pfDB["zones"] and pfDB["zones"]["data-epoch"] and pfDB["zones"]["data-epoch"][zoneID]
  end
  return zoneData
end

-- Continent assignments
local zoneContinent = {
  -- Eastern Kingdoms = 2 (continent 0 in game)
  [1] = 2, [3] = 2, [4] = 2, [8] = 2, [10] = 2, [11] = 2, [12] = 2,
  [28] = 2, [33] = 2, [36] = 2, [38] = 2, [40] = 2, [41] = 2, [44] = 2,
  [45] = 2, [46] = 2, [47] = 2, [51] = 2, [85] = 2, [130] = 2, [139] = 2,
  [267] = 2, [1497] = 2, [1519] = 2, [1537] = 2,
  
  -- Kalimdor = 1 (continent 1 in game)
  [14] = 1, [15] = 1, [16] = 1, [17] = 1, [141] = 1, [148] = 1, [215] = 1,
  [331] = 1, [357] = 1, [361] = 1, [400] = 1, [405] = 1, [406] = 1,
  [440] = 1, [490] = 1, [493] = 1, [618] = 1, [1377] = 1, [1637] = 1,
  [1638] = 1, [1657] = 1,
}

-- Dynamically determine continent for zones not in our mapping
local function GetZoneContinent(zoneID)
  -- Check cached mapping first
  if zoneContinent[zoneID] then
    return zoneContinent[zoneID]
  end
  
  -- Try to get continent from zone data
  local zoneData = GetZoneData(zoneID)
  if zoneData and zoneData[1] then
    local continent = zoneData[1]
    
    -- pfQuest uses 0 for EK and 1 for Kalimdor in zone data
    -- But we need to map to what GetCurrentMapContinent() returns
    -- GetCurrentMapContinent returns: 1 = Kalimdor, 2 = Eastern Kingdoms
    if continent == 0 then
      continent = 2  -- Eastern Kingdoms
    elseif continent == 1 then
      continent = 1  -- Kalimdor stays 1
    else
      -- Unknown continent, don't process
      return nil
    end
    
    -- Cache the result
    zoneContinent[zoneID] = continent
    return continent
  end
  
  return nil
end

local function ZoneToWorld(x, y, zoneID)
  local uiMapID = zoneToUiMapID[zoneID]
  if not uiMapID then 
    return nil, nil 
  end
  local data = mapData[uiMapID]
  if not data then 
    return nil, nil 
  end
  
  -- Standard conversion without adjustments - let the data be accurate
  local worldX = data[3] - data[1] * (x / 100)
  local worldY = data[4] - data[2] * (y / 100)
  
  return worldX, worldY
end

local function WorldToContinent(worldX, worldY, continent)
  local contData = mapData[continent == 1 and 1414 or 1415]
  if not contData then return nil, nil end
  
  local x = (contData[3] - worldX) / contData[1]
  local y = (contData[4] - worldY) / contData[2]
  
  return x, y
end

-- Animation function - disabled for continent pins
local function NodeAnimate(self, max)
  -- Do nothing - animation disabled for continent view
  return
end

local function CreateContinentPin(index)
  if not continentPins[index] then
    local pin = CreateFrame("Button", "pfQuestContinentPin" .. index, WorldMapButton)
    pin:SetWidth(12)
    pin:SetHeight(12)
    pin:SetFrameLevel(WorldMapButton:GetFrameLevel() + 10)
    pin:SetFrameStrata("DIALOG")
    
    -- Create textures like pfQuest expects
    pin.tex = pin:CreateTexture(nil, "BACKGROUND")
    pin.tex:SetAllPoints(pin)
    
    pin.pic = pin:CreateTexture(nil, "BORDER")
    pin.pic:SetPoint("TOPLEFT", pin, "TOPLEFT", 1, -1)
    pin.pic:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", -1, 1)
    
    pin.hl = pin:CreateTexture(nil, "OVERLAY")
    pin.hl:SetTexture(pfQuestConfig.path.."\\img\\track")
    pin.hl:SetPoint("TOPLEFT", pin, "TOPLEFT", -5, 5)
    pin.hl:SetWidth(12)
    pin.hl:SetHeight(12)
    pin.hl:Hide()
    
    -- Set default properties
    pin.defalpha = 1
    pin.defsize = 12
    pin.Animate = NodeAnimate
    pin.dt = 0
    
    pin:SetScript("OnEnter", function(self)
      if self.node then
        pfMap.NodeEnter(self)
      end
    end)
    
    pin:SetScript("OnLeave", function(self)
      -- Reset animation state when mouse leaves
      self.pulse = 1
      self.mod = 1
      self:SetWidth(self.defsize)
      self:SetHeight(self.defsize)
      pfMap.NodeLeave(self)
    end)
    
    continentPins[index] = pin
  end
  return continentPins[index]
end

-- Trigger quest loading
local questsLoaded = false
local function LoadAvailableQuests()
  if not questsLoaded then
    -- Search for available quests
    local meta = { ["lvl"] = UnitLevel("player") }
    pfDatabase:SearchQuests(meta)
    questsLoaded = true
  end
end

function pfMap:UpdateNodes()
  local continent = GetCurrentMapContinent()
  local zone = GetCurrentMapZone()
  
  -- First call original to let pfQuest do its work
  original_UpdateNodes(self)
  
  -- Check if we're actually on continent view
  local mapName = GetMapInfo()
  local isContinent = (mapName == "Kalimdor" or mapName == "Azeroth" or mapName == "World")
  
  -- ALWAYS clear all continent pins first to prevent persistence
  for i = 1, maxContinentPins do
    if continentPins[i] then
      continentPins[i]:Hide()
      continentPins[i].node = nil
      continentPins[i].sourceContinent = nil
    end
  end
  
  -- Hide our continent pins if in zone view
  if zone > 0 and not isContinent then
    return
  end
  
  -- Make sure we have quest nodes loaded
  LoadAvailableQuests()
  
  -- Hide pfQuest's normal pins on continent view
  for _, pin in pairs(pfMap.pins) do
    if pin then pin:Hide() end
  end
  
  -- Handle world map (both continents visible)
  if continent == 0 then
    -- DISABLED: World map pins are too inaccurate
    -- Just hide all pins on world map view
    for i = 1, maxContinentPins do
      if continentPins[i] then
        continentPins[i]:Hide()
      end
    end
    return
  end
  
  -- Don't show on invalid continents
  if continent > 2 or continent < 1 then
    return
  end
  
  -- Single continent view - rebuild pins for current continent
  
  -- Show continent pins
  local pinCount = 0
  local playerLevel = UnitLevel("player")
  local processedZones = {}
  
  for addon, addonData in pairs(pfMap.nodes) do
    -- Process all nodes
    -- if addon == "PFQUEST_CONTINENT" then
    for zID, zoneNodes in pairs(addonData) do
      -- Only process zones on current continent
      local zoneCont = GetZoneContinent(zID)
      
      -- Strict filtering - only process zones on the correct continent
      if not zoneCont or zoneCont ~= continent then
        -- Skip zones that are not on the current continent
        -- This prevents Silverpine (EK) from showing on Kalimdor
      else
        processedZones[zID] = true
        local uiMapID = zoneToUiMapID[zID]
        if uiMapID and mapData[uiMapID] then
          for coords, node in pairs(zoneNodes) do
            -- Filter out unwanted quests on continent view too
            local skipNode = false
            for title, data in pairs(node) do
              -- Skip chicken quests
              if title == "CLUCK!" or title == "Cluck!" or string.find(title, "CLUCK") then
                skipNode = true
                break
              end
              -- Skip PvP quests
              if string.find(title, "Warsong") or string.find(title, "Arathi") or 
                 string.find(title, "Alterac") or string.find(title, "Battleground") then
                skipNode = true
                break
              end
              
              -- Get quest levels
              local questLevel = tonumber(data.qlvl) or tonumber(data.lvl) or 0
              local minLevel = tonumber(data.min) or 0
              
              -- Skip gray quests (too low level)
              if questLevel > 0 and playerLevel > questLevel + 10 then
                if not (data.texture and string.find(data.texture, "complete")) then
                  skipNode = true
                  break
                end
              end
              
              -- Skip quests that are way too high level (red quests)
              if questLevel > playerLevel + 5 then
                if not (data.texture and string.find(data.texture, "complete")) then
                  skipNode = true
                  break
                end
              end
              
              -- Special filter for quests with suspiciously low min level
              if minLevel <= 1 and questLevel > playerLevel + 10 then
                if not (data.texture and string.find(data.texture, "complete")) then
                  skipNode = true
                  break
                end
              end
            end
            
            if not skipNode then
              local _, _, strx, stry = strfind(coords, "(.*)|(.*)")
              local zoneX = tonumber(strx)
              local zoneY = tonumber(stry)
            
            if zoneX and zoneY then
              local worldX, worldY = ZoneToWorld(zoneX, zoneY, zID)
              if worldX and worldY then
                local contX, contY = WorldToContinent(worldX, worldY, continent)
                if contX and contY and contX >= 0 and contX <= 1 and contY >= 0 and contY <= 1 then
                  -- Debug: Check if pins are appearing in wrong zones
                  if not processedZones[zID .. "_sample"] and continent == 1 then
                    local problemZones = {
                      [405] = "Desolace",
                      [215] = "Mulgore",
                      [15] = "Dustwallow",
                      [400] = "Thousand Needles",
                    }
                    if problemZones[zID] then
                      processedZones[zID .. "_sample"] = true
                      -- Show where a sample pin from this zone is being placed
                      -- Debug output removed
                    end
                  end
                  
                  pinCount = pinCount + 1
                  if pinCount > maxContinentPins then break end
                  
                  local pin = CreateContinentPin(pinCount)
                  pin.node = node
                  pin.sourceContinent = continent  -- Track which continent this pin belongs to
                  
                  -- Update pin appearance
                  pfMap:UpdateNode(pin, node, nil, nil, nil)
                  
                  -- Position pin (no adjustment needed if zone data is correct)
                  pin:ClearAllPoints()
                  pin:SetPoint("CENTER", WorldMapButton, "TOPLEFT",
                             contX * WorldMapButton:GetWidth(),
                             -contY * WorldMapButton:GetHeight())
                  pin:Show()
                end
              end
            end
            end -- end skipNode check
          end
          if pinCount >= maxContinentPins then break end
        end
      end  -- end continent check
    end
      if pinCount >= maxContinentPins then break end
    -- end
  end
  
  -- Hide unused continent pins
  for i = pinCount + 1, maxContinentPins do
    if continentPins[i] then
      continentPins[i]:Hide()
    end
  end
  
  -- DEBUG: Show pin count
  -- DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ffccpfQuest:|r Created %d pins on %s", 
  --   pinCount, continent == 1 and "Kalimdor" or continent == 2 and "Eastern Kingdoms" or "World Map"))
  
  -- Don't delete nodes here - keep them for next update
end

-- Hook into world map updates to catch continent switches
local originalWorldMapButton_OnUpdate = WorldMapButton:GetScript("OnUpdate")
WorldMapButton:SetScript("OnUpdate", function(self, elapsed)
  if originalWorldMapButton_OnUpdate then
    originalWorldMapButton_OnUpdate(self, elapsed)
  end
  
  -- Check if continent or zoom level changed
  local currentContinent = GetCurrentMapContinent()
  local currentZone = GetCurrentMapZone()
  
  if self.lastContinent ~= currentContinent or self.lastZone ~= currentZone then
    self.lastContinent = currentContinent
    self.lastZone = currentZone
    
    -- Update on continent view or world view
    if currentZone == 0 then
      --DEFAULT_CHAT_FRAME:AddMessage(string.format("Continent changed to %d, forcing update", currentContinent))
      pfMap:UpdateNodes()
    end
  end
end)

-- Addon loaded silently - no messages or slash commands for clean integration
