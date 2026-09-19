local mod	= DBM:NewMod(540, "DBM-Party-BC", 11, 251)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914132425")
mod:SetCreatureID(18096)

mod:SetModelID(19135)
mod:SetModelScale(0.15)
mod:SetModelOffset(0, 0, 8)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 31914",
	"SPELL_AURA_APPLIED 33834"
)

local warnSandBreath		= mod:NewSpellAnnounce(31914, 2)

local timerManaDisruption	= mod:NewBuffActiveTimer(15, 33834, nil, nil, nil, 1)

function mod:SPELL_CAST_START(args)
	if args.spellId == 31914 then -- Sand Breath is a cast, not an aura
		warnSandBreath:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 33834 then
		timerManaDisruption:Start()
	end
end