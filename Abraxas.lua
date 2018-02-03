--[[
    Addon created by Dorann
	Curse idea by Mohock
	
    Abraxas allows you to dynamically cast the most important curse
	create one of the following macros:
		- "/abraxas Curse" casts the most important missing curse
		- "/abraxas CurseOrShadowbolt" casts the most important missing curse or Shadow Bolt if all curses are present
--]]

------------------------------
-- Initialization      		--
------------------------------
local L = AceLibrary("AceLocale-2.2"):new("Abraxas")
local BB = AceLibrary("Babble-Boss-2.2")
local BS = AceLibrary("Babble-Spell-2.2")


Abraxas = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceModuleCore-2.0", "AceDB-2.0", "AceDebug-2.0", "FuBarPlugin-2.0")
Abraxas.revision = 1

Abraxas:RegisterDB("AbraxasDB")
Abraxas.cmdtable = {
	type = "group",
	handler = Abraxas,
	args = {
		curse = {
			type = "group",
			name = L["Curse"],
			desc = L["Options for curse"],
			order = 1,
			args = {
				mode = {
					type = "text",
					name = L["Set mode"],
					desc = L["Set which mode should be used for casting curses."],
					get = function() return Abraxas.db.profile.cursemode end,
					set = function(v) Abraxas.db.profile.cursemode = v end,
					validate = {L["static"], L["dynamic"] },
					order = 1,
				},
				staticcurse = {
					type = "text",
					name = L["Set static curse"],
					desc = L["Set which curse should be casted in static mode."],
					get = function() return Abraxas.db.profile.staticcurse end,
					set = function(v) Abraxas.db.profile.staticcurse = v end,
					validate = {BS["Curse of Shadow"], BS["Curse of the Elements"], BS["Curse of Recklessness"], BS["Curse of Tongues"], BS["Curse of Weakness"], BS["Curse of Exhaustion"], BS["Curse of Doom"], BS["Curse of Agony"]},
					order = 2,
				},
				cast = {
					type = "execute",
					name = L["Curse"],
					desc = L["Cast curse. \nMacro: |cfB34DFFf/abraxas curse cast|r"],
					order = 3,
					func = function() Abraxas:Curse() end,
				},
				shadowbolt = {
					type = "execute",
					name = BS["Shadow Bolt"],
					desc = L["Casts Shadow Bolt if all curses are present. \nMacro: |cfB34DFFf/abraxas curse shadowbolt|r"],
					order = 4,
					func = function() Abraxas:CurseOrShadowbolt() end,				
				}
			}
		},
		summon = {
			type = "execute",
			name = L["Summon"],
			desc = L["Show the summon window."],
			order = 2,
			func = function() Abraxas:ToggleFrame() end,
		},
		version = {
			type = "execute",
			name = L["Abraxas Version Query"],
			desc = L["Runs a version query on Abraxas."],
			order = 3,
			func = function() Abraxas:GetModule("Version Query"):QueryVersion() end,
		},
	}
}
Abraxas:RegisterChatCommand({"/abraxas"}, Abraxas.cmdtable)

Abraxas.defaultDB = {
	posx = nil,
	posy = nil,
	visible = nil,
	cursemode = L["static"],
	staticcurse = BS["Curse of Shadow"],
}


function Abraxas:OnInitialize()
	-- Called when the addon is loaded	
	if self.db.profile.cursemode == nil then
		self.db.profile.cursemode = L["static"]
	end
	
	if self.db.profile.staticcurse == nil then
		self.db.profile.staticcurse = BS["Curse of Shadow"]
	end
end

function Abraxas:OnEnable()
	-- Called when the addon is enabled
	self:OnEnableSummon()
	--self:OnEnableVersion()
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")	
end

function Abraxas:OnDisable()
	-- Called when the addon is disabled
	self:OnDisableSummon()
end

------------------------------
-- FuBar	     			--
------------------------------
local tablet = AceLibrary("Tablet-2.0")
function Abraxas:OnTooltipUpdate()
	tablet:SetHint(L["|cffeda55fClick|r to toggle the Summon window. |cffeda55fRight click|r to show the options menu."])
end

function Abraxas:OnClick()
	self:ToggleFrame()
end

Abraxas.hasIcon = "Interface\\Icons\\spell_shadow_twilight"
Abraxas.defaultMinimapPosition = 160
Abraxas.OnMenuRequest = Abraxas.cmdtable


