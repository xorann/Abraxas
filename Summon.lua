

--[[

Summoning assistant for Warlocks

by Dorann
https://github.com/xorann/Abraxas

hide if list is empty
show if list is not empty
]]


--[[
1. raid member writes in raid chat, say, yell or whispers warlock one of the following words: port, summon
2. gets automatically added to the frame: One row per player with the name, a button to remove the player and a button to summon the player
]]

----------------------------------
--      Module Declaration      --
----------------------------------

local L = AceLibrary("AceLocale-2.2"):new("Abraxas")
local module = Abraxas
local frame = nil
local list = {}
local playerName = UnitName("player")

local states = {
	default = {
		r = 39/255,
		g = 115/255,
		b = 31/255
	},
	disabled = {
		r = 57/255,
		g = 57/255,
		b = 57/255
	},
	summoning = {
		r = 0/255,
		g = 0/255,
		b = 255/255
	}
}


---------------------------------
--      	Variables 		   --
---------------------------------

local BS = AceLibrary("Babble-Spell-2.2")
local BZ = AceLibrary("Babble-Zone-2.2")

-- Function decToHex (renamed, updated): http://lua-users.org/lists/lua-l/2004-09/msg00054.html
local function decToHex(IN)
	local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
	while IN>0 do
    	I=I+1
    	IN,D=math.floor(IN/B),math.mod(IN,B)+1
    	OUT=string.sub(K,D,D)..OUT
	end
	return OUT
end
-- Function rgbToHex: http://gameon365.net/index.php
local function rgbToHex(r,g,b)
	local output = decToHex(r) .. decToHex(g) .. decToHex(b);
	return output
end

local hexColors = {}
for k, v in pairs(RAID_CLASS_COLORS) do
    hexColors[k] = string.format("|cff%02x%02x%02x ", v.r * 255, v.g * 255, v.b * 255)
end

-- Helper table to cache colored player names.
local coloredNames = setmetatable({}, {__index =
	function(self, unit)
		if type(unit) == "nil" then return nil end
		local _, class = UnitClass(unit)
        local name, _ = UnitName(unit)
		if class then
			self[name] = hexColors[class] .. name .. "|r"
			return self[name]
		else
			return name
		end
	end
})

local channelingSummon = nil
local spellStatus = AceLibrary("SpellStatus-1.0")

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnableSummon()	
	module:SetupFrame()
	
	if not UnitAffectingCombat("player") then
		self:ScheduleRepeatingEvent("AbraxasUpdateState", self.UpdatePlayerState, 1, self)
	end
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	self:RegisterEvent("CHAT_MSG_PARTY", "CheckForRequest")
	self:RegisterEvent("CHAT_MSG_RAID", "CheckForRequest")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "CheckForRequest")
	self:RegisterEvent("CHAT_MSG_SAY", "CheckForRequest")
	self:RegisterEvent("CHAT_MSG_YELL", "CheckForRequest")
	self:RegisterEvent("CHAT_MSG_WHISPER", "CheckForRequest")
	
	self:RegisterEvent("CHAT_MSG_ADDON")
	
	
	self:RegisterEvent("SpellStatus_SpellCastCastingStart")
	self:RegisterEvent("SpellStatus_SpellCastFailure")
	self:RegisterEvent("SpellStatus_SpellCastCastingFinish")
	self:RegisterEvent("SpellStatus_SpellCastChannelingStart")
	self:RegisterEvent("SpellStatus_SpellCastChannelingFinish")
	self:RegisterEvent("SpellStatus_SpellCastInstant")
	self:RegisterEvent("SPELLCAST_STOP")
end

function module:OnDisableSummon()
	frame:Hide()
end

------------------------------
--      Event Handlers	    --
------------------------------

-- entering combat: hide frame
function module:PLAYER_REGEN_DISABLED()
	self:CancelScheduledEvent("AbraxasUpdateState")
	frame:Hide()
end

