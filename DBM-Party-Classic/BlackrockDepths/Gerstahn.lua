local mod	= DBM:NewMod(369, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9018)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 10894 10876 8122 22417"
)

local warnPain			= mod:NewSpellAnnounce(10894, 3, nil, "Healer")
local warnBurn			= mod:NewSpellAnnounce(10876, 3, nil, "Healer")
local warnScream		= mod:NewSpellAnnounce(8122, 3)
local warnShield		= mod:NewSpellAnnounce(22417, 2)

local timerPainCD			= mod:NewCDTimer(7, 10894, nil, "Healer", nil, 3)--Core 4s first, 7s repeat
local timerBurnCD			= mod:NewCDTimer(10, 10876, nil, "Healer", nil, 3)--Core 14s first, 10s repeat
local timerScreamCD		= mod:NewCDTimer(30, 8122, nil, nil, nil, 3)--Core 32s first, 30s repeat
local timerShieldCD		= mod:NewCDTimer(25, 22417, nil, nil, nil, 2)--Core 8s first, 25s repeat

function mod:OnCombatStart(delay)
	timerPainCD:Start(4-delay)--Core 4s first
	timerBurnCD:Start(14-delay)--Core 14s first
	timerScreamCD:Start(32-delay)--Core 32s first
	timerShieldCD:Start(8-delay)--Core 8s first
end

function mod:OnCombatEnd()
	timerPainCD:Cancel()
	timerBurnCD:Cancel()
	timerScreamCD:Cancel()
	timerShieldCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 10894 then -- Shadow Word: Pain (core 7s repeat)
		warnPain:Show()
		timerPainCD:Start()
	elseif args.spellId == 10876 then -- Mana Burn (core 10s repeat)
		warnBurn:Show()
		timerBurnCD:Start()
	elseif args.spellId == 8122 then -- Psychic Scream (core 30s repeat)
		warnScream:Show()
		timerScreamCD:Start()
	elseif args.spellId == 22417 then -- Shadow Shield (core 25s repeat)
		warnShield:Show()
		timerShieldCD:Start()
	end
end
