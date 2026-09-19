local mod	= DBM:NewMod("Zuramat", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29314)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54361 54524 54369",
	"SPELL_AURA_APPLIED 59743 54361 54343 59745 54524"
)

local warningVoidShift			= mod:NewTargetNoFilterAnnounce(59743, 2)
local warningShroudofDarkness	= mod:NewTargetNoFilterAnnounce(59745, 3)
local warnSentry				= mod:NewSpellAnnounce(54369, 3)

local specWarnVoidShifted		= mod:NewSpecialWarningYou(54343, nil, nil, nil, 1, 2)
local specWarnShroud			= mod:NewSpecialWarningDispel(59745, "MagicDispeller", nil, nil, 1, 2)

local timerVoidShift			= mod:NewTargetTimer(5, 59743)
local timerVoidShifted			= mod:NewTargetTimer(15, 54343)
local timerVoidShiftCD		= mod:NewCDTimer(20, 54361, nil, nil, nil, 3)--Core 23-25s first, 18-22s repeat
local timerShroudCD			= mod:NewCDTimer(20, 54524, nil, nil, nil, 3)--Core 5-7s first, 20s repeat
local timerSentryCD			= mod:NewCDTimer(12, 54369, nil, nil, nil, 1)--Core 10s first, 12s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerVoidShiftCD:Start(24-delay)--Core 23-25s first
	timerShroudCD:Start(6-delay)--Core 5-7s first
	timerSentryCD:Start(10-delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerVoidShiftCD:Cancel()
	timerShroudCD:Cancel()
	timerSentryCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54361 then -- Void Shift (core 18-22s repeat)
		timerVoidShiftCD:Start()
	elseif args.spellId == 54524 then -- Shroud of Darkness (core 20s repeat)
		timerShroudCD:Start()
	elseif args.spellId == 54369 then -- Summon Void Sentry (core 12s repeat, was untracked)
		warnSentry:Show()
		timerSentryCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(59743, 54361) then			-- Void Shift			59743 (HC)  54361 (nonHC)
		warningVoidShift:Show(args.destName)
		timerVoidShift:Start(args.destName)
	elseif args.spellId == 54343 then
		if args:IsPlayer() then
			specWarnVoidShifted:Show()
			specWarnVoidShifted:Play("targetyou")
		end
		timerVoidShifted:Start(args.destName)
	elseif args:IsSpellID(59745, 54524) then		-- Shroud of Darkness	59745 (HC)   54524 (nonHC)
		if self.Options.SpecWarn59745dispel then
			specWarnShroud:Show(args.destName)
			specWarnShroud:Play("dispelboss")
		else
			warningShroudofDarkness:Show(args.destName)
		end
	end
end