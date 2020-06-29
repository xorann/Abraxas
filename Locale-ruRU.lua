local L = AceLibrary("AceLocale-2.2"):new("Abraxas")

L:RegisterTranslations("ruRU", 
	function()
		return {
			["Curse"] = "Проклятие",
			["Options for curse"] = "Настройки Проклятия",
			["Set mode"] = "Установить режим",
			["Set which mode should be used for casting curses."] = "Установить, какой режим будет использован для наложения проклятий.",
			["static"] = "статический",
			["dynamic"] = "динамический",
			["Set static curse"] = "Установить статическое проклятие",
			["Set which curse should be casted in static mode."] = "Установить, какое проклятие должно быть наложено в статическом режиме.",
			["Cast curse. \nMacro: |cfB34DFFf/abraxas curse cast|r"] = "Применить заклинание. \nМакрос: |cfB34DFFf/abraxas curse cast|r",
			["Casts Shadow Bolt if all curses are present. \nMacro: |cfB34DFFf/abraxas curse shadowbolt|r"] = "Произнести Стрела Тьмы если все проклятия присутствуют. \nМакрос: |cfB34DFFf/abraxas curse shadowbolt|r",
			["Summon"] = "Призыв",
			["Show the summon window."] = "Показать окно призыва.",
			["Flamewaker Priest"] = "Поджигатель-жрец", --need check (-)
			["Giant Eye Tentacle"] = "Огромное глазастое щупальце",
			["There are still curses missing but you already casted a more important curse"] = "Проклятия все еще нет, но вы уже наложили более важное проклятие",
			["All curses are present."] = "Все проклятия присутствую.",
			["Your Curse of (.+) was resisted by (.+)."] = "(.+) сопротивляется вашему заклинанию \"Проклятие (.+)\".", -- SPELLRESISTSELFOTHER
																																																		
			["Your Curse of %s was |cffff0000resisted|r by %s."] = "%s |cffff0000сопротивляется|r вашему заклинанию \"Проклятие %s\".", --msg print for check^
			["^Curse of (.+) fades from ([%w%s:]+)."] = "^Действие эффекта \"Проклятие (.+)\", наложенного на ([%w%s:]+), заканчивается.", -- AURAREMOVEDOTHER -- NEED CHECK
			["Your curse has faded."] = "Ваше проклятие закончилось.", ----msg print for check^
			["You have slain %s!"] = "Вы убили %s!", -- SELFKILLOTHER
			["Curse of"] = "Проклятие", -- need check
			font = "Fonts\\FRIZQT__.TTF",
			["Abraxas Summon"] = "Призыв Abraxas",
			
			["You are in combat"] = "Вы не можете этого сделать в режиме боя", -- SPELL_FAILED_AFFECTING_COMBAT
			["%s is in combat"] = "%s сражается", -- SPELL_FAILED_TARGET_AFFECTING_COMBAT
			["You can't summon someone from |cffff0000%s|r to %s"] = "Вы не можете вызвать кого-то из |cffff0000%s|r в %s",
			["<Abraxas> Summoning %s to %s"] = "<Abraxas> Призываю %s в %s",
			["<Abraxas> Summoning you to %s"] = "<Abraxas> Призываю тебя в %s",
			["<Abraxas> Please assist summoning %s"] = "<Abraxas> Пожалуйста, помогите призвать %s",
			
			["The Molten Core"] = "Огненные Недра",
			
			["|cffeda55fClick|r to toggle the Summon window. |cffeda55fRight click|r to show the options menu."] = "|cffeda55fКлик|r чтобы открыть окно призыва. |cffeda55fПравый клик|r показать меню настроек.",
			
			-- запрос версии
			["Abraxas Version Query"] = "Запрос версии Abraxas",
			["Abraxas"] = "Abraxas",
			["Runs a version query on Abraxas."] = "Запускает запрос версии для Abraxas.",
			["Querying versions"] = "Запрос версий",
			["N/A"] = "Н/Д",
			["Query already running, please wait 5 seconds before trying again."] = "Запрос уже запущен, пожалуйста, подождите 5 секунд, прежде чем пытаться снова.",
			["Close window"] = "Закрыть окно", -- I know, it's really a Tablet.
			["Green versions are newer than yours, red are older, and white are the same.\nOnly Warlocks are listed."] = "Зеленые версии новее вашей, красные старше и белые одинаковы.\nВ списке указаны только чернокнижники.",
			["Player"] = "Игрок",
			["Version"] = "Версия",
			["Version query done."] = "Запрос версии выполнен.",
			["Closes the version query window."] = "Закрывает окно запроса версии.",
			["Nr Replies"] = "Nr Ответы",
		}
	end
)
