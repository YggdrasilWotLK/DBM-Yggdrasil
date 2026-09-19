local mod	= DBM:NewMod("Anub'Rekhan", "DBM-Naxx", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231415")
mod:SetCreatureID(15956)

mod:RegisterCombat("combat_yell", L.Pull1, L.Pull2)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 28785 54021",
	"SPELL_AURA_REMOVED 28785 54021",
	"SPELL_DAMAGE 28783 56090",
	"SPELL_MISSED 28783 56090"
)

local warningLocustSoon		= mod:NewSoonAnnounce(28785, 2)
local warningLocustFaded	= mod:NewFadesAnnounce(28785, 1)
local warnImpale			= mod:NewTargetNoFilterAnnounce(28783, 3)

local specialWarningLocust	= mod:NewSpecialWarningSpell(28785, nil, nil, nil, 2, 2)

local timerLocustIn			= mod:NewCDTimer(90, 28785, nil, nil, nil, 6)--Core 70-120s first, 90s repeat from cast
local timerLocustFade		= mod:NewBuffActiveTimer(23, 28785, nil, nil, nil, 6)
local timerImpaleCD		= mod:NewCDTimer(20, 28783, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 15s first, 20s repeat

mod:AddBoolOption("ArachnophobiaTimer", true, "timer", nil, nil, nil, "at1859")--Sad caveat that 10 and 25 man have own achievements and we have to show only 1 in GUI


function mod:OnCombatStart(delay)
	if self:IsDifficulty("normal25") then
		timerLocustIn:StartRange(70 - delay, 120 - delay)
		warningLocustSoon:Schedule(90 - delay)
	else
		timerLocustIn:StartRange(70 - delay, 120 - delay)
		warningLocustSoon:Schedule(76 - delay)
	end
	timerImpaleCD:Start(15 - delay)--Core 15s first
end

function mod:OnCombatEnd(wipe)
	timerLocustIn:Cancel()
	timerLocustFade:Cancel()
	timerImpaleCD:Cancel()
	warningLocustSoon:Cancel()
	if not wipe and self.Options.ArachnophobiaTimer then
		DBT:CreateBar(1200, L.ArachnophobiaTimer)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(28785, 54021) then  -- Locust Swarm (core repeats 90s from cast)
		specialWarningLocust:Show()
		specialWarningLocust:Play("aesoon")
		timerLocustIn:Start(90)
		warningLocustSoon:Schedule(72)
		if self:IsDifficulty("normal25") then
			timerLocustFade:Start(23)
		else
			timerLocustFade:Start(19)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(28785, 54021)
	and args.auraType == "BUFF" then
		warningLocustFaded:Show()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destName, _, spellId)
	if spellId == 28783 or spellId == 56090 then -- Impale (core 15s first, 20s repeat)
		warnImpale:Show(destName)
		timerImpaleCD:Start()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE