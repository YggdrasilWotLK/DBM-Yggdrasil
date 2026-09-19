local mod	= DBM:NewMod("Heigan", "DBM-Naxx", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(15936)

mod:RegisterCombat("combat_yell", L.Pull)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 29310 29998 55011",
	"SPELL_AURA_APPLIED 29998 55011"
)

local warnTeleportSoon			= mod:NewAnnounce("WarningTeleportSoon", 2, 46573)
local warnTeleportNow			= mod:NewAnnounce("WarningTeleportNow", 3, 46573)
local warnPlagueCloudEnd		= mod:NewEndAnnounce(29350, 1)
local warnDisruption			= mod:NewSpellAnnounce(29310, 2, nil, "SpellCaster")
local warnFever				= mod:NewTargetNoFilterAnnounce(29998, 2)

local timerTeleport				= mod:NewTimer(90, "TimerTeleport", 46573, nil, nil, 6)
local timerPlagueCloud			= mod:NewBuffActiveTimer(45, 29350, nil, nil, nil, 6)
local timerDisruptionCD		= mod:NewCDTimer(10, 29310, nil, "SpellCaster", nil, 5)--Core 12-15s first, 10s repeat
local timerFeverCD			= mod:NewCDRangeTimer(22, 25, 29998, nil, nil, nil, 3)--Core 17s first, 22-25s repeat

function mod:DancePhase()
	timerPlagueCloud:Start()
	warnTeleportSoon:Schedule(35, 10)
	warnPlagueCloudEnd:Schedule(45)
	self:ScheduleMethod(45, "BackInRoom", 90)
	self:SetStage(2)
end

function mod:BackInRoom(time)
	timerTeleport:Show(time)
	warnTeleportSoon:Schedule(time - 15, 15)
	warnTeleportNow:Schedule(time)
	self:ScheduleMethod(time, "DancePhase")
	self:SetStage(1)
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self:BackInRoom(90 - delay)
	timerDisruptionCD:StartRange(12 - delay, 15 - delay)--Core 12-15s first
	timerFeverCD:Start(17 - delay)--Core 17s first
end

function mod:OnCombatEnd()
	self:UnscheduleMethod("DancePhase")
	self:UnscheduleMethod("BackInRoom")
	timerTeleport:Cancel()
	timerPlagueCloud:Cancel()
	timerDisruptionCD:Cancel()
	timerFeverCD:Cancel()
	warnTeleportSoon:Cancel()
	warnTeleportNow:Cancel()
	warnPlagueCloudEnd:Cancel()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 29310 then -- Spell Disruption (core 10s repeat)
		warnDisruption:Show()
		timerDisruptionCD:Start()
	elseif args:IsSpellID(29998, 55011) then -- Decrepit Fever (core 22-25s repeat)
		timerFeverCD:StartRange(22, 25)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(29998, 55011) then
		warnFever:Show(args.destName)
	end
end