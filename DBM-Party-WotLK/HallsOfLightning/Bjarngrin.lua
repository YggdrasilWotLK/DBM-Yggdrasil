local mod	= DBM:NewMod("Bjarngrin", "DBM-Party-WotLK", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
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
local timerKnockCD			= mod:NewCDTimer(20, 52029, nil, "Tank", nil, 3)--Core 20-21s repeat (was untracked)
local timerIronformCD			= mod:NewCDTimer(20, 52022, nil, nil, nil, 3)--Core 18-23s repeat (was untracked)
local timerSlamCD				= mod:NewCDTimer(11, 52026, nil, "Tank", nil, 3)--Core 10-12s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerWhirlwindCD:Start(25-delay)--Core 25s
	timerKnockCD:Start(20-delay)--Core 20-21s first
	timerIronformCD:Start(20-delay)--Core 18-23s first
	timerSlamCD:Start(11-delay)--Core 10-12s first
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
		timerKnockCD:Start()
	elseif args.spellId == 52022 then -- Ironform (was untracked)
		warnIronform:Show()
		timerIronformCD:Start()
	elseif args.spellId == 52026 then -- Slam (was untracked)
		timerSlamCD:Start()
	end
end