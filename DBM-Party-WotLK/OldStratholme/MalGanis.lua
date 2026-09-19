local mod	= DBM:NewMod("MalGanis", "DBM-Party-WotLK", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26533)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.Outro)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52720 58852 52722 58850 52723",
	"SPELL_AURA_APPLIED 52721 58849",
	"SPELL_AURA_REMOVED 52721 58849"
)

local warningSleep	= mod:NewTargetNoFilterAnnounce(52721, 2)
local warnSwarm		= mod:NewSpellAnnounce(52720, 3)
local warnBlast		= mod:NewSpellAnnounce(52722, 2, nil, "Healer")
local warnTouch		= mod:NewSpellAnnounce(52723, 2, nil, "Healer")

local timerSleep	= mod:NewTargetTimer(10, 52721, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSleepCD	= mod:NewCDTimer(17, 52721, nil, nil, nil, 3)--Core 20s first, 17s repeat
local timerSwarmCD	= mod:NewCDTimer(7, 52720, nil, nil, nil, 3)--Core 7s (was untracked)
local timerBlastCD	= mod:NewCDTimer(6, 52722, nil, "Healer", nil, 3)--Core 6s (was untracked)
local timerTouchCD	= mod:NewCDTimer(30, 52723, nil, "Healer", nil, 3)--Core 30s (was untracked)

function mod:OnCombatStart(delay)
	timerSleepCD:Start(20-delay)--Core 20s first
	timerSwarmCD:Start(7-delay)--Core 7s
	timerBlastCD:Start(6-delay)--Core 6s
	timerTouchCD:Start(30-delay)--Core 30s
end

function mod:OnCombatEnd()
	timerSleepCD:Cancel()
	timerSwarmCD:Cancel()
	timerBlastCD:Cancel()
	timerTouchCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52720, 58852) then -- Carrion Swarm (was untracked)
		warnSwarm:Show()
		timerSwarmCD:Start()
	elseif args:IsSpellID(52722, 58850) then -- Mind Blast (was untracked)
		warnBlast:Show()
		timerBlastCD:Start()
	elseif args.spellId == 52723 then -- Vampiric Touch (was untracked)
		warnTouch:Show()
		timerTouchCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(52721, 58849) then
		warningSleep:Show(args.destName)
		timerSleep:Start(args.destName)
		timerSleepCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(52721, 58849) then
		timerSleep:Cancel(args.destName)
	end
end