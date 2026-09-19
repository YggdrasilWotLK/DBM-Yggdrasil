local mod	= DBM:NewMod("LeyGuardianEregos", "DBM-Party-WotLK", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(27656)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 50804 51153",
	"SPELL_AURA_APPLIED 51162 51170"
)

local warningShift		= mod:NewSpellAnnounce(51162, 4)
local warningShiftEnd	= mod:NewEndAnnounce(51162, 1)
local warningEnraged	= mod:NewSpellAnnounce(51170, 3)
local warnBarrage		= mod:NewSpellAnnounce(50804, 2)
local warnVolley		= mod:NewSpellAnnounce(51153, 3)

local timerEnraged		= mod:NewBuffActiveTimer(12, 51170, nil, nil, nil, 6)
local timerEnragedCD	= mod:NewCDTimer(35, 51170, nil, nil, nil, 2)--Core 35s first and repeat
local timerShift		= mod:NewBuffActiveTimer(18, 51162, nil, nil, nil, 6)
local timerBarrageCD	= mod:NewCDTimer(2.5, 50804, nil, nil, nil, 3)--Core 0s first, 2.5s repeat
local timerVolleyCD		= mod:NewCDTimer(8, 51153, nil, nil, nil, 3)--Core 5s first, 8s repeat


function mod:OnCombatStart(delay)
	timerEnragedCD:Start(35-delay)--Core 35s first
	timerVolleyCD:Start(5-delay)--Core 5s first
	timerBarrageCD:Start(2-delay)--Core 0s first
end

function mod:OnCombatEnd(wipe)
	timerEnragedCD:Cancel()
	timerVolleyCD:Cancel()
	timerBarrageCD:Cancel()
	warningShiftEnd:Cancel()
	if DBT:GetBar(L.MakeitCountTimer) then
		DBT:CancelBar(L.MakeitCountTimer)--Cancel on wipe too (was kill-only, leaked)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 50804 then -- Arcane Barrage (core 2.5s repeat, was untracked)
		warnBarrage:Show()
		timerBarrageCD:Start()
	elseif args.spellId == 51153 then -- Arcane Volley (core 8s repeat, was untracked)
		warnVolley:Show()
		timerVolleyCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 51162 then
		warningShift:Show()
		warningShiftEnd:Schedule(18)
		timerShift:Start()
	elseif args.spellId == 51170 then
		warningEnraged:Show()
		timerEnraged:Start()
		timerEnragedCD:Start()
	end
end