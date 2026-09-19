local mod	= DBM:NewMod(390, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(9237)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 3391 16075 15284 16856 15618 10966 15615",
	"UNIT_HEALTH boss1"
)

local warnThrash		= mod:NewSpellAnnounce(3391, 3, nil, "Tank")
local warnAxe			= mod:NewSpellAnnounce(16075, 2)
local warnCleave		= mod:NewSpellAnnounce(15284, 3, nil, "Tank")
local warnStrike		= mod:NewSpellAnnounce(16856, 3, nil, "Tank|Healer")
local warnKick			= mod:NewSpellAnnounce(15618, 2, nil, "Tank")
local warnUppercut		= mod:NewSpellAnnounce(10966, 3, nil, "Tank")
local warnPummel		= mod:NewSpellAnnounce(15615, 2)

local timerThrashCD		= mod:NewCDTimer(10, 3391, nil, "Tank", nil, 3)--Core 3s first, 10s repeat (Brawler phase)
local timerAxeCD			= mod:NewCDTimer(8, 16075, nil, nil, nil, 2)--Core 1s first, 8s repeat (Brawler phase)
local timerCleaveCD		= mod:NewCDTimer(12, 15284, nil, "Tank", nil, 3)--Core 14s first, 12s repeat (Thrasher phase)
local timerStrikeCD		= mod:NewCDTimer(10, 16856, nil, "Tank|Healer", nil, 3)--Core 12s first, 10s repeat (Thrasher phase)
local timerKickCD			= mod:NewCDTimer(6, 15618, nil, "Tank", nil, 2)--Core 8s first, 6s repeat (Warmaster phase)
local timerUppercutCD		= mod:NewCDTimer(14, 10966, nil, "Tank", nil, 3)--Core 20s first, 14s repeat (Warmaster phase)
local timerPummelCD		= mod:NewCDTimer(16, 15615, nil, nil, nil, 2)--Core 32s first, 16s repeat (Warmaster phase)

mod.vb.warnedThrasher = false
mod.vb.warnedWarmaster = false

local warnThrasher		= mod:NewPhaseAnnounce(2)
local warnWarmaster		= mod:NewPhaseAnnounce(3)

function mod:OnCombatStart(delay)
	self.vb.warnedThrasher = false
	self.vb.warnedWarmaster = false
	timerThrashCD:Start(3-delay)--Core 3s first
	timerAxeCD:Start(1-delay)--Core 1s first
end

function mod:OnCombatEnd()
	timerThrashCD:Cancel()
	timerAxeCD:Cancel()
	timerCleaveCD:Cancel()
	timerStrikeCD:Cancel()
	timerKickCD:Cancel()
	timerUppercutCD:Cancel()
	timerPummelCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 3391 then -- Thrash (Brawler)
		warnThrash:Show()
		timerThrashCD:Start()
	elseif args.spellId == 16075 then -- Throw Axe (Brawler)
		warnAxe:Show()
		timerAxeCD:Start()
	elseif args.spellId == 15284 then -- Cleave (Thrasher)
		warnCleave:Show()
		timerCleaveCD:Start()
	elseif args.spellId == 16856 then -- Mortal Strike (Thrasher)
		warnStrike:Show()
		timerStrikeCD:Start()
	elseif args.spellId == 15618 then -- Snap Kick (Warmaster)
		warnKick:Show()
		timerKickCD:Start()
	elseif args.spellId == 10966 then -- Uppercut (Warmaster)
		warnUppercut:Show()
		timerUppercutCD:Start()
	elseif args.spellId == 15615 then -- Pummel (Warmaster)
		warnPummel:Show()
		timerPummelCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedThrasher and self:GetUnitCreatureId(uId) == 9237 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.65 then
		self.vb.warnedThrasher = true
		warnThrasher:Show()--Thrasher phase: Cleave + Mortal Strike
		timerCleaveCD:Start(14)
		timerStrikeCD:Start(12)
	elseif not self.vb.warnedWarmaster and self:GetUnitCreatureId(uId) == 9237 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.40 then
		self.vb.warnedWarmaster = true
		warnWarmaster:Show()--Warmaster phase: Kick + Uppercut + Pummel
		timerKickCD:Start(8)
		timerUppercutCD:Start(20)
		timerPummelCD:Start(32)
	end
end