function module:CheckForRequest(msg, name)
	if module:ContainsWholeWord(msg, "port") 
		or module:ContainsWholeWord(msg, "porten")
		or module:ContainsWholeWord(msg, "summon")
		then
		
		--module:AddPlayer(name)
		module:Sync("Request " .. name)
	end
end

function module:SpellStatus_SpellCastCastingStart(id, name, fullName, startTime, stopTime, duration)
	--self:Print("SpellStatus_SpellCastCastingStart " .. name)
	if name == BS["Ritual of Summoning"] then
		self:Sync("Summon " .. name)
	end
end

function module:SpellStatus_SpellCastFailure(id, name, rank, fullName, isActiveSpell, UIEM_Message, CMSFLP_Message, CMSFLP_Message)
	--self:Print("SpellStatus_SpellCastFailure")	
	if self:IsEventScheduled("SpellStatus_Pseudo_SpellCastSuccess") then
		--self:Print("cancel SpellStatus_Pseudo_SpellCastSuccess")
		self:CancelScheduledEvent("SpellStatus_Pseudo_SpellCastSuccess")
	end
	
	if name == BS["Ritual of Summoning"] then
		self:Sync("Request " .. UnitName("target"))
	end
end

function module:SpellStatus_SpellCastCastingFinish(id, name, rank, fullName, startTime, stopTime, delayTotal)
	--self:Print("SpellStatus_SpellCastCastingFinish")
	self:ScheduleEvent("SpellStatus_Pseudo_SpellCastSuccess", self.SpellStatus_Pseudo_SpellCastSuccess, 0.5, self, id, name, rank, fullName, startTime, stopTime, delayTotal)
end

function module:SpellStatus_Pseudo_SpellCastSuccess(id, name, rank, fullName, startTime, stopTime, delayTotal)
	--self:Print("SpellStatus_Pseudo_SpellCastSuccess")
	--self:Print("SpellStatus_Pseudo_SpellCastSuccess " .. name .. " " .. startTime .. " " .. stopTime .. " " .. " " .. (stopTime - startTime) .. " " .. delayTotal)
	if name == BS["Ritual of Summoning"] then
		if spellStatus:IsChanneling() then
			--self:Print("is channeling")
		else
			--self:Print("is not channeling")
			self:SpellStatus_SpellCastFailure(id, name, rank, fullName)
		end
	end
end
		
function module:SpellStatus_SpellCastChannelingStart(id, name, rank, fullName, startTime, stopTime, duration, action)
	--self:Print("SpellStatus_SpellCastChannelingStart")
	if self:IsEventScheduled("Abraxas_SpellStatus_SpellCastFailure") then
		--self:Print("cancel Abraxas_SpellStatus_SpellCastFailure")
		self:CancelScheduledEvent("Abraxas_SpellStatus_SpellCastFailure")
	end
end

function module:SpellStatus_SpellCastChannelingFinish(id, name, rank, fullName, startTime, stopTime, duration, action, disruptionTotal)
	--self:Print("SpellStatus_SpellCastChannelingFinish")
	self:ScheduleEvent("SpellStatus_Pseudo_SpellChannelingFailure", self.SpellStatus_Pseudo_SpellChannelingFailure, 0.5, self, id, name, rank, fullName, startTime, stopTime, duration, action, disruptionTotal)
end
function module:SPELLCAST_STOP()
	--self:Print("SPELLCAST_STOP")
	if self:IsEventScheduled("SpellStatus_Pseudo_SpellChannelingFailure") then
		self:CancelScheduledEvent("SpellStatus_Pseudo_SpellChannelingFailure")
		local id, name, rank, fullName, startTime, stopTime, duration, action = spellStatus:GetActiveSpellData()
		self:SpellStatus_Pseudo_SpellChannelingSuccess(id, name, rank, fullName, startTime, stopTime, duration, action)
	end
end

function module:SpellStatus_Pseudo_SpellChannelingSuccess(id, name, rank, fullName, startTime, stopTime, duration, action)
	--self:Print("SpellStatus_Pseudo_SpellChannelingSuccess")
	if name and name == BS["Ritual of Summoning"] then
		self:Sync("Remove " .. UnitName("target"))
	end
