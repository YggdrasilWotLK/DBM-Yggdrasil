local mod	= DBM:NewMod("Amanitar", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic"

mod:SetRevision("20220518110528")
mod:SetCreatureID(30258)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 57055 57094 57088"
)

local warningMini	= mod:NewSpellAnnounce(57055, 3)
local warnBash		= mod:NewSpellAnnounce(57094, 3, nil, "Tank")
local warnVolley	= mod:NewSpellAnnounce(57088, 2, nil, "Healer")

local timerMiniCD	= mod:NewCDTimer(37, 57055, nil, nil, nil, 2)--Core 25-32s first, 30-45s repeat
local timerBashCD		= mod:NewCDTimer(17, 57094, nil, "Tank", nil, 3)--Core 10-14s first, 15-20s repeat
local timerVolleyCD	= mod:NewCDTimer(17, 57088, nil, "Healer", nil, 2)--Core 15-20s first

function mod:OnCombatStart(delay)
	timerMiniCD:Start(28-delay)--Core 25-32s first
	timerBashCD:Start(12-delay)--Core 10-14s first
	timerVolleyCD:Start(17-delay)--Core 15-20s first
end

function mod:OnCombatEnd()
	timerMiniCD:Cancel()
	timerBashCD:Cancel()
	timerVolleyCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 57055 then -- Mini (core 30-45s repeat)
		warningMini:Show()
		timerMiniCD:Start()
	elseif args.spellId == 57094 then -- Bash, tanks care (core 15-20s repeat)
		warnBash:Show()
		timerBashCD:Start()
	elseif args.spellId == 57088 then -- Venom Bolt Volley, healers care
		warnVolley:Show()
		timerVolleyCD:Start()
	end
end