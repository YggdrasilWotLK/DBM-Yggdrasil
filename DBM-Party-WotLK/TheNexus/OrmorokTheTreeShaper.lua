local mod	= DBM:NewMod("OrmorokTheTreeShaper", "DBM-Party-WotLK", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26794)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 47958 57082 57083 48016",
	"SPELL_CAST_SUCCESS 47958 57082 57083",
	"SPELL_AURA_APPLIED 47981 48017 57086",
	"SPELL_AURA_REMOVED 47981",
	"SPELL_SUMMON 61564"
)

local warningFrenzy			= mod:NewSpellAnnounce(48017, 3, nil, "Tank|Healer", 2)
local warningAdd			= mod:NewSpellAnnounce(61564, 2)
local warnTrample			= mod:NewSpellAnnounce(48016, 3, nil, "Tank")

local specWarnReflection	= mod:NewSpecialWarningReflect(47981, "SpellCaster", nil, nil, 1, 2)
local specWarnSpikes		= mod:NewSpecialWarningDodge(47958, nil, nil, nil, 2, 2)

local timerReflection		= mod:NewBuffActiveTimer(15, 47981, nil, "SpellCaster", 2, 5, nil, DBM_COMMON_L.DEADLY_ICON)
local timerReflectionCD		= mod:NewCDTimer(30, 47981, nil, "SpellCaster", 2, 5, nil, DBM_COMMON_L.DEADLY_ICON)
local timerSpikesCD			= mod:NewCDTimer(20, 47958, nil, nil, nil, 3)--Core 12s first, 20s repeat
local timerTrampleCD		= mod:NewCDTimer(10, 48016, nil, "Tank", nil, 3)--Core 10s first and repeat (was untracked)

function mod:OnCombatStart(delay)
	timerSpikesCD:Start(12-delay)--Core 12s first
	timerReflectionCD:Start(30-delay)--Core 30s first
	timerTrampleCD:Start(10-delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerSpikesCD:Cancel()
	timerReflectionCD:Cancel()
	timerTrampleCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(47958, 57082, 57083) then -- Crystal Spikes (core 47958 + heroic twins as fallback)
		specWarnSpikes:Show()
		specWarnSpikes:Play("watchstep")
		timerSpikesCD:Start()
	elseif args.spellId == 48016 then -- Trample (was untracked)
		warnTrample:Show()
		timerTrampleCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(47958, 57082, 57083) then
		timerSpikesCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 47981 then
		specWarnReflection:Show(args.sourceName)
		specWarnReflection:Play("stopattack")
		timerReflection:Start()
		timerReflectionCD:Start()
	elseif args:IsSpellID(48017, 57086) then -- Frenzy (core 48017 + heroic twin as fallback)
		warningFrenzy:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 47981 then
		timerReflection:Cancel()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 61564 then
		warningAdd:Show()
	end
end