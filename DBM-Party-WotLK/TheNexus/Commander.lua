local mod = DBM:NewMod("Commander", "DBM-Party-WotLK", 8)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")

if UnitFactionGroup("player") == "Alliance" then
	mod:SetCreatureID(26798)
else
	mod:SetCreatureID(26796)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 19134",
	"SPELL_CAST_START 38618"
)

local warningFear		= mod:NewSpellAnnounce(19134, 3)
local warningWhirlwind	= mod:NewSpellAnnounce(38618, 3)

local specWarnWW		= mod:NewSpecialWarningRun(38618, "MeleeDps", nil, nil, 4, 2)

local timerFearCD		= mod:NewCDTimer(17, 19134, nil, nil, nil, 2)--Core 10s first, 15-20s repeat
local timerWhirlwindCD	= mod:NewCDTimer(16, 38618, nil, nil, nil, 2)--Core 15s first, 16s repeat

function mod:OnCombatStart(delay)
	timerFearCD:Start(10-delay)--Core 10s first
	timerWhirlwindCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerFearCD:Cancel()
	timerWhirlwindCD:Cancel()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19134 then
		warningFear:Show()
		timerFearCD:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 38618 then -- Whirlwind (core only casts 38618)
		if self.Options.SpecWarn38619run then
			specWarnWW:Show()
			specWarnWW:Play("runaway")
		else
			warningWhirlwind:Show()
		end
		timerWhirlwindCD:Start()
	end
end