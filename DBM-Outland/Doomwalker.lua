local mod	= DBM:NewMod("Doomwalker", "DBM-Outland")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914190606")
mod:SetCreatureID(17711)
mod:SetModelID(21435)
mod:EnableWBEngageSync()--Enable syncing engage in outdoors

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 32637 32636",--32636 is the core Overrun ID, 32637 kept as fallback
	"SPELL_AURA_APPLIED 32686"
)

local warnCharge			= mod:NewSpellAnnounce(32637, 3)
local warnQuake				= mod:NewSpellAnnounce(32686, 3)

local timerChargeMinCD			= mod:NewCDTimer(25, 32637, nil, nil, nil, 3)--Core 25-40s RNG: earliest recast
local timerChargeCD			= mod:NewCDTimer(40, 32637, nil, nil, nil, 3)--Core 25-40s RNG; max bar (was 42)
local timerQuakeCD			= mod:NewCDTimer(52, 32686, nil, nil, nil, 2)
local timerQuake			= mod:NewBuffActiveTimer(8, 32686, nil, nil, nil, 2)

mod:AddRangeFrameOption("10")

function mod:OnCombatStart(delay)
	timerChargeMinCD:Start(30-delay)--Core first 30-45s (min)
	timerChargeCD:Start(45-delay)--Core first 30-45s (max)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(32637, 32636) and self:AntiSpam(10, 1) then
		warnCharge:Show()
		timerChargeMinCD:Cancel()
		timerChargeCD:Cancel()
		timerChargeMinCD:Start(25)
		timerChargeCD:Start(40)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32686 and self:AntiSpam(30, 2) then
		warnQuake:Show()
		timerQuake:Start()
		timerQuakeCD:Start()
	end
end