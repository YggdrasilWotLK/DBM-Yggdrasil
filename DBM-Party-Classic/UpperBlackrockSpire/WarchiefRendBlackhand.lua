local mod	= DBM:NewMod("WarchiefRendBlackhand", "DBM-Party-Classic", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(10339, 10429) -- Gyth, Rend
mod:SetMainBossID(10429)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 13736 15284 16856"
)

local warnWhirlwind		= mod:NewSpellAnnounce(13736, 3)
local warnCleave		= mod:NewSpellAnnounce(15284, 3, nil, "Tank")
local warnStrike		= mod:NewSpellAnnounce(16856, 3, nil, "Tank|Healer")

local timerWhirlwindCD	= mod:NewCDRangeTimer(13, 18, 13736, nil, nil, nil, 3)--Core 13-15s first, 13-18s repeat
local timerCleaveCD		= mod:NewCDRangeTimer(10, 14, 15284, nil, "Tank", nil, 3)--Core 15-17s first, 10-14s repeat
local timerStrikeCD		= mod:NewCDRangeTimer(14, 18, 16856, nil, "Tank|Healer", nil, 3)--Core 17-19s first, 14-18s repeat

function mod:OnCombatStart(delay)
	timerWhirlwindCD:StartRange(13-delay, 15-delay)--Core 13-15s first
	timerCleaveCD:StartRange(15-delay, 17-delay)--Core 15-17s first
	timerStrikeCD:StartRange(17-delay, 19-delay)--Core 17-19s first
end

function mod:OnCombatEnd()
	timerWhirlwindCD:Cancel()
	timerCleaveCD:Cancel()
	timerStrikeCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 13736 then -- Whirlwind (core 13-18s repeat)
		warnWhirlwind:Show()
		timerWhirlwindCD:StartRange(13, 18)
	elseif args.spellId == 15284 then -- Cleave (core 10-14s repeat)
		warnCleave:Show()
		timerCleaveCD:StartRange(10, 14)
	elseif args.spellId == 16856 then -- Mortal Strike (core 14-18s repeat)
		warnStrike:Show()
		timerStrikeCD:StartRange(14, 18)
	end
end
