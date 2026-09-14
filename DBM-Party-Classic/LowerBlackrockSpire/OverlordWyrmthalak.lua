local mod	= DBM:NewMod(396, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9568)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 11130 23511 20691 20686",
	"UNIT_HEALTH boss1"
)

local warnBlast			= mod:NewSpellAnnounce(11130, 3)
local warnShout			= mod:NewSpellAnnounce(23511, 2, nil, "Healer")
local warnCleave		= mod:NewSpellAnnounce(20691, 3, nil, "Tank")
local warnKnock			= mod:NewSpellAnnounce(20686, 3, nil, "Tank")
local warnAdds			= mod:NewSpellAnnounce(9216, 4)

local timerBlastCD		= mod:NewCDTimer(20, 11130, nil, nil, nil, 3)--Core 20s first and repeat
local timerShoutCD		= mod:NewCDTimer(10, 23511, nil, "Healer", nil, 2)--Core 2s first, 10s repeat
local timerCleaveCD		= mod:NewCDTimer(7, 20691, nil, "Tank", nil, 3)--Core 6s first, 7s repeat
local timerKnockCD		= mod:NewCDTimer(14, 20686, nil, "Tank", nil, 3)--Core 12s first, 14s repeat

mod.vb.warnedAdds = false

function mod:OnCombatStart(delay)
	self.vb.warnedAdds = false
	timerBlastCD:Start(20-delay)--Core 20s first
	timerShoutCD:Start(2-delay)--Core 2s first
	timerCleaveCD:Start(6-delay)--Core 6s first
	timerKnockCD:Start(12-delay)--Core 12s first
end

function mod:OnCombatEnd()
	timerBlastCD:Cancel()
	timerShoutCD:Cancel()
	timerCleaveCD:Cancel()
	timerKnockCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 11130 then -- Blast Wave (core 20s repeat)
		warnBlast:Show()
		timerBlastCD:Start()
	elseif args.spellId == 23511 then -- Shout (core 10s repeat)
		warnShout:Show()
		timerShoutCD:Start()
	elseif args.spellId == 20691 then -- Cleave (core 7s repeat)
		warnCleave:Show()
		timerCleaveCD:Start()
	elseif args.spellId == 20686 then -- Knock Away (core 14s repeat)
		warnKnock:Show()
		timerKnockCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedAdds and self:GetUnitCreatureId(uId) == 9568 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.51 then
		self.vb.warnedAdds = true
		warnAdds:Show()--Spirstone Warlord + Smolderthorn Berserker below 51%
	end
end
