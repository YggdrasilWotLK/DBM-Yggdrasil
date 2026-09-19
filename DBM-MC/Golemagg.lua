local mod	= DBM:NewMod("Golemagg", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914171913")
mod:SetCreatureID(11988)--, 11672

mod:SetModelID(11986)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 19798",
	"SPELL_CAST_SUCCESS 20553 19798"
)

--TODO, quake not in combat log on classic?
local warnQuake		= mod:NewSpellAnnounce(20553)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(20553, 19798) then--19798 is the core Quake ID, 20553 kept as fallback
		warnQuake:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 19798 then--Core Quake cast (triggered, SUCCESS may not log)
		warnQuake:Show()
	end
end