local mod	= DBM:NewMod("Toravon", "DBM-VoA")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220705003611")
mod:SetCreatureID(38433)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 72096 72034 72095 72091",
	"SPELL_CAST_SUCCESS 72104 72090"
)

local warnFreezingGround	= mod:NewSpellAnnounce(72090, 1)
local warnWhiteout			= mod:NewSpellAnnounce(72034, 2)
local warnOrb				= mod:NewSpellAnnounce(72091, 3)

local timerFreezingGroundCD	= mod:NewCDTimer(20, 72090, nil, nil, nil, 3)--Core 7s first, 20s repeat
local timerWhiteout			= mod:NewNextTimer(40, 72034, nil, nil, nil, 2)--Core 25s first, 40s repeat
local timerNextOrb			= mod:NewNextTimer(30, 72091, nil, nil, nil, 1)--Core 12s first, 30s repeat

--local timerToravonEnrage	= mod:NewTimer(300, "ToravonEnrage", 26662)

function mod:OnCombatStart(delay)
	timerNextOrb:Start(12-delay)--Core 12s first
	timerWhiteout:Start(25-delay)--Core 25s first
	timerFreezingGroundCD:Start(7-delay)--Core 7s first
--	timerToravonEnrage:Start(-delay)
end

function mod:OnCombatEnd()
	timerNextOrb:Cancel()
	timerWhiteout:Cancel()
	timerFreezingGroundCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(72096, 72034) then
		warnWhiteout:Show()
		timerWhiteout:Start()
	elseif args:IsSpellID(72095, 72091) then	--Frozen Orb(add)
		warnOrb:Show()
		timerNextOrb:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(72104, 72090) then			-- Freezing Ground (core 20s repeat)
		warnFreezingGround:Show()
		timerFreezingGroundCD:Start()
	end
end