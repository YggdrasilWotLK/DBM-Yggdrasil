local mod	= DBM:NewMod("Gluth", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220221015714")
mod:SetCreatureID(15932)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 28374 54426",
	"SPELL_AURA_APPLIED 28371 54427 25646",
	"SPELL_AURA_REMOVED 28371 54427 25646",
	"SPELL_AURA_APPLIED_DOSE 25646"
)

local warnEnrage		= mod:NewTargetNoFilterAnnounce(19451, 3, nil , "Healer|Tank|RemoveEnrage", 2)
local warnDecimateSoon	= mod:NewSoonAnnounce(28374, 2)
local warnDecimateNow	= mod:NewSpellAnnounce(28374, 3)
local warnMortalWound	= mod:NewStackAnnounce(25646, 2, nil, "Tank|Healer")

local specWarnEnrage	= mod:NewSpecialWarningDispel(19451, "RemoveEnrage", nil, nil, 1, 6)
local specWarnMortalWound	= mod:NewSpecialWarningStack(25646, nil, 3, nil, nil, 1, 6)

local timerEnrage		= mod:NewBuffActiveTimer(8, 19451, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerEnrageCD		= mod:NewCDTimer(22, 28371, nil, "Healer|Tank|RemoveEnrage", nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)--Core 22s first and repeat
local timerDecimate		= mod:NewCDTimer(104, 28374, nil, nil, nil, 2)--Set per-mode on pull: 110s 10m / 90s 25m
local timerMortalWoundCD	= mod:NewCDTimer(10, 25646, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 10s first and repeat
local enrageTimer		= mod:NewBerserkTimer(360)--Core 6min

function mod:OnCombatStart(delay)
	enrageTimer:Start(-delay)
	timerEnrageCD:Start(22 - delay)--Core 22s first
	timerMortalWoundCD:Start(10 - delay)--Core 10s first
	if self:IsDifficulty("normal25", "heroic25") then
		timerDecimate:Start(90 - delay)--Core 90s on 25m
		warnDecimateSoon:Schedule(80 - delay)
	else
		timerDecimate:Start(110 - delay)--Core 110s on 10m
		warnDecimateSoon:Schedule(100 - delay)
	end
end

function mod:OnCombatEnd()
	timerDecimate:Cancel()
	timerEnrageCD:Cancel()
	timerMortalWoundCD:Cancel()
	warnDecimateSoon:Cancel()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(28374, 54426) then -- Decimate (core 110s 10m / 90s 25m)
		warnDecimateNow:Show()
		if self:IsDifficulty("normal25", "heroic25") then
			timerDecimate:Start(90)
			warnDecimateSoon:Schedule(80)
		else
			timerDecimate:Start(110)
			warnDecimateSoon:Schedule(100)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(28371, 54427) then -- Enrage (core 22s loop)
		if self.Options.SpecWarn19451dispel then
			specWarnEnrage:Show(args.destName)
			specWarnEnrage:Play("enrage")
		else
			warnEnrage:Show(args.destName)
		end
		timerEnrage:Start()
		timerEnrageCD:Start()
	elseif args.spellId == 25646 then -- Mortal Wound (core 10s loop)
		local amount = args.amount or 1
		if args:IsPlayer() and amount >= 3 then
			specWarnMortalWound:Show(amount)
			specWarnMortalWound:Play("stackhigh")
		else
			warnMortalWound:Show(args.destName, amount)
		end
		timerMortalWoundCD:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(28371, 54427) then
		timerEnrage:Stop()
	end
end