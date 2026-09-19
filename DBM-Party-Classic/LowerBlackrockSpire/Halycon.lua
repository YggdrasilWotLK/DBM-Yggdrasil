local mod	= DBM:NewMod(394, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(10220)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 13738 3391"
)

local warnRend			= mod:NewSpellAnnounce(13738, 3, nil, "Tank|Healer")
local warnThrash		= mod:NewSpellAnnounce(3391, 3, nil, "Tank")

local timerRendCD			= mod:NewCDTimer(9, 13738, nil, "Tank|Healer", nil, 3)--Core 17-20s first, 8-10s repeat

function mod:OnCombatStart(delay)
	timerRendCD:Start(18-delay)--Core 17-20s first (mid)
end

function mod:OnCombatEnd()
	timerRendCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 13738 then -- Rend (core 8-10s repeat)
		warnRend:Show()
		timerRendCD:Start()
	elseif args.spellId == 3391 then -- Thrash, one-shot no repeat in core
		warnThrash:Show()
	end
end
