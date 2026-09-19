local mod	= DBM:NewMod("BloodstoneAnnihilator", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29307)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54850 54878 54719 54715 54801 54819",
	"SPELL_PERIODIC_DAMAGE 55627",
	"SPELL_PERIODIC_MISSED 55627"
)

local warningElemental		= mod:NewAnnounce("WarningElemental", 3, 54850)
local warningStone			= mod:NewAnnounce("WarningStone", 3, 54878)
local warnBlow				= mod:NewSpellAnnounce(54719, 3, nil, "Tank")
local warnStrike			= mod:NewSpellAnnounce(54715, 2, nil, "Tank")
local warnSurge				= mod:NewSpellAnnounce(54801, 3)

local specWarnMojo			= mod:NewSpecialWarningMove(55627, nil, nil, nil, 1, 2)

local timerBlowCD				= mod:NewCDTimer(10, 54719, nil, "Tank", nil, 3)--Core 10s (was untracked)
local timerStrikeCD			= mod:NewCDTimer(7, 54715, nil, "Tank", nil, 3)--Core 7s (was untracked)
local timerSurgeCD			= mod:NewCDTimer(15, 54801, nil, nil, nil, 3)--Core 7s first, 15s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerBlowCD:Start(10-delay)--Core 10s
	timerStrikeCD:Start(7-delay)--Core 7s
	timerSurgeCD:Start(7-delay)--Core 7s first
end

function mod:OnCombatEnd()
	timerBlowCD:Cancel()
	timerStrikeCD:Cancel()
	timerSurgeCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54850 then -- Emerge (health-gated <51% and <2%, no CD)
		warningElemental:Show()
	elseif args.spellId == 54878 then -- Merge (health-gated <56%, no CD)
		warningStone:Show()
	elseif args.spellId == 54719 then -- Mighty Blow (core 10s, was untracked)
		warnBlow:Show()
		timerBlowCD:Start()
	elseif args.spellId == 54715 then -- Mortal Strike (core 7s, was untracked)
		warnStrike:Show()
		timerStrikeCD:Start()
	elseif args.spellId == 54801 or args.spellId == 54819 then -- Surge (core 15s repeat, was untracked)
		warnSurge:Show()
		timerSurgeCD:Start()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if spellId == 55627 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) and not self:IsTrivial() then -- Mojo Puddle (core ID, was phantom 59451)
		specWarnMojo:Show()
		specWarnMojo:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE