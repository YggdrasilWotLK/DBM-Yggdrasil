local mod	= DBM:NewMod("JedogaShadowseeker", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29310)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 56855 60030",
	"SPELL_CAST_SUCCESS 56926 60029"
)

--TODO, GTFO for thundershock shit on ground
--TODO, switch warning for add
local warningThundershock	= mod:NewSpellAnnounce(56926, 3)
local warningCycloneStrike	= mod:NewSpecialWarningClose(56855, nil, nil, nil, 1, 2)--Only warn players near boss

local timerThunderCD		= mod:NewCDRangeTimer(16, 22, 56926, nil, nil, nil, 3)--Core 12s first, 16-22s repeat
local timerCycloneCD		= mod:NewCDRangeTimer(10, 14, 56855, nil, nil, nil, 3)--Core 3s first, 10-14s repeat

function mod:OnCombatStart(delay)
	timerThunderCD:Start(12-delay)--Core 12s first
	timerCycloneCD:Start(3-delay)--Core 3s first
end

function mod:OnCombatEnd()
	timerThunderCD:Cancel()
	timerCycloneCD:Cancel()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(56926, 60029) then
		warningThundershock:Show()
		timerThunderCD:StartRange(16, 22)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(56855, 60030) then -- Cyclone Strike, only warn players near boss
		if self:CheckBossDistance(args.sourceGUID) then
			warningCycloneStrike:Show()
			warningCycloneStrike:Play("runaway")
		end
		timerCycloneCD:StartRange(10, 14)
	end
end