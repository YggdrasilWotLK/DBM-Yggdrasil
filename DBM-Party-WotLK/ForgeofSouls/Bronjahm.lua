local mod	= DBM:NewMod("Bronjahm", "DBM-Party-WotLK", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(36497)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 68872 68950",
	"SPELL_AURA_APPLIED 68839",
	"UNIT_HEALTH boss1"
)

local warnSoulstormSoon		= mod:NewSoonAnnounce(68872, 2)
local warnCorruptSoul		= mod:NewTargetNoFilterAnnounce(68839, 4)
local warnFear				= mod:NewSpellAnnounce(68950, 3)

local specwarnSoulstorm		= mod:NewSpecialWarningSpell(68872, nil, nil, nil, 2, 2)
local specwarnCorruptedSoul	= mod:NewSpecialWarningMoveTo(68839, nil, nil, nil, 1, 7)

local timerSoulstormCast	= mod:NewCastTimer(4, 68872, nil, nil, nil, 2)
local timerCorruptSoulCD	= mod:NewCDRangeTimer(20, 25, 68839, nil, nil, nil, 3)--Core 14-20s first, 20-25s repeat
local timerFearCD				= mod:NewCDRangeTimer(8, 12, 68950, nil, nil, nil, 3)--Core 8-14s post-35%, 8-12s repeat (was untracked)

mod.vb.warned_preStorm = false

function mod:OnCombatStart(delay)
	self.vb.warned_preStorm = false
	timerCorruptSoulCD:StartRange(14-delay, 20-delay)--Core 14-20s first
end

function mod:OnCombatEnd()
	timerCorruptSoulCD:Cancel()
	timerFearCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 68872 then							-- Soulstorm
		specwarnSoulstorm:Show()
		specwarnSoulstorm:Play("aesoon")
		timerSoulstormCast:Start()
		timerFearCD:StartRange(8, 14)--Core 8-14s after 35%
	elseif args.spellId == 68950 then -- Fear phase 2 (was untracked)
		warnFear:Show()
		timerFearCD:StartRange(8, 12)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 68839 then							-- Corrupt Soul (core 20-25s repeat)
		if args:IsPlayer() then
			specwarnCorruptedSoul:Show(DBM_COMMON_L.EDGE)
			specwarnCorruptedSoul:Play("runtoedge")
		else
			warnCorruptSoul:Show(args.destName)
		end
		timerCorruptSoulCD:StartRange(20, 25)
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warned_preStorm and self:GetUnitCreatureId(uId) == 36497 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 then--Core teleports at 35%
		self.vb.warned_preStorm = true
		warnSoulstormSoon:Show()
	end
end