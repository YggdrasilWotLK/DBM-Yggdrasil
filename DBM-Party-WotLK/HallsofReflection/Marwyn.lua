local mod = DBM:NewMod("Marwyn", "DBM-Party-WotLK", 16)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(38113)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 72362 72360 72368",
	"SPELL_AURA_APPLIED 72362 72436 72363",
	"SPELL_CAST_SUCCESS 72362"
)

local warnWellCorruption		= mod:NewSpellAnnounce(72362, 3)
local warnCorruptedFlesh		= mod:NewSpellAnnounce(72363, 3)
local warnObliterate			= mod:NewSpellAnnounce(72360, 3, nil, "Tank")
local warnSuffering			= mod:NewSpellAnnounce(72368, 4, nil, "Healer")

local specWarnWellCorruption	= mod:NewSpecialWarningMove(72362, nil, nil, nil, 1, 8)
local specWarnSuffering		= mod:NewSpecialWarningDispel(72368, "RemoveMagic", nil, nil, 1, 2)

local timerWellCorruptionCD		= mod:NewCDTimer(13, 72362, nil, nil, nil, 3)
local timerCorruptedFlesh		= mod:NewBuffActiveTimer(8, 72363, nil, nil, nil, 5)
local timerCorruptedFleshCD		= mod:NewCDTimer(20, 72363, nil, nil, nil, 2)
local timerObliterateCD		= mod:NewCDTimer(15, 72360, nil, "Tank", nil, 3)--Core 15s (was untracked)
local timerSufferingCD		= mod:NewCDTimer(15, 72368, nil, "Healer", nil, 3)--Core 15s, 5s first (was untracked)

function mod:OnCombatStart(delay)
	timerWellCorruptionCD:Start(13-delay)--Core 13s
	timerCorruptedFleshCD:Start(20-delay)--Core 20s
	timerObliterateCD:Start(15-delay)--Core 15s
	timerSufferingCD:Start(5-delay)--Core 5s first
end

function mod:OnCombatEnd()
	timerWellCorruptionCD:Cancel()
	timerCorruptedFleshCD:Cancel()
	timerObliterateCD:Cancel()
	timerSufferingCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 72360 then -- Obliterate tank nuke (was untracked)
		warnObliterate:Show()
		timerObliterateCD:Start()
	elseif args.spellId == 72368 then -- Shared Suffering (was untracked)
		warnSuffering:Show()
		specWarnSuffering:Show()
		specWarnSuffering:Play("helpdispel")
		timerSufferingCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 72362 and args:IsPlayer() then
		specWarnWellCorruption:Show()
		specWarnWellCorruption:Play("watchfeet")
	elseif args:IsSpellID(72436, 72363) then -- Corrupted Flesh (72436 kept per tactic)
		if self:AntiSpam(5) then
			warnCorruptedFlesh:Show()
			timerCorruptedFlesh:Start()
			timerCorruptedFleshCD:Start()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 72362 then
		warnWellCorruption:Show()
		timerWellCorruptionCD:Start()
	end
end