local mod	= DBM:NewMod("Lavanthor", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29312)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54235 54282 54249 59466"
)

local warnBolt		= mod:NewSpellAnnounce(54235, 2)
local warnBreath	= mod:NewSpellAnnounce(54282, 3, nil, "Tank")
local warnBurn		= mod:NewSpellAnnounce(54249, 3)

local timerBoltCD		= mod:NewCDRangeTimer(5, 13, 54235, nil, nil, nil, 2)--Core 1s first, 5-13s repeat
local timerBreathCD		= mod:NewCDRangeTimer(10, 15, 54282, nil, "Tank", nil, 3)--Core 5s first, 10-15s repeat
local timerBurnCD			= mod:NewCDRangeTimer(14, 20, 54249, nil, nil, nil, 3)--Core 10s first, 14-20s repeat
local timerCauterCD		= mod:NewCDRangeTimer(10, 16, 59466, nil, nil, nil, 3)--Heroic 3s first, 10-16s repeat

function mod:OnCombatStart(delay)
	timerBoltCD:Start(5-delay)--Core 1s first (grace)
	timerBreathCD:Start(5-delay)--Core 5s first
	timerBurnCD:Start(10-delay)--Core 10s first
	if self:IsDifficulty("heroic5") then
		timerCauterCD:Start(3-delay)--Core 3s first (heroic)
	end
end

function mod:OnCombatEnd()
	timerBoltCD:Cancel()
	timerBreathCD:Cancel()
	timerBurnCD:Cancel()
	timerCauterCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54235 then -- Firebolt (core 5-13s repeat)
		warnBolt:Show()
		timerBoltCD:StartRange(5, 13)
	elseif args.spellId == 54282 then -- Flame Breath (core 10-15s repeat)
		warnBreath:Show()
		timerBreathCD:StartRange(10, 15)
	elseif args.spellId == 54249 then -- Lava Burn (core 14-20s repeat)
		warnBurn:Show()
		timerBurnCD:StartRange(14, 20)
	elseif args.spellId == 59466 then -- Cauterizing Flames (heroic; core casts Flame Breath by bug, warn anyway)
		timerCauterCD:StartRange(10, 16)
	end
end