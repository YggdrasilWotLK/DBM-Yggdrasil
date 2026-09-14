local mod	= DBM:NewMod("Kormok", "DBM-Party-Classic", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(10447)--Kormok the Ravager

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 20741 27687 27688",
	"UNIT_HEALTH boss1"
)

local warnVolley		= mod:NewSpellAnnounce(20741, 3, nil, "Healer")
local warnMinions		= mod:NewSpellAnnounce(27687, 3)
local warnShield		= mod:NewSpellAnnounce(27688, 2)
local warnMages			= mod:NewSpellAnnounce(27695, 4)

local timerVolleyCD		= mod:NewCDTimer(15, 20741, nil, "Healer", nil, 3)--Core 10s first, 15s repeat
local timerMinionsCD	= mod:NewCDTimer(12, 27687, nil, nil, nil, 1)--Core 15s first, 12s repeat
local timerShieldCD		= mod:NewCDTimer(45, 27688, nil, nil, nil, 2)--Core 45s repeat (2s after summon)

mod.vb.warnedMages = false

function mod:OnCombatStart(delay)
	self.vb.warnedMages = false
	timerVolleyCD:Start(10-delay)--Core 10s first
	timerMinionsCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerVolleyCD:Cancel()
	timerMinionsCD:Cancel()
	timerShieldCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 20741 then -- Shadowbolt Volley (core 15s repeat)
		warnVolley:Show()
		timerVolleyCD:Start()
	elseif args.spellId == 27687 then -- Summon Bone Minions (core 12s repeat)
		warnMinions:Show()
		timerMinionsCD:Start()
		timerShieldCD:Start(2)--Bone Shield 2s after summon
	elseif args.spellId == 27688 then -- Bone Shield (core 45s repeat)
		warnShield:Show()
		timerShieldCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedMages and self:GetUnitCreatureId(uId) == 10447 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 then
		self.vb.warnedMages = true
		warnMages:Show()--Bone Mages below 25%, once
	end
end