end

function module:SpellStatus_Pseudo_SpellChannelingFailure(id, name, rank, fullName, startTime, stopTime, duration, action, disruptionTotal)
	--self:Print("SpellStatus_Pseudo_SpellChannelingFailure")
	if name and name == BS["Ritual of Summoning"] then
		--self:Print("SpellStatus_Pseudo_SpellChannelingFailure")
		self:Sync("Request " .. UnitName("target"))
	end
end

function module:SpellStatus_SpellCastInstant(id, name, rank, fullName, startTime, stopTime, duration, delayTotal)
	--self:Print("SpellStatus_SpellCastInstant " .. name)
	--if name == BS["Curse of Tongues"] or name == BS["Curse of Shadow"] or name == BS["Curse of the Elements"] or name == BS["Curse of Recklessness"] then
	if string.find(name, L["Curse of"]) then
		Abraxas:CastedCurse(name)
	end
end


------------------------------
--      Synchronization	    --
------------------------------
function module:CHAT_MSG_ADDON(prefix, message, type, sender)
	if prefix ~= "Abraxas" or type ~= "RAID" then 
		return 
	end
	
	local _, _, sync, rest = string.find(message, "(%S+)%s*(.*)$")
	if not sync then 
		return 
	end
	
	if sync == "Request" and rest and sender then
        module:AddPlayer(rest)
    elseif sync == "Summon" and rest and sender then
		module:SummoningPlayer(rest)
	elseif sync == "Remove" and rest and sender then
		module:RemovePlayer(rest)
	-- version query
	elseif sync == "AbraxasVersionQuery" and sender ~= UnitName("player") and rest then
		-- send response
		self:Sync("AbraxasVersionReply " .. self.revision .. " " .. sender)
	elseif sync == "AbraxasVersionReply" and sender and rest then
		-- parse reply
		local m = Abraxas:GetModule("Version Query")
		m:VersionQueryReply(sender, rest)
	end
end

function module:Sync(msg)
	local _, _, sync, rest = string.find(msg, "(%S+)%s*(.*)$")

	if not sync then return end

	SendAddonMessage("Abraxas", msg, "RAID")
	self:CHAT_MSG_ADDON("Abraxas", msg, "RAID", playerName)
end


------------------------------
--      Sync Handlers	    --
------------------------------
function module:AddPlayer(name)
	if not list[name] then
		list[name] = {}
		local i = module:TableSize(list)

		list[name].frame = module:CreatePlayer(frame.body, i, name)
	end
		
	module:SetState(name, states.default)
	module:UpdatePlayerPositions()
end

function module:SummoningPlayer(name)
	--self:Print("SummoningPlayer " .. name)
	if list[name] then
		module:SetState(name, states.summoning)
	end
end

function module:RemovePlayer(name)	
	if list[name] then
		list[name].frame:Hide()
		list[name].frame = nil
		list[name] = nil
	end
	
	module:UpdatePlayerPositions()
end


------------------------------
--      Utility	Functions   --
------------------------------
function module:GetUnitId(name)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers(), 1 do
			local aName = GetRaidRosterInfo(i)
			if aName == name then
				return "Raid" .. i
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers(), 1 do
			local unitId = "Party" .. i
			local aName = UnitName(unitId)
			if aName == name then
				return unitId
			end
		end
	end
	return nil
end

