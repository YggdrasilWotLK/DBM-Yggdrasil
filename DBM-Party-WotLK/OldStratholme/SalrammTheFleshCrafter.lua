local mod	= DBM:NewMod("SalrammTheFleshcrafter", "DBM-Party-WotLK", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26530)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52480 58825 52708",
	"SPELL_AURA_APPLIED 58845 52709 52711 52712",
	"SPELL_AURA_REMOVED 58845",
	"SPELL_SUMMON 52451"
)

local warningCurse	= mod:NewTargetNoFilterAnnounce(58845, 2, nil, "RemoveCurse", 2)
local warningSteal	= mod:NewTargetNoFilterAnnounce(52709, 2)
local warningGhoul	= mod:NewSpellAnnounce(52451, 3)
local warnExplode		= mod:NewSpellAnnounce(52480, 3)

local timerGhoulCD	= mod:NewCDTimer(10, 52451, nil, nil, nil, 1)--Core 16s first, 10s repeat
local timerCurse	= mod:NewTargetTimer(30, 58845, nil, "RemoveCurse", nil, 5, nil, DBM_COMMON_L.CURSE_ICON)
local timerExplodeCD	= mod:NewCDTimer(15, 52480, nil, nil, nil, 3)--Core every 15s (was untracked)
local timerFleshCD	= mod:NewCDTimer(12, 52708, nil, nil, nil, 3)--Core channel 52708 every 12s

function mod:OnCombatStart(delay)
	timerGhoulCD:Start(16-delay)--Core 16s first
	timerExplodeCD:Start(15-delay)--Core every 15s
	timerFleshCD:Start(12-delay)--Core every 12s
end

function mod:OnCombatEnd()
	timerGhoulCD:Cancel()
	timerExplodeCD:Cancel()
	timerFleshCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52480, 58825) then -- Explode Ghoul (was untracked)
		warnExplode:Show()
		timerExplodeCD:Start()
	elseif args.spellId == 52708 then -- Steal Flesh channel (auras 52709/52711/52712)
		timerFleshCD:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 52451 then
		warningGhoul:Show()
		timerGhoulCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 58845 then
		warningCurse:Show(args.destName)
		timerCurse:Start(args.destName)
	elseif args:IsSpellID(52709, 52711, 52712) then -- Steal Flesh auras (52709 restored per tactic)
		warningSteal:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 58845 then
		timerCurse:Cancel(args.destName)
	end
end