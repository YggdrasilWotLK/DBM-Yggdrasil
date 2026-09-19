local mod	= DBM:NewMod("SkadiTheRuthless", "DBM-Party-WotLK", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26693)
mod:SetMinSyncRevision(3108)

mod:RegisterCombat("yell", L.Phase2)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 50255 59331 50234 59330",
	"SPELL_AURA_APPLIED 50258 59334 50228 59322",
	"SPELL_AURA_REMOVED 50258 59334"
)

local warnPhase2			= mod:NewPhaseAnnounce(2)
local warningPoisonDebuff	= mod:NewTargetNoFilterAnnounce(50258, 2, nil, "Healer")
local warnCrush			= mod:NewSpellAnnounce(50234, 3, nil, "Tank")

local specWarnWhirlwind		= mod:NewSpecialWarningRun(50228, nil, nil, 2, 4, 2)

local timerPoisonDebuff		= mod:NewTargetTimer(12, 50258, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerPoisonCD			= mod:NewCDTimer(10, 59331, nil, "Healer", nil, 5)
local timerWhirlwindCD		= mod:NewCDRangeTimer(15, 20, 50228, nil, nil, nil, 2)--Core 15s first, 15-20s repeat
local timerCrushCD			= mod:NewCDTimer(8, 50234, nil, "Tank", nil, 3)--Core 8s first and repeat
local timerAchieve			= mod:NewAchievementTimer(180, 1873)

function mod:OnCombatEnd()
	timerPoisonCD:Cancel()
	timerWhirlwindCD:Cancel()
	timerCrushCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(50255, 59331) then
		timerPoisonCD:Start() -- Poisoned Spear throw
	elseif args:IsSpellID(50234, 59330) then -- Crush (core 8s repeat, was untracked)
		warnCrush:Show()
		timerCrushCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(50258, 59334) then
		warningPoisonDebuff:Show(args.destName)
		timerPoisonDebuff:Start(args.destName)
	elseif args:IsSpellID(50228, 59322) then -- Whirlwind (core casts 50228 both modes; 59322 heroic fallback)
		timerWhirlwindCD:StartRange(15, 20)
		specWarnWhirlwind:Show()
		specWarnWhirlwind:Play("runout")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(50258, 59334) then
		timerPoisonDebuff:Cancel(args.destName)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Phase2 or msg:find(L.Phase2) then
		warnPhase2:Show()
	elseif msg == L.CombatStart or msg:find(L.CombatStart) then
		if not self:IsDifficulty("normal5") then
			timerAchieve:Start()
		end
	end
end