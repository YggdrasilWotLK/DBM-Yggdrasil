local mod	= DBM:NewMod("ChronoLordEpoch", "DBM-Party-WotLK", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26532)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52771 58830 52766",
	"SPELL_CAST_SUCCESS 58848 52766",
	"SPELL_AURA_APPLIED 52772",
	"SPELL_AURA_REMOVED 52772"
)

local warningTime	= mod:NewSpellAnnounce(58848, 3)
local warningCurse	= mod:NewTargetNoFilterAnnounce(52772, 2, nil, "RemoveCurse", 2)
local warnStrike	= mod:NewSpellAnnounce(52771, 3, nil, "Tank")

local timerCurse	= mod:NewTargetTimer(10, 52772, nil, "RemoveCurse", nil, 5, nil, DBM_COMMON_L.CURSE_ICON)
local timerTimeCD	= mod:NewCDTimer(25, 52766, nil, nil, nil, 2)--Time Warp 25s; heroic Time Stop 20s
local timerStrikeCD	= mod:NewCDTimer(6, 52771, nil, "Tank", nil, 3)--Core every 6s (was untracked)

function mod:OnCombatStart(delay)
	timerTimeCD:Start(25-delay)--Core Warp 25s
	timerStrikeCD:Start(6-delay)--Core every 6s
end

function mod:OnCombatEnd()
	timerTimeCD:Cancel()
	timerStrikeCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52771, 58830) then -- Wounding Strike (core every 6s, was untracked)
		warnStrike:Show()
		timerStrikeCD:Start()
	elseif args.spellId == 52766 then -- Time Warp (core 25s; heroic Stop 58848 is 20s; SUCCESS fallback shares AntiSpam key below)
		if self:AntiSpam(5, "Warp") then
			warningTime:Show()
		end
		timerTimeCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 58848 then -- Time Stop, heroic-only 20s (was merged as 25s)
		warningTime:Show()
		timerTimeCD:Start(20)
	elseif args.spellId == 52766 then -- Fallback; shares AntiSpam with START
		if self:AntiSpam(5, "Warp") then
			warningTime:Show()
		end
		timerTimeCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 52772 then
		warningCurse:Show(args.destName)
		timerCurse:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 52772 then
		timerCurse:Cancel(args.destName)
	end
end