local mod	= DBM:NewMod("Anomalus", "DBM-Party-WotLK", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26763)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 47751",
	"SPELL_SUMMON 47743",
	"UNIT_HEALTH boss1"
)

local warningRiftSoon	= mod:NewSoonAnnounce(47743, 2)
local warningRiftNow	= mod:NewSpellAnnounce(47743, 3)
local warnSpark		= mod:NewSpellAnnounce(47751, 2)

local timerRiftCD		= mod:NewCDTimer(25, 47743, nil, nil, nil, 3)--Core 25s normal, 15s heroic
local timerSparkCD	= mod:NewCDTimer(5, 47751, nil, nil, nil, 3)--Core 5s repeat

local warnedRift		= false

function mod:OnCombatStart(delay)
	warnedRift = false
	if self:IsDifficulty("heroic5") then
		timerRiftCD:Start(15-delay)--Core 15s heroic
	else
		timerRiftCD:Start(25-delay)--Core 25s normal
	end
	timerSparkCD:Start(5-delay)--Core 5s first
end

function mod:OnCombatEnd()
	timerRiftCD:Cancel()
	timerSparkCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 47751 then -- Spark (core 5s repeat, was untracked)
		warnSpark:Show()
		timerSparkCD:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 47743 then
		warningRiftNow:Show()
		if self:IsDifficulty("heroic5") then
			timerRiftCD:Start(15)
		else
			timerRiftCD:Start(25)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitName(uId) == L.name then
		local h = UnitHealth(uId) / UnitHealthMax(uId)
		if h > 0.55 or (h < 0.47 and h > 0.30) then
			warnedRift = false
		end
		if not warnedRift then
			if (h < 0.55 and h > 0.48) then -- Core empowers at 51%
				warningRiftSoon:Show()
				warnedRift = true
			end
		end
	end
end