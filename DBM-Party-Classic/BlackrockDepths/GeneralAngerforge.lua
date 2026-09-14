local mod	= DBM:NewMod(378, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9033)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 14099 9080 20691",
	"UNIT_HEALTH boss1"
)

local warnBlow			= mod:NewSpellAnnounce(14099, 3, nil, "Tank")
local warnHamstring		= mod:NewSpellAnnounce(9080, 2, nil, "Tank")
local warnCleave		= mod:NewSpellAnnounce(20691, 3, nil, "Tank")
local warnAdds			= mod:NewSpellAnnounce(8901, 4)

local timerBlowCD			= mod:NewCDTimer(18, 14099, nil, "Tank", nil, 3)--Core 8s first, 18s repeat
local timerHamstringCD	= mod:NewCDTimer(15, 9080, nil, "Tank", nil, 2)--Core 12s first, 15s repeat
local timerCleaveCD		= mod:NewCDTimer(9, 20691, nil, "Tank", nil, 3)--Core 16s first, 9s repeat

mod.vb.warnedAdds = false

function mod:OnCombatStart(delay)
	self.vb.warnedAdds = false
	timerBlowCD:Start(8-delay)--Core 8s first
	timerHamstringCD:Start(12-delay)--Core 12s first
	timerCleaveCD:Start(16-delay)--Core 16s first
end

function mod:OnCombatEnd()
	timerBlowCD:Cancel()
	timerHamstringCD:Cancel()
	timerCleaveCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 14099 then -- Mighty Blow (core 18s repeat)
		warnBlow:Show()
		timerBlowCD:Start()
	elseif args.spellId == 9080 then -- Hamstring (core 15s repeat)
		warnHamstring:Show()
		timerHamstringCD:Start()
	elseif args.spellId == 20691 then -- Cleave (core 9s repeat)
		warnCleave:Show()
		timerCleaveCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedAdds and self:GetUnitCreatureId(uId) == 9033 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.21 then
		self.vb.warnedAdds = true
		warnAdds:Show()--Adds + medics below 21%
	end
end