------------------------------
-- Variables     			--
------------------------------


-- targets where curse of tongues should be used
local tongueTarget = {
	[L["Flamewaker Priest"]] = true,
	[BB["The Prophet Skeram"]] = true,
	[L["Giant Eye Tentacle"]] = true
}

-- targets where curse of recklessness should not be used
local recklessnessException = {
	[BB["Broodlord Lashlayer"]] = true,
	[BB["Bloodlord Mandokir"]] = true,
	[BB["Princess Huhuran"]] = true,
	[BB["Emperor Vek'lor"]] = true,
	[BB["Ouro"]] = true,
	[BB["Patchwerk"]] = true,
}

local cursePriority = {
	[BS["Curse of Tongues"]] = 4,
	[BS["Curse of Shadow"]] = 3,
	[BS["Curse of the Elements"]] = 2,
	[BS["Curse of Recklessness"]] = 1,
	[BS["Curse of Weakness"]] = 0,
	[BS["Curse of Agony"]] = 0,
	[BS["Curse of Doom"]] = 0,
	[BS["Curse of Exhaustion"]] = 0,
}

local curseTarget = nil
local curseTime = nil
local curseCasted = nil


------------------------------
-- Slashcommand Handlers 	--
------------------------------
function Abraxas:Curse()
	if self.db.profile.cursemode == L["dynamic"] then
		self:UpdateCursePriority()
		local spell = self:GetMostImportantMissingCurse()

		if spell then
			if not curseCasted or (curseCasted and cursePriority[curseCasted] < cursePriority[spell]) then
				--Abraxas:CastCurse(spell)
				CastSpellByName(spell)
			else
				self:Print(L["There are still curses missing but you already casted a more important curse"])
			end
		else
			self:Print(L["All curses are present."])
		end
	else
		CastSpellByName(self.db.profile.staticcurse)
	end
end

function Abraxas:CurseOrShadowbolt()
	if self.db.profile.cursemode == L["dynamic"] then
		self:UpdateCursePriority()
		local spell = self:GetMostImportantMissingCurse()
		
		if spell then
			if not curseCasted or (curseCasted and cursePriority[curseCasted] < cursePriority[spell]) then
				--Abraxas:CastCurse(spell)
				CastSpellByName(curse)
			else
				--self:Print(L["There are still curses missing but you already casted a more important curse"])
				CastSpellByName(BS["Shadow Bolt"])
			end
		else
			CastSpellByName(BS["Shadow Bolt"])
		end
	else
		local curseMissing = false
		if self.db.profile.staticcurse == BS["Curse of Tongues"] and tongueTarget[target] and not Abraxas:HasTongues() then
			curse = BS["Curse of Tongues"]
			curseMissing = true
		end
		
		if self.db.profile.staticcurse == BS["Curse of Shadow"] and not Abraxas:HasShadows() then
			curse = BS["Curse of Shadow"]
			curseMissing = true
		end
		
		if self.db.profile.staticcurse == BS["Curse of the Elements"] and not Abraxas:HasElements() then
			curse = BS["Curse of the Elements"]
			curseMissing = true
		end
		
		if not recklessnessException[target] and self.db.profile.staticcurse == BS["Curse of Recklessness"] and not Abraxas:HasRecklessness() then
			curse = BS["Curse of Recklessness"]
			curseMissing = true
		end
		
		if curseMissing then
			CastSpellByName(self.db.profile.staticcurse)
		else
			CastSpellByName(BS["Shadow Bolt"])
		end
	end
end


----------------------
-- Event Handlers  	--
----------------------
function Abraxas:CHAT_MSG_SPELL_SELF_DAMAGE(msg)
	local start, ending, userspell, target = string.find(msg, L["Your Curse of (.+) was resisted by (.+)."])
	if userspell and target then
		self:Print(string.format(L["Your Curse of %s was |cffff0000resisted|r by %s."], userspell, target))
    end
	
	local start, ending, curse, target = string.find(msg, L["^Curse of (.+) fades from ([%w%s:]+)."])
    if target and target == curseTarget and curseCasted == BS[string.format("Curse of %s", curse)] then
        curseTarget = nil
		curseTime = nil
		curseCasted = nil
		
		self:Print(L["Your curse has faded."])
    end
end

