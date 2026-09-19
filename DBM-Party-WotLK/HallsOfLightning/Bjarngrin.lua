local mod	= DBM:NewMod("Bjarngrin", "DBM-Party-WotLK", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(28586)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52027 52026 52029 52022 16856"
)

local warningWhirlwind		= mod:NewSpellAnnounce(52027, 3)
local warnKnock				= mod:NewSpellAnnounce(52029, 2, nil, "Tank")
local warnIronform			= mod:NewSpellAnnounce(52022, 3)

local specWarnWhirlwind		= mod:NewSpecialWarningRun(52027, "Melee", nil, nil, 4, 2)

local timerWhirlwindCD		= mod:NewCDTimer(25, 52027, nil, nil, nil, 2)--Core 25s repeat
local timerKnockCD			= mod:NewCDRangeTimer(20, 21, 52029, nil, "Tank", nil, 3)--Core 20-21s repeat (was untracked)
local timerIronformCD			= mod:NewCDRangeTimer(18, 23, 52022, nil, nil, nil, 3)--Core 18-23s repeat (was untracked)
local timerSlamCD				= mod:NewCDRangeTimer(10, 12, 52026, nil, "Tank", nil, 3)--Core 10-12s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerWhirlwindCD:Start(25-delay)--Core 25s
	timerKnockCD:StartRange(20-delay, 21-delay)--Core 20-21s first
	timerIronformCD:StartRange(18-delay, 23-delay)--Core 18-23s first
	timerSlamCD:StartRange(10-delay, 12-delay)--Core 10-12s first
end

function mod:OnCombatEnd()
	timerWhirlwindCD:Cancel()
	timerKnockCD:Cancel()
	timerIronformCD:Cancel()
	timerSlamCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 52027 then -- Whirlwind (core single ID, 25s repeat)
		if self.Options.SpecWarn52024run then
			specWarnWhirlwind:Show()
			specWarnWhirlwind:Play("runout")
		else
			warningWhirlwind:Show()
		end
		timerWhirlwindCD:Start()
	elseif args.spellId == 52029 then -- Knock Away (was untracked)
		warnKnock:Show()
		timerKnockCD:StartRange(20, 21)
	elseif args.spellId == 52022 then -- Ironform (was untracked)
		warnIronform:Show()
		timerIronformCD:StartRange(18, 23)
	elseif args.spellId == 52026 then -- Slam (was untracked)
		timerSlamCD:StartRange(10, 12)
	end
end