function module:SummonPlayer(name)	
	local unitId = module:GetUnitId(name)
	local playerZone = self:GetZone("player")
	local targetZone = self:GetZone(unitId)
	
	if UnitAffectingCombat("player") then
		self:Print(L["You are in combat"])
	elseif UnitAffectingCombat(unitId) then
		self:Print(string.format(L["%s is in combat"], name))
	elseif not self:ValidZone(playerZone, targetZone) then
		self:Print(string.format(L["You can't summon someone from |cffff0000%s|r to %s"], targetZone, playerZone))
	else
		TargetUnit(unitId)
		CastSpellByName(BS["Ritual of Summoning"])
		
		--self:Print(string.format(L["<Abraxas> Summoning %s to %s"], name, playerZone))
		local chatType = "PARTY"
		if GetNumRaidMembers() > 0 then
			chatType = "RAID"
		end
		SendChatMessage(string.format(L["<Abraxas> Summoning %s to %s"], name, playerZone), chatType)
		--self:Print(string.format(L["<Abraxas> Summoning you to %s"], playerZone))
		SendChatMessage(string.format(L["<Abraxas> Summoning you to %s"], playerZone), "WHISPER", nil, name)
		--self:Print(string.format(L["<Abraxas> Please assist summoning %s"], name))
		SendChatMessage(string.format(L["<Abraxas> Please assist summoning %s"], name), "SAY")
		
		self:Sync("Summon " .. name)
	end	
end

function module:UpdatePlayerState()
	for name, player in pairs(list) do
		local unitId = module:GetUnitId(name)
		if unitId then
			local online = UnitIsConnected(unitId)
			local dead = UnitIsDeadOrGhost(unitId)
			
			if player.state == states.summoning then
				-- do nothing
			elseif not online or dead then
				self:SetState(name, states.disabled)
			else
				self:SetState(name, states.default)
			end
		end
	end
end

function module:UpdatePlayerPositions()
	local index = 0
	for name, player in pairs(list) do
		local playerFrame = player.frame
		playerFrame:ClearAllPoints()
		playerFrame:SetPoint("TOPLEFT", playerFrame:GetParent(), "TOPLEFT", 0, 0 - index * playerFrame:GetHeight())
	
		index = index + 1
	end
	
	if index == 0 then
		module:CloseFrame()
	else
		if UnitAffectingCombat("player") then
			-- show frame after combat
			self.db.profile.visible = true
		else
			module:ShowFrame()
		end
	end
end

function module:ContainsWholeWord(input, word)
	if not string.find(input, "%f[%a]" .. word .. "%f[%A]") then
		return false
	else
		return true
	end
	--return string.find(input, "%f[%a]" .. word .. "%f[%A]")
end

function module:TableSize(aTable)
	local s = 0
	for k, v in pairs(aTable) do
		s = s + 1
	end
	return s
end

function module:GetPlayerText(name)
	local unitId = module:GetUnitId(name)
	local coloredName = tostring(coloredNames[unitId])

	return coloredName
end

function module:SetState(name, state)
	if name and frame and list[name] and list[name].frame and state then
		list[name].frame:SetBackdropColor(state.r, state.g, state.b)
		list[name].state = state
	end
end


function module:GetZone(unitId)	
	if GetNumRaidMembers() > 0 then
		if unitId then
			if unitId == "player" then
				unitId = module:GetUnitId(GetUnitName(unitId))
				local _, _, _, _, _, _, zone = GetRaidRosterInfo(string.sub(unitId, 5))
				return zone
			elseif string.find(unitId, "Raid") then
				local _, _, _, _, _, _, zone = GetRaidRosterInfo(string.sub(unitId, 5))
				return zone
			end
		end
	elseif GetNumPartyMembers() > 0 then
		if unitId then
			-- how do I get the zone of party members?
			return GetRealZoneText()
		end
	end
	
	return nil
end

