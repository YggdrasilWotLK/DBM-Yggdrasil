local mod	= DBM:NewMod("GortokPalehoof", "DBM-Party-WotLK", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26687)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 48256 48260",
	"SPELL_AURA_APPLIED 48261 59268"
)

local warningImpale		= mod:NewTargetNoFilterAnnounce(48261, 2, nil, "Healer")
local warnRoar			= mod:NewSpellAnnounce(48256, 3)
local warnSmash			= mod:NewSpellAnnounce(48260, 2, nil, "Tank")

local timerImpale		= mod:NewTargetTimer(9, 48261, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerImpaleCD		= mod:NewCDTimer(10, 48261, nil, "Healer", 2, 5)--Core 12s first, 8-12s repeat
local timerRoarCD			= mod:NewCDTimer(10, 48256, nil, nil, nil, 3)--Core 10s first, 8-12s repeat
local timerSmashCD		= mod:NewCDTimer(15, 48260, nil, "Tank", nil, 3)--Core 15s first, 13-17s repeat

function mod:OnCombatStart(delay)
	timerImpaleCD:Start(12-delay)--Core 12s first
	timerRoarCD:Start(10-delay)--Core 10s first
	timerSmashCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerImpaleCD:Cancel()
	timerRoarCD:Cancel()
	timerSmashCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 48256 then -- Withering Roar (core 8-12s repeat)
		warnRoar:Show()
		timerRoarCD:Start()
	elseif args.spellId == 48260 then -- Arcing Smash (core 13-17s repeat)
		warnSmash:Show()
		timerSmashCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(48261, 59268) then -- Impale (core 8-12s repeat)
		warningImpale:Show(args.destName)
		timerImpale:Start(args.destName)
		timerImpaleCD:Start()
	end
end