local mod = DBM:NewMod(544, "DBM-Party-BC", 10, 253)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20260914132425")

mod:SetCreatureID(18731)

mod:SetModelID(18821)
mod:SetModelScale(0.7)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 33547"
)

local warnFear		= mod:NewSpellAnnounce(33547, 3)

local timerFearMin		= mod:NewNextTimer(23, 33547, nil, nil, nil, 2)--Core 23-33s RNG: earliest recast
local timerFear		= mod:NewNextTimer(33, 33547, nil, nil, nil, 2)--Core 23-33s first and repeat RNG; max bar

local enrageTimer	= mod:NewBerserkTimer(180)

function mod:OnCombatStart(delay)
	if self:IsDifficulty("heroic5", "timewalker") then
		enrageTimer:Start(-delay)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 33547 then
		warnFear:Show()
		timerFearMin:Cancel()
		timerFear:Cancel()
		timerFearMin:Start(23)
		timerFear:Start(33)
	end
end