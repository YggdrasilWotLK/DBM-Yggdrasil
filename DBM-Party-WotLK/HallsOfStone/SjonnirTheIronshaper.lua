local mod	= DBM:NewMod("SjonnirTheIronshaper", "DBM-Party-WotLK", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(27978)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 50830 59844 50831 59845",
	"SPELL_AURA_APPLIED 59848 50840 59861 51849 50834 59846"
)

local warningCharge		= mod:NewTargetAnnounce(50834, 2)
local warningRing		= mod:NewSpellAnnounce(50840, 3)
local warnChain			= mod:NewSpellAnnounce(50830, 2)
local warnShield		= mod:NewSpellAnnounce(50831, 2)

local specWarnCharge	= mod:NewSpecialWarningMoveAway(50834, nil, nil, nil, 1, 2)
local yellCharge		= mod:NewYell(50834)

local timerCharge		= mod:NewTargetTimer(10, 50834)
local timerChargeCD		= mod:NewCDTimer(20, 50834, nil, nil, nil, 3)--Core 20s repeat
local timerRingCD			= mod:NewCDTimer(28, 50840, nil, nil, nil, 2)--Core 25-31s repeat
local timerChainCD		= mod:NewCDTimer(9, 50830, nil, nil, nil, 3)--Core 6-12s (was untracked)
local timerShieldCD		= mod:NewCDTimer(16, 50831, nil, nil, nil, 3)--Core 14-19s (was untracked)

function mod:OnCombatStart(delay)
	timerChargeCD:Start(20-delay)--Core 20s
	timerRingCD:Start(28-delay)--Core 25-31s (mid)
	timerChainCD:Start(9-delay)--Core 6-12s (mid)
	timerShieldCD:Start(16-delay)--Core 14-19s (mid)
end

function mod:OnCombatEnd()
	timerChargeCD:Cancel()
	timerRingCD:Cancel()
	timerChainCD:Cancel()
	timerShieldCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(50830, 59844) then -- Chain Lightning (core 6-12s, was untracked)
		warnChain:Show()
		timerChainCD:Start()
	elseif args:IsSpellID(50831, 59845) then -- Lightning Shield (core 14-19s, was untracked)
		warnShield:Show()
		timerShieldCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(59848, 50840, 59861, 51849) then -- Lightning Ring (59861/51849 kept as fallback per tactic)
		warningRing:Show()
		timerRingCD:Start()
	elseif args:IsSpellID(50834, 59846) then
		if args:IsPlayer() then
			specWarnCharge:Show()
			specWarnCharge:Play("runout")
			yellCharge:Yell()
		else
			warningCharge:Show(args.destName)
		end
		timerCharge:Start(args.destName)
		timerChargeCD:Start()
	end
end