local instancedZones = {
	[BZ["Ahn'Qiraj"]] = true,
	[BZ["Alterac Valley"]] = true,
	[BZ["Arathi Basin"]] = true,
	[BZ["Blackfathom Deeps"]] = true,
	[BZ["Blackrock Depths"]] = true,
	[BZ["Blackrock Spire"]] = true,
	[BZ["Blackwing Lair"]] = true,
	[BZ["The Deadmines"]] = true,
	[BZ["Deeprun Tram"]] = true,
	--[BZ["Dire Maul"]] = true, -- the zone outside of the instance is called dire maul as well ..
	[BZ["Dire Maul (East)"]] = true,
	[BZ["Dire Maul (West)"]] = true,
	[BZ["Dire Maul (North)"]] = true,
	[BZ["Gnomeregan"]] = true,
	[BZ["Hall of Legends"]] = true,
	[BZ["Hyjal"]] = true,
	[BZ["Lower Blackrock Spire"]] = true,
	[BZ["Maraudon"]] = true,
	[L["The Molten Core"]] = true, -- babble-zone has the wrong name
	[BZ["Naxxramas"]] = true,
	--[BZ["Onyxia's Lair"]] = true, -- the zone outside of the instance is called dire maul as well ..
	[BZ["Ragefire Chasm"]] = true,
	[BZ["Razorfen Downs"]] = true,
	[BZ["Razorfen Kraul"]] = true,
	[BZ["Ruins of Ahn'Qiraj"]] = true,
	[BZ["Scarlet Monastery"]] = true,
	[BZ["Scholomance"]] = true,
	[BZ["Shadowfang Keep"]] = true,
	[BZ["The Stockade"]] = true,
	[BZ["Stratholme"]] = true,
	[BZ["Temple of Ahn'Qiraj"]] = true,
	[BZ["The Temple of Atal'Hakkar"]] = true,
	[BZ["Uldaman"]] = true,
	[BZ["Upper Blackrock Spire"]] = true,
	[BZ["Wailing Caverns"]] = true,
	[BZ["Warsong Gulch"]] = true,
	[BZ["Zul'Farrak"]] = true,
	[BZ["Zul'Gurub"]] = true,
}
function module:ValidZone(zone1, zone2)
	if zone1 and zone2 then
		if zone1 == zone2 then
			return true
		elseif not instancedZones[zone1] and not instancedZones[zone2] then
			return true
		else
			return false
		end
	end
	return true
end


------------------------------
--      Frame			    --
------------------------------
function module:CreateHeader(title, width)
	local header = frame:CreateFontString(nil, "OVERLAY")
	header:ClearAllPoints()
	header:SetWidth(width)
	header:SetHeight(15)
	header:SetPoint("TOP", frame, "TOP", 5, -14)
	header:SetFont(L["font"], 12)
	header:SetJustifyH("LEFT")
	header:SetText(title)
	header:SetShadowOffset(.8, -.8)
	header:SetShadowColor(0, 0, 0, 1)
	
	return header
end

function module:CreateBody(parent, height)
	local body = CreateFrame("Frame", nil, parent)
	body:Show()
	
	body:SetWidth(parent:GetWidth())
	body:SetHeight(height)
	--[[body:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	body:SetBackdropColor(24/255, 240/255, 24/255)]]
	body:ClearAllPoints()
	body:SetPoint("TOP", parent, "TOP", 0, -32)

	return body
end

function module:CreatePlayer(parent, position, name)
	if not parent or not position or not name then 
		return nil 
	end
		
	local frame = CreateFrame("Frame", nil, parent)
	frame:Show()
	frame:SetFrameStrata("LOW")
	
	local height = 20
	
	-- size
	frame:SetWidth(parent:GetWidth())
	frame:SetHeight(height)
	
	-- background
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 0, bottom = 1},
	})
	frame:SetBackdropColor(38/255, 171/255, 71/255)
	
	-- position
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0 - (position - 1) * height)
	
	-- drag and drop
	frame:SetMovable(false)

	local function CreateButton(parent, edgeSize, posX, posY, texturePath)
		local button = CreateFrame("Button", "testButton", parent)
		button:Show()
		button:SetPoint("TOPLEFT", posX, posY)
		button:SetWidth(edgeSize)
		button:SetHeight(edgeSize)
		button:SetFrameStrata("HIGH")
		button:EnableMouse(true)
		button:RegisterForClicks("LeftButtonUp")
		
		local texture = parent:CreateTexture(nil, "OVERLAY")
		texture:SetAllPoints(button)
		texture:SetTexture(texturePath)
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- zoom in to hide border
		
		button.texture = texture
		
		return button
	end
	
	-- remove button
	local removeButton = CreateButton(frame, 19, 1, 0, "Interface\\Icons\\spell_chargenegative")
	removeButton:SetScript("OnClick", function()
		local playerName = this:GetParent().playerName
		if playerName then
			Abraxas:Sync("Remove " .. playerName)
		end
	end)
	--removeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", frame:GetWidth() - 19, 0)
	frame.removeButton = removeButton
	
	-- summon button
	local summonButton = CreateButton(frame, 19, frame:GetWidth() - 20, 0, "Interface\\Icons\\spell_shadow_twilight")
	summonButton:SetScript("OnClick", function()
		local playerName = this:GetParent().playerName
		if playerName then
			Abraxas:SummonPlayer(playerName)
		end
	end)
	frame.summonButton = summonButton
	
	-- player name
	local text = frame:CreateFontString(nil, "ARTWORK")
	text:SetParent(frame)
	text:ClearAllPoints()
	text:SetWidth(parent:GetWidth() - removeButton:GetWidth() - summonButton:GetWidth())
	text:SetHeight(height)
	text:SetPoint("Left", frame, "LEFT", 22, 0)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("CENTER")
	text:SetFont(L["font"], 12)
	text:SetText(module:GetPlayerText(name))
	frame.text = text
	frame.playerName = name

	return frame
