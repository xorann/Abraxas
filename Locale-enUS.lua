local L = AceLibrary("AceLocale-2.2"):new("Abraxas")

L:RegisterTranslations("enUS", 
	function()
		return {
			["Curse"] = true,
			["Options for curse"] = true,
			["Set mode"] = true,
			["Set which mode should be used for casting curses."] = true,
			["static"] = true,
			["dynamic"] = true,
			["Set static curse"] = true,
			["Set which curse should be casted in static mode."] = true,
			["Cast curse. \nMacro: |cfB34DFFf/abraxas curse cast|r"] = true,
			["Casts Shadow Bolt if all curses are present. \nMacro: |cfB34DFFf/abraxas curse shadowbolt|r"] = true,
			["Summon"] = true,
			["Show the summon window."] = true,
			["Flamewaker Priest"] = true,
			["Giant Eye Tentacle"] = true,
			["There are still curses missing but you already casted a more important curse"] = true,
			["All curses are present."] = true,
			["Your Curse of (.+) was resisted by (.+)."] = true,
			["Your Curse of %s was |cffff0000resisted|r by %s."] = true,
			["^Curse of (.+) fades from ([%w%s:]+)."] = true,
			["Your curse has faded."] = true,
			["You have slain %s!"] = true,
			["Curse of"] = true,
			font = "Fonts\\FRIZQT__.TTF",
			["Abraxas Summon"] = true,
			
			["You are in combat"] = true,
			["%s is in combat"] = true,
			["You can't summon someone from |cffff0000%s|r to %s"] = true,
			["<Abraxas> Summoning %s to %s"] = true,
			["<Abraxas> Summoning you to %s"] = true,
			["<Abraxas> Please assist summoning %s"] = true,
			
			["The Molten Core"] = true,
			
			["|cffeda55fClick|r to toggle the Summon window. |cffeda55fRight click|r to show the options menu."] = true,
			
			-- version query
			["Abraxas Version Query"] = true,
			["Abraxas"] = true,
			["Runs a version query on Abraxas."] = true,
			["Querying versions"] = true,
			["N/A"] = true,
			["Query already running, please wait 5 seconds before trying again."] = true,
			["Close window"] = true, -- I know, it's really a Tablet.
			["Green versions are newer than yours, red are older, and white are the same.\nOnly Warlocks are listed."] = true,
			["Player"] = true,
			["Version"] = true,
			["Version query done."] = true,
			["Closes the version query window."] = true,
			["Nr Replies"] = true,
		}
	end
)
