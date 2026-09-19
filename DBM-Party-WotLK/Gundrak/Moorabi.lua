local mod	= DBM:NewMod("Moorabi", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29305)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55098 55142 55101 55106 55100 55104 55102",
	"UNIT_HEALTH boss1"
)

-- local warnCopies			= mod:NewSpellAnnounce(55101, 4)

local specWarnTransform		= mod:NewSpecialWarningInterruptCount(55098, nil, nil, nil, 1, 2)
local warnTremor			= mod:NewSpellAnnounce(55142, 3)
local warnShout				= mod:NewSpellAnnounce(55106, 2)
local warnStab				= mod:NewSpellAnnounce(55104, 3, nil, "Tank")

local timerTransform		= mod:NewCDTimer(10, 55098, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTremorCD		= mod:NewCDTimer(20, 55142, nil, nil, nil, 3)--Core 13-30s first (was untracked)
local timerShoutCD		= mod:NewCDTimer(17, 55106, nil, nil, nil, 2)--Core 8-38s first (was untracked)
local timerStabCD			= mod:NewCDTimer(20, 55104, nil, "Tank", nil, 3)--Core 20s (was untracked)

mod.vb.lowHealth = false
mod.vb.kickCount = 0

function mod:OnCombatStart(delay)
	self.vb.lowHealth = false
	self.vb.kickCount = 0
	timerTransform:Start(10-delay)--Core 10s
	timerTremorCD:Start(21-delay)--Core 13-30s first (mid)
	timerShoutCD:Start(23-delay)--Core 8-38s first (mid)
	timerStabCD:Start(20-delay)--Core 20s
end

function mod:OnCombatEnd()
	timerTransform:Cancel()
	timerTremorCD:Cancel()
	timerShoutCD:Cancel()
	timerStabCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 55098 then -- Transformation (core flat 10s)
		self.vb.kickCount = self.vb.kickCount + 1
		specWarnTransform:Show(args.sourceName, self.vb.kickCount)
		specWarnTransform:Play("kickcast")
		if self.vb.lowHealth then
			timerTransform:Start(5) --cast every 5 seconds below 50% health (tactic)
		else
			timerTransform:Start() --cast every 10 seconds above 50% health
		end
	elseif args:IsSpellID(55142, 55101) then -- Ground Tremor/Quake (was untracked)
		warnTremor:Show()
		timerTremorCD:Start()
	elseif args:IsSpellID(55106, 55100) then -- Numbing Shout/Roar (was untracked)
		warnShout:Show()
		timerShoutCD:Start()
	elseif args:IsSpellID(55104, 55102) then -- Determined Stab/Gore (was untracked)
		warnStab:Show()
		timerStabCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if self:GetUnitCreatureId(uId) == 29305 then
		if not self.vb.lowHealth and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 then
			self.vb.lowHealth = true
			local remaining = timerTransform:GetRemaining()
			timerTransform:Cancel()
			if remaining > 5 then--Update
				timerTransform:Start(remaining-5)
			end
		end
	end
end