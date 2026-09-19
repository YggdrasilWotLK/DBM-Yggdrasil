local mod	= DBM:NewMod(387, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(9019)--Moira 8929


mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 17492 15636"
)

local warnHand			= mod:NewSpellAnnounce(17492, 3, nil, "Healer")
local warnAvatar		= mod:NewSpellAnnounce(15636, 3)

local timerHandCD			= mod:NewCDTimer(5, 17492, nil, "Healer", nil, 3)--Core 4-7s first and repeat
local timerAvatarCD		= mod:NewCDTimer(25, 15636, nil, nil, nil, 3)--Core 10-12s first, 23-27s repeat

function mod:OnCombatStart(delay)
	timerHandCD:Start(5-delay)--Core 4-7s first (mid)
	timerAvatarCD:Start(11-delay)--Core 10-12s first (mid)
end

function mod:OnCombatEnd()
	timerHandCD:Cancel()
	timerAvatarCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 17492 then -- Hand of Thaurissan (core 4-7s repeat)
		warnHand:Show()
		timerHandCD:Start()
	elseif args.spellId == 15636 then -- Avatar of Flame (core 23-27s repeat)
		warnAvatar:Show()
		timerAvatarCD:Start()
	end
end
