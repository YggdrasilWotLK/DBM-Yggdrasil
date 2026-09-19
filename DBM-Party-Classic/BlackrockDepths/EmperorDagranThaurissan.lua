local mod	= DBM:NewMod(387, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(9019)--Moira 8929


mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 17492 15636"
)

local warnHand			= mod:NewSpellAnnounce(17492, 3, nil, "Healer")
local warnAvatar		= mod:NewSpellAnnounce(15636, 3)

local timerHandCD			= mod:NewCDRangeTimer(4, 7, 17492, nil, "Healer", nil, 3)--Core 4-7s first and repeat
local timerAvatarCD		= mod:NewCDRangeTimer(23, 27, 15636, nil, nil, nil, 3)--Core 10-12s first, 23-27s repeat

function mod:OnCombatStart(delay)
	timerHandCD:StartRange(4-delay, 7-delay)--Core 4-7s first
	timerAvatarCD:StartRange(10-delay, 12-delay)--Core 10-12s first
end

function mod:OnCombatEnd()
	timerHandCD:Cancel()
	timerAvatarCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 17492 then -- Hand of Thaurissan (core 4-7s repeat)
		warnHand:Show()
		timerHandCD:StartRange(4, 7)
	elseif args.spellId == 15636 then -- Avatar of Flame (core 23-27s repeat)
		warnAvatar:Show()
		timerAvatarCD:StartRange(23, 27)
	end
end
