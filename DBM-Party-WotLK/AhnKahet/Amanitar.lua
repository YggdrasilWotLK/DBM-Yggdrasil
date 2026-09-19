local mod	= DBM:NewMod("Amanitar", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic"

mod:SetRevision("20260919205410")
mod:SetCreatureID(30258)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 57055 57094 57088"
)

local warningMini	= mod:NewSpellAnnounce(57055, 3)
local warnBash		= mod:NewSpellAnnounce(57094, 3, nil, "Tank")
local warnVolley	= mod:NewSpellAnnounce(57088, 2, nil, "Healer")

local timerMiniCD	= mod:NewCDRangeTimer(30, 45, 57055, nil, nil, nil, 2)--Core 25-32s first, 30-45s repeat
local timerBashCD		= mod:NewCDRangeTimer(15, 20, 57094, nil, "Tank", nil, 3)--Core 10-14s first, 15-20s repeat
local timerVolleyCD	= mod:NewCDRangeTimer(15, 20, 57088, nil, "Healer", nil, 2)--Core 15-20s first

function mod:OnCombatStart(delay)
	timerMiniCD:StartRange(25-delay, 32-delay)--Core 25-32s first
	timerBashCD:StartRange(10-delay, 14-delay)--Core 10-14s first
	timerVolleyCD:StartRange(15-delay, 20-delay)--Core 15-20s first
end

function mod:OnCombatEnd()
	timerMiniCD:Cancel()
	timerBashCD:Cancel()
	timerVolleyCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 57055 then -- Mini (core 30-45s repeat)
		warningMini:Show()
		timerMiniCD:StartRange(30, 45)
	elseif args.spellId == 57094 then -- Bash, tanks care (core 15-20s repeat)
		warnBash:Show()
		timerBashCD:StartRange(15, 20)
	elseif args.spellId == 57088 then -- Venom Bolt Volley, healers care
		warnVolley:Show()
		timerVolleyCD:StartRange(15, 20)
	end
end