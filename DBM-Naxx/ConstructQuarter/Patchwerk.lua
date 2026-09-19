local mod	= DBM:NewMod("Patchwerk", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231415")
mod:SetCreatureID(16028)

mod:RegisterCombat("combat_yell", L.yell1, L.yell2)

mod:RegisterEventsInCombat(
	"SPELL_DAMAGE 41926 59192",
	"SPELL_MISSED 41926 59192",
	"SPELL_AURA_APPLIED 28131",
	"UNIT_HEALTH boss1"
)

local enrageTimer	= mod:NewBerserkTimer(360)
local timerAchieve	= mod:NewAchievementTimer(180, 1857)
local warnFrenzy	= mod:NewSpellAnnounce(28131, 4, nil, "Tank|Healer")

mod:AddBoolOption("WarningHateful", false, "announce", nil, nil, nil, 41926)

local function announceStrike(target, damage)
	SendChatMessage(L.HatefulStrike:format(target, damage), "RAID")
end

mod.vb.warnedFrenzy = false

function mod:OnCombatStart(delay)
	enrageTimer:Start(-delay)
	timerAchieve:Start(-delay)
	self.vb.warnedFrenzy = false
end

function mod:SPELL_DAMAGE(_, _, _, _, destName, _, spellId, _, _, amount)
	if (spellId == 41926 or spellId == 59192) and self.Options.WarningHateful and DBM:GetRaidRank() >= 1 then
		announceStrike(destName, amount or 0)
	end
end

function mod:SPELL_MISSED(_, _, _, _, destName, _, spellId, _, _, missType)
	if (spellId == 41926 or spellId == 59192) and self.Options.WarningHateful and DBM:GetRaidRank() >= 1 then
		announceStrike(destName, getglobal("ACTION_SPELL_MISSED_"..(missType)) or "")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 28131 and not self.vb.warnedFrenzy then -- Frenzy at 5%
		self.vb.warnedFrenzy = true
		warnFrenzy:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedFrenzy and self:GetUnitCreatureId(uId) == 16028 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.05 then
		self.vb.warnedFrenzy = true
		warnFrenzy:Show()
	end
end