end

function module:SetupFrame()
	if frame then return end

	frame = CreateFrame("Frame", "AbraxasSummonFrame", UIParent)
	if self.db.profile.visible then
		frame:Show()
	else
		frame:Hide()
	end

	-- size
	local width = 200
	local height = 100
	frame:SetWidth(width)
	frame:SetHeight(height)

	-- background
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1,
		edgeFile = "Interface\\AddOns\\Abraxas\\Textures\\otravi-semi-full-border", edgeSize = 32,
		--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeSize = 32,
        --edgeFile = "", edgeSize = 32,
		insets = {left = 1, right = 1, top = 20, bottom = 1},
	})
	frame:SetBackdropColor(24/255, 24/255, 24/255)
	frame:SetBackdropBorderColor(0/255, 0/255, 255/255)
	frame:SetFrameStrata("LOW")

	-- position
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	-- drag and drop
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true) -- can't move it outside of the screen
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetScript("OnDragStart", function() this:StartMoving() end)
	frame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
		self:SaveFramePosition()
	end)
	
	-- close button
	local close = frame:CreateTexture(nil, "ARTWORK")
	close:SetTexture("Interface\\AddOns\\Abraxas\\Textures\\otravi-close")
	close:SetTexCoord(0, .625, 0, .9333)

	close:SetWidth(20)
	close:SetHeight(14)
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -15)

	local closebutton = CreateFrame("Button", nil)
	closebutton:SetParent(frame)
	closebutton:SetWidth(20)
	closebutton:SetHeight(14)
	closebutton:SetPoint("CENTER", close, "CENTER")
	closebutton:SetScript( "OnClick", function() Abraxas:CloseFrame() end )
	
	-- content
	frame.header = module:CreateHeader(L["Abraxas Summon"], width)
	frame.body = module:CreateBody(frame, height)
	frame.healer = {}
	
	local x = self.db.profile.posx
	local y = self.db.profile.posy
	if x and y then
		local scale = frame:GetEffectiveScale()
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
	else
		self:ResetFramePosition()
	end
end

function module:CloseFrame()
	self.db.profile.visible = false
	frame:Hide()
end

function module:ShowFrame()
	self.db.profile.visible = true
	frame:Show()
end

function module:ToggleFrame()
	if self.db.profile.visible then
		module:CloseFrame()
	else
		module:ShowFrame()
	end
end

function module:ResetFramePosition()
	if not frame then 
		self:SetupFrame() 
	end
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER")
    --frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	self.db.profile.posx = nil
	self.db.profile.posy = nil
end

function module:SaveFramePosition()
	if not frame then 
		self:SetupFrame() 
	end

	local scale = frame:GetEffectiveScale()
	self.db.profile.posx = frame:GetLeft() * scale
	self.db.profile.posy = frame:GetTop() * scale
end


----------------------------------
--      Module Test Function    --
----------------------------------

