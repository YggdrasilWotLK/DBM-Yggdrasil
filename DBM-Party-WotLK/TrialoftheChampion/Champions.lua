local mod	= DBM:NewMod("GrandChampions", "DBM-Party-WotLK", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(34657, 34701, 34702, 34703, 34705, 35569, 35570, 35571, 35572, 35617)

mod:RegisterCombat("combat")
mod:SetWipeTime(60)--prevent wipe for no vehicle user
mod:SetDetectCombatInVehicle(false)

mod:RegisterKill("yell", L.YellCombatEnd)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 68318 67528",
	"SPELL_CAST_SUCCESS 66045 67528 68318",
	"SPELL_AURA_APPLIED 66043 68311 67534 67701"
)

local warnHealingWave		= mod:NewSpellAnnounce(67528, 2)
local warnPolymorph			= mod:NewTargetAnnounce(66043, 1)

local specWarnPoison		= mod:NewSpecialWarningMove(67701, nil, nil, nil, 1, 8)
local specWarnHaste			= mod:NewSpecialWarningDispel(66045, "MagicDispeller", nil, nil, 1, 2)
local specWarnHex			= mod:NewSpecialWarningDispel(67534, "RemoveCurse", nil, nil, 1, 2)

local timerHealingCD		= mod:NewCDTimer(22, 67528, nil, "Healer", nil, 3)--Core 22s repeat
local timerHasteCD			= mod:NewCDTimer(22, 66045, nil, nil, nil, 3)--Core 22s repeat
local timerPolyCD				= mod:NewCDTimer(8, 66043, nil, nil, nil, 2)--Core 8s repeat
local timerPoisonCD			= mod:NewCDTimer(19, 67701, nil, nil, nil, 3)--Core 19s (correct ID)

function mod:OnCombatStart(delay)
	timerHealingCD:Start(22-delay)
	timerHasteCD:Start(22-delay)
	timerPolyCD:Start(8-delay)
	timerPoisonCD:Start(19-delay)
end

function mod:OnCombatEnd()
	timerHealingCD:Cancel()
	timerHasteCD:Cancel()
	timerPolyCD:Cancel()
	timerPoisonCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(68318, 67528) then								-- Healing Wave (core 22s repeat)
		warnHealingWave:Show()
		timerHealingCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 66045 and not args:IsDestTypePlayer() then		-- Haste (core 22s repeat)
		specWarnHaste:Show(args.destName)
		specWarnHaste:Play("dispelboss")
		timerHasteCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(66043, 68311) then								-- Polymorph on <x> (core 8s repeat)
		warnPolymorph:Show(args.destName)
		timerPolyCD:Start()
	elseif args.spellId == 67534 and self:CheckDispelFilter() then		-- Hex of Mending on <x>
		specWarnHex:Show(args.destName)
		specWarnHex:Play("helpdispel")
	elseif args.spellId == 67701 and args:IsPlayer() then		-- Poison Bottle (core ID, was 67594/68316)
		specWarnPoison:Show()
		specWarnPoison:Play("watchfeet")
		timerPoisonCD:Start()
	end
end