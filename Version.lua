local L = AceLibrary("AceLocale-2.2"):new("Abraxas")
--local module = Abraxas
local module = Abraxas:NewModule("Version Query")
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

local COLOR_GREEN = "00ff00"
local COLOR_RED = "ff0000"
local COLOR_WHITE = "ffffff"


------------------------------
--      Initialization      --
------------------------------
function module:OnEnable()
	self.queryRunning = nil
	self.responseTable = {}
end


------------------------------
--      Event Handlers      --
------------------------------
function module:UpdateTablet()
    if not tablet:IsRegistered("Abraxas_VersionQuery") then
		tablet:Register("Abraxas_VersionQuery",
			"children", function() tablet:SetTitle(L["Abraxas Version Query"])
				self:OnTooltipUpdate() end,
			"clickable", true,
			"showTitleWhenDetached", true,
			"showHintWhenDetached", true,
			"cantAttach", true,
			"menu", function()
					dewdrop:AddLine(
						"text", L["Abraxas"],
						"tooltipTitle", L["Abraxas"],
						"tooltipText", L["Runs a version query on Abraxas."],
						"func", function() self:QueryVersion("Abraxas") end)
					dewdrop:AddLine(
						"text", L["Close window"],
						"tooltipTitle", L["Close window"],
						"tooltipText", L["Closes the version query window."],
						"func", function() tablet:Attach("Abraxas_VersionQuery"); dewdrop:Close() end)
				end
		)
	end
	if tablet:IsAttached("Abraxas_VersionQuery") then
		tablet:Detach("Abraxas_VersionQuery")
	else
		tablet:Refresh("Abraxas_VersionQuery")
	end
end

function module:OnTooltipUpdate()
	local playerscat = tablet:AddCategory(
		"columns", 1,
		"text", L["Nr Replies"],
		"child_justify1", "LEFT"
	)
	playerscat:AddLine("text", self.responses)
	local cat = tablet:AddCategory(
		"columns", 2,
		"text", L["Player"],
		"text2", L["Version"],
		"child_justify1", "LEFT",
		"child_justify2", "RIGHT"
	)
	
	for name, version in pairs(self.responseTable) do
		if version == -1 then
			cat:AddLine("text", name, "text2", "|cff" .. COLOR_RED .. L["N/A"] .."|r")
		else
			local color = COLOR_WHITE
			
			if Abraxas.revision > version then
				color = COLOR_GREEN
			elseif Abraxas.revision < version then
				color = COLOR_RED
			end
			
			cat:AddLine("text", name, "text2", "|cff"..color..version.."|r")
		end
	end

	tablet:SetHint(L["Green versions are newer than yours, red are older, and white are the same.\nOnly Warlocks are listed."])
end

function module:QueryVersion()
	if self.queryRunning then
		Abraxas:Print(L["Query already running, please wait 5 seconds before trying again."])
		return
	end

    Abraxas:Print(L["Querying versions"])

	self.queryRunning = true
	Abraxas:ScheduleEvent(	function()
            self.queryRunning = nil
            Abraxas:Print(L["Version query done."])
        end, 5)

	self.responseTable = {}

	local _, class = UnitClass("player")
	if class == "WARLOCK" then
		self.responseTable[UnitName("player")] = Abraxas.revision
		self.responses = 1
	end
	
	Abraxas:Sync("AbraxasVersionQuery")
	self:UpdateTablet()
end

function module:VersionQueryReply(sender, rest)
	local rev, queryNick = self:ParseReply(rest)
	local unitId = Abraxas:GetUnitId(sender)
	local _, class = UnitClass(unitId)
	
	if queryNick == UnitName("player") and class == "WARLOCK" then
		self.responseTable[sender] = tonumber(rev)
		self.responses = self.responses + 1
		self:UpdateTablet()
	end
end

-- Parses the reply, which is "<version> <nick>"
function module:ParseReply(reply)
	-- If there's no space, it's just a version number we got.
	local first, last = string.find(reply, " ")
	if not first or not last then 
		return reply, nil 
	end

	local rev = string.sub(reply, 1, first)
	local nick = string.sub(reply, last + 1, string.len(reply))

	return tonumber(rev), nick
end