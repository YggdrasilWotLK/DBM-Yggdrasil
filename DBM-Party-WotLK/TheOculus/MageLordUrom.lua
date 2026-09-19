local mod	= DBM:NewMod("MageLordUrom", "DBM-Party-WotLK", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(27655)
mod:SetMinSyncRevision(2824)

mod:RegisterCombat("yell", L.CombatStart)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 51110 59377 51103",
	"SPELL_CAST_SUCCESS 51121 59376",
	"SPELL_AURA_APPLIED 51121 59376"
)

local warningTimeBomb		= mod:NewTargetNoFilterAnnounce(51121, 4)
local warnFrostbomb		= mod:NewSpellAnnounce(51103, 3)

local specWarnExplosion		= mod:NewSpecialWarningMoveTo(51110, nil, nil, nil, 3, 2)

local timerTimeBomb			= mod:NewTargetTimer(6, 51121, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerTimeBombCD		= mod:NewCDRangeTimer(20, 25, 51121, nil, nil, nil, 3)--Core 20-25s repeat
local timerExplosion		= mod:NewCastTimer(9, 51110, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--Core 9s normal, 7s heroic
local timerFrostbombCD	= mod:NewCDRangeTimer(7, 11, 51103, nil, nil, nil, 3)--Core 7-11s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerTimeBombCD:StartRange(20-delay, 25-delay)--Core 20-25s first
	timerFrostbombCD:StartRange(7-delay, 11-delay)--Core 7-11s first
end

function mod:OnCombatEnd()
	timerTimeBombCD:Cancel()
	timerExplosion:Cancel()
	timerFrostbombCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(51110, 59377) then -- Empowered Arcane Explosion (9s N / 7s H)
		specWarnExplosion:Show(DBM_COMMON_L.BREAK_LOS)
		specWarnExplosion:Play("findshelter")
		if self:IsDifficulty("heroic5") then
			timerExplosion:Start(7)
		else
			timerExplosion:Start(9)
		end
	elseif args.spellId == 51103 then -- Frostbomb (core 7-11s repeat, was untracked)
		warnFrostbomb:Show()
		timerFrostbombCD:StartRange(7, 11)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(51121, 59376) then -- Time Bomb (core 20-25s repeat)
		timerTimeBombCD:StartRange(20, 25)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(51121, 59376) then
		warningTimeBomb:Show(args.destName)
		timerTimeBomb:Start(args.destName)
	end
end