function Abraxas:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if curseTarget and (msg == string.format(UNITDIESOTHER, curseTarget) or msg == string.format(L["You have slain %s!"], curseTarget)) then
		curseTarget = nil
		curseTime = nil
		curseCasted = nil
	end
end

function Abraxas:PLAYER_REGEN_ENABLED()
    curseTarget = nil
	curseTime = nil
	curseCasted = nil
	
	self:ScheduleRepeatingEvent("AbraxasUpdateState", self.UpdatePlayerState, 1, self)
	if self.db.profile.visible then
		self:ShowFrame()
	end
end


-----------------------
-- Utility Functions --
-----------------------
function Abraxas:CastedCurse(curse)
	--self:Print("CastedCurse " .. curse)
	if curse then		
		curseTarget = UnitName("target")
		curseTime = GetTime()
		curseCasted = curse
	end
end

function Abraxas:HasDebuff(iconPath)
	for i = 1, 16 do
		local debuff = UnitDebuff("target", i)
		if debuff and debuff == iconPath then
			return true
		end
	end
	
	return false
end

function Abraxas:HasTongues()
	return Abraxas:HasDebuff("Interface\\Icons\\Spell_Shadow_CurseOfTounges")
end
function Abraxas:HasShadows()
	return Abraxas:HasDebuff("Interface\\Icons\\Spell_Shadow_CurseOfAchimonde")
end
function Abraxas:HasElements()
	return Abraxas:HasDebuff("Interface\\Icons\\Spell_Shadow_ChillTouch")
end
function Abraxas:HasRecklessness()
	return Abraxas:HasDebuff("Interface\\Icons\\Spell_Shadow_UnholyStrength")
end

function Abraxas:WarlocksAreMoreImportant()
	local result = true
	local warlocks = 0
	local mages = 0
	
	for i = 1, GetNumRaidMembers(), 1 do
		local _, playerClass = UnitClass("Raid" .. i)
		
		if playerClass == "WARLOCK" then
			warlocks = warlocks + 1
		elseif playerClass == "MAGE" then
			mages = mages + 1
		end
	end
	
	if mages > warlocks then
		result = false -- there are more pesky mages than magnificent warlocks
	end
	
	return result
end

function Abraxas:UpdateCursePriority()
	if Abraxas:WarlocksAreMoreImportant() then
		cursePriority[2] = BS["Curse of Shadow"]
		cursePriority[3] = BS["Curse of the Elements"]
	else
		cursePriority[2] = BS["Curse of the Elements"]
		cursePriority[3] = BS["Curse of Shadow"]
	end
end

--[[function Abraxas:GetMostImportantMissingCurse()	
	self:print("GetMostImportantMissingCurse")
	local target = UnitName("target")
	self:print(cursePriority)
	for index, curse in pairs(cursePriority) do
		self:print(index .. " " .. curse)
		if curse == BS["Curse of Tongues"] and tongueTarget[target] and not Abraxas:HasTongues() then
			return curse
		elseif curse == BS["Curse of Shadow"] and not Abraxas:HasShadows() then
			return curse
		elseif curse == BS["Curse of the Elements"] and not Abraxas:HasElements() then
			return curse
		elseif curse == BS["Curse of Recklessness"] and not Abraxas:HasRecklessness() then
			return curse
		end
	end
	
	return nil
end]]

function Abraxas:GetMostImportantMissingCurse()
	local target = UnitName("target")
	local curse = nil
	local priority = 0
	
	if tongueTarget[target] and not Abraxas:HasTongues() then
		curse = BS["Curse of Tongues"]
		priority = cursePriority[BS["Curse of Tongues"]]
	end
	
	if cursePriority[BS["Curse of Shadow"]] > priority and not Abraxas:HasShadows() then
		curse = BS["Curse of Shadow"]
		priority = cursePriority[BS["Curse of Shadow"]]
	end
	
	if cursePriority[BS["Curse of the Elements"]] > priority and not Abraxas:HasElements() then
		curse = BS["Curse of the Elements"]
		priority = cursePriority[BS["Curse of the Elements"]]
	end
	
	if not recklessnessException[target] and cursePriority[BS["Curse of Recklessness"]] > priority and not Abraxas:HasRecklessness() then
		curse = BS["Curse of Recklessness"]
		priority = cursePriority[BS["Curse of Recklessness"]]
	end
	
	return curse
end