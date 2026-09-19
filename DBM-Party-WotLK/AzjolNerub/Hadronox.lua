local mod	= DBM:NewMod("Hadronox", "DBM-Party-WotLK", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(28921)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 53030 53418 57731",
	"SPELL_CAST_SUCCESS 53030",
	"SPELL_AURA_APPLIED 53030",
	"SPELL_PERIODIC_DAMAGE 53400 59419",
	"SPELL_PERIODIC_MISSED 53400 59419"
)

local warningLeech	= mod:NewTargetNoFilterAnnounce(53030, 2, nil, "Healer")
local warnPierce	= mod:NewSpellAnnounce(53418, 3, nil, "Tank")
local warnGrab		= mod:NewSpellAnnounce(57731, 3)

local specWarnLeech	= mod:NewSpecialWarningDispel(53030, "RemovePoison", nil, nil, 1, 2)
local specWarnGTFO	= mod:NewSpecialWarningGTFO(53400, nil, nil, nil, 1, 8)

local timerLeechCD	= mod:NewCDTimer(12, 53030, nil, "Healer", nil, 3)--Core 4s first, 12s repeat
local timerPierceCD	= mod:NewCDTimer(8, 53418, nil, "Tank", nil, 3)--Core 1s first, 8s repeat
local timerGrabCD		= mod:NewCDTimer(25, 57731, nil, nil, nil, 3)--Core 15s first, 25s repeat

function mod:OnCombatStart(delay)
	timerLeechCD:Start(4-delay)--Core 4s first
	timerPierceCD:Start(5-delay)--Core 1s first (grace)
	timerGrabCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerLeechCD:Cancel()
	timerPierceCD:Cancel()
	timerGrabCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 53030 then -- Leech Poison (core casts on self, 12s repeat)
		timerLeechCD:Start()
	elseif args.spellId == 53418 then -- Pierce Armor (core 8s repeat, tanks care)
		warnPierce:Show()
		timerPierceCD:Start()
	elseif args.spellId == 57731 then -- Web Grab (core 25s repeat, was untracked)
		warnGrab:Show()
		timerGrabCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 53030 then
		timerLeechCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 53030 then -- Leech Poison on friendly, healers/poison dispellers care
		warningLeech:Show(args.destName)
		if args:IsPlayer() then
			specWarnLeech:Show(args.destName)
			specWarnLeech:Play("helpdispel")
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, destGUID, _, _, spellId, spellName)
	if (spellId == 53400 or spellId == 59419) and destGUID == UnitGUID("player") and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE