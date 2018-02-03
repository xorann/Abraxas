local L = AceLibrary("AceLocale-2.2"):new("Abraxas")

L:RegisterTranslations("deDE", 
	function()
		return {
			["Curse"] = "Fluch",
			["Options for curse"] = "Optionen für Flüche",
			["Set mode"] = "Modus setzen",
			["Set which mode should be used for casting curses."] = "Definiert den Fluchmodus.",
			["static"] = "statisch",
			["dynamic"] = "dynamisch",
			["Set static curse"] = "Statischer Fluch definieren",
			["Set which curse should be casted in static mode."] = "Fluch für statischen Modus definieren",
			["Cast curse. \nMacro: |cfB34DFFf/abraxas curse cast|r"] = "Fluch zaubern. \nMakro: |cfB34DFFf/abraxas curse cast|r",
			["Casts Shadow Bolt if all curses are present. \nMacro: |cfB34DFFf/abraxas curse shadowbolt|r"] = "Zaubert Schattenblitz wenn alle Flüche vorhanden sind. \Makro: |cfB34DFFf/abraxas curse shadowbolt|r",
			["Summon"] = "Beschwören",
			["Show the summon window."] = "Beschwörungsfenster anzeigen",
			["Flamewaker Priest"] = "Feuerschuppenpriester",
			["Giant Eye Tentacle"] = "Riesieges Augententakel",
			["There are still curses missing but you already casted a more important curse"] = "Gewisse Flüche fehlen noch, aber du hast bereits einen wichtigeren Fluch gezaubert.",
			["All curses are present."] = "Alle Flüche vorhanden.",
			["Your Curse of (.+) was resisted by (.+)."] = "Ihr habt es mit Fluch der (.+) versucht, aber (.+) hat widerstanden.", -- Ihr habt es mit Versengen versucht, aber Der Prophet Skeram hat widerstanden.
			["Your Curse of %s was |cffff0000resisted|r by %s."] = "Dein Fluch der %s wurde widerstanden von %s",
			["^Curse of (.+) fades from ([%w%s:]+)."] = "^Fluch der (.+) schwindet von ([%w%s:]+).",
			["Your curse has faded."] = "Dein Fluch ist ausgelaufen.",
			["You have slain %s!"] = "Ihr habt %s getötet!", --Ihr habt Bohrer der Vekniss getötet!
			["Curse of"] = "Fluch der",
			font = "Fonts\\FRIZQT__.TTF",
			["Abraxas Summon"] = "Abraxas Beschwörung",	
			
			["You are in combat"] = "Du bist im Kampf",
			["%s is in combat"] = "%s ist im Kampf",
			["You can't summon someone from |cffff0000%s|r to %s"] = "Du kannst nicht jemanden von |cff000000%s|r nach %s beschwören",
			["<Abraxas> Summoning %s to %s"] = "<Abraxas> Beschwöre %s nach %s",
			["<Abraxas> Summoning you to %s"] = "<Abraxas> Beschwöre dich nach %s",
			["<Abraxas> Please assist summoning %s"] = "<Abraxas> Bitte beim Beschwören von %s helfen",
			
			["The Molten Core"] = "Der Geschmolzene Kern",
			
			["|cffeda55fClick|r to toggle the Summon window. |cffeda55fRight click|r to show the options menu."] = "|cffeda55fKlicken|r um das Beschwören-Fenster anzuzeigen/verstecken. |cffeda55fRechtsklick|r um die Optionen anzuzeigen.",
			
			-- version query
			["Abraxas Version Query"] = "Abraxas Versionsabfrage",
			--["Abraxas"] = true,
			["Runs a version query on Abraxas."] = "Versionsabfrage für Abraxas starten.",
			["Querying versions"] = "Frage Version ab",
			["N/A"] = "kA",
			["Query already running, please wait 5 seconds before trying again."] = "Abfrage l\195\164uft bereits, bitte 5 Sekunden warten bis zum n\195\164chsten Versuch.",
			["Query already running, please wait 5 seconds before trying again."] = "Abfrage l\195\164uft bereits, bitte 5 Sekunden warten bis zum n\195\164chsten Versuch.",
			["Close window"] = "Schlie\195\159e Fenster", -- I know, it's really a Tablet.
			["Green versions are newer than yours, red are older, and white are the same.\nOnly Warlocks are listed."] = "Gr\195\188ne Versionen sind neuer, rote sind \195\164lter, wei\195\159e sind gleich.\nNur Hexenmeister werden aufgeführt.",
			["Player"] = "Spieler",
			["Version"] = "Version",
			["Version query done."] = "Versionsabfrage beendet.",
			["Closes the version query window."] = "Schlie\195\159t das Versionsabfrage-Fenster.",
			["Nr Replies"] = "Anzahl der Antworten",
		}
	end
)