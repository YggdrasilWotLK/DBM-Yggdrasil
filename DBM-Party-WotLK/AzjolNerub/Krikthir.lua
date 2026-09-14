local mod	= DBM:NewMod("Krikthir", "DBM-Party-WotLK", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(28684)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52592 52586 52440",
	"SPELL_AURA_APPLIED 52592",
	"UNIT_HEALTH boss1"
)

local warnCurse	= mod:NewSpellAnnounce(52592, 2)
local warnFlay		= mod:NewSpellAnnounce(52586, 3, nil, "Tank|Healer")
local warnSwarm		= mod:NewSpellAnnounce(52440, 3)

local specWarnCurse	= mod:NewSpecialWarningYou(52592, nil, nil, nil, 1, 2)

local timerCurseCD	= mod:NewCDTimer(30, 52592, nil, nil, nil, 2)--Core 27-35s first and repeat
local timerFlayCD		= mod:NewCDTimer(11, 52586, nil, "Tank|Healer", nil, 3)--Core 8-14s first (was untracked)
local timerSwarmCD	= mod:NewCDTimer(28, 52440, nil, nil, nil, 1)--Core 10-13s first, 26-30s repeat (was untracked)
local timerFrenzy		= mod:NewBuffActiveTimer(10, 28747, nil, nil, nil, 5)--Core at 25%

mod.vb.warnedFrenzy = false

function mod:OnCombatStart(delay)
	timerCurseCD:Start(30-delay)--Core 27-35s first
	timerFlayCD:Start(11-delay)--Core 8-14s first
	timerSwarmCD:Start(11-delay)--Core 10-13s first
	self.vb.warnedFrenzy = false
end

function mod:OnCombatEnd()
	timerCurseCD:Cancel()
	timerFlayCD:Cancel()
	timerSwarmCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 52592 then -- Curse of Fatigue (core single ID, 27-35s repeat)
		warnCurse:Show()
		timerCurseCD:Start()
	elseif args.spellId == 52586 then -- Mind Flay (core 5-9s frenzy repeat, was untracked)
		warnFlay:Show()
		timerFlayCD:Start()
	elseif args.spellId == 52440 then -- Swarm (core 26-30s repeat, was untracked)
		warnSwarm:Show()
		timerSwarmCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 52592 then
		if args:IsPlayer() then
			specWarnCurse:Show()
			specWarnCurse:Play("targetyou")
		end
	elseif args.spellId == 28747 and not self.vb.warnedFrenzy then -- Frenzy at 25%
		self.vb.warnedFrenzy = true
		warnFlay:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedFrenzy and self:GetUnitCreatureId(uId) == 28684 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 then
		self.vb.warnedFrenzy = true
	end
end