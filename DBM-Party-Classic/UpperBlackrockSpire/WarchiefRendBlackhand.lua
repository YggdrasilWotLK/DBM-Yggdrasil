local mod	= DBM:NewMod("WarchiefRendBlackhand", "DBM-Party-Classic", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(10339, 10429) -- Gyth, Rend
mod:SetMainBossID(10429)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 13736 15284 16856"
)

local warnWhirlwind		= mod:NewSpellAnnounce(13736, 3)
local warnCleave		= mod:NewSpellAnnounce(15284, 3, nil, "Tank")
local warnStrike		= mod:NewSpellAnnounce(16856, 3, nil, "Tank|Healer")

local timerWhirlwindCD	= mod:NewCDTimer(15, 13736, nil, nil, nil, 3)--Core 13-15s first, 13-18s repeat
local timerCleaveCD		= mod:NewCDTimer(12, 15284, nil, "Tank", nil, 3)--Core 15-17s first, 10-14s repeat
local timerStrikeCD		= mod:NewCDTimer(16, 16856, nil, "Tank|Healer", nil, 3)--Core 17-19s first, 14-18s repeat

function mod:OnCombatStart(delay)
	timerWhirlwindCD:Start(14-delay)--Core 13-15s first (mid)
	timerCleaveCD:Start(16-delay)--Core 15-17s first (mid)
	timerStrikeCD:Start(18-delay)--Core 17-19s first (mid)
end

function mod:OnCombatEnd()
	timerWhirlwindCD:Cancel()
	timerCleaveCD:Cancel()
	timerStrikeCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 13736 then -- Whirlwind (core 13-18s repeat)
		warnWhirlwind:Show()
		timerWhirlwindCD:Start()
	elseif args.spellId == 15284 then -- Cleave (core 10-14s repeat)
		warnCleave:Show()
		timerCleaveCD:Start()
	elseif args.spellId == 16856 then -- Mortal Strike (core 14-18s repeat)
		warnStrike:Show()
		timerStrikeCD:Start()
	end
end
