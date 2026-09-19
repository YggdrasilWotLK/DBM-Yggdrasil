local mod	= DBM:NewMod("Zarithrian", "DBM-ChamberOfAspects", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231151")
mod:SetCreatureID(39746)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 74384 74392",
	"SPELL_AURA_APPLIED 74367 10278 642",
	"SPELL_AURA_APPLIED_DOSE 74367",
	"SPELL_SUMMON 74398",
	"SPELL_DAMAGE 74367 74394",
	"SPELL_MISSED 74367",
	"CHAT_MSG_MONSTER_YELL"
)

local warningAdds				= mod:NewAnnounce("WarnAdds", 3, 74398)
local warnCleaveArmor			= mod:NewStackAnnounce(74367, 2, nil, "Tank|Healer")
local warnFearSoon			= mod:NewSoonAnnounce(74384, 2, nil, nil, nil, nil, nil, 2)
local warnBlastNova			= mod:NewSpellAnnounce(74392, 3)
local warnLavaGout			= mod:NewTargetNoFilterAnnounce(74394, 2)

local specWarnFear			= mod:NewSpecialWarningSpell(74384, nil, nil, nil, 2, 2)
local specWarnCleaveArmor		= mod:NewSpecialWarningStack(74367, nil, 2, nil, nil, 1, 6)--ability lasts 30 seconds, has a 15 second cd, so tanks should trade at 2 stacks.
local specWarnLavaGout		= mod:NewSpecialWarningYou(74394, nil, nil, nil, 1, 2)

local timerAddsCD				= mod:NewTimer(40, "TimerAdds", 74398, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerAddsTravel			= mod:NewTimer(10, "AddsArrive") -- Timer to indicate when the summoned adds arive
local timerCleaveArmor		= mod:NewTargetTimer(30, 74367, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCleaveCD			= mod:NewCDTimer(15, 74367, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 9s first, 15s repeat
local timerFearCD				= mod:NewCDTimer(30, 74384, nil, nil, nil, 2)
local timerBlastNovaCD		= mod:NewCDTimer(25, 74392, nil, nil, nil, 3)--Core 20-30s repeat

mod:AddBoolOption("CancelBuff")
local CleaveArmorTargets = {}

function mod:OnCombatStart(delay)
	timerFearCD:Start(14-delay)
	warnFearSoon:ScheduleVoice(11, "fearsoon") -- 3 secs prewarning
	timerAddsCD:Start(18-delay)
	timerCleaveCD:Start(9-delay)--Core 9s first
end

function mod:OnCombatEnd()
	warnFearSoon:Cancel()
	warnFearSoon:CancelVoice()
	timerAddsCD:Cancel()
	timerAddsTravel:Cancel()
	timerCleaveCD:Cancel()
	timerBlastNovaCD:Cancel()
	table.wipe(CleaveArmorTargets)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 74384 then
		specWarnFear:Show()
		warnFearSoon:ScheduleVoice(27, "fearsoon") -- 3 secs prewarning
		timerFearCD:Start()
	elseif args.spellId == 74392 then -- Blast Nova (Flamecaller add)
		warnBlastNova:Show()
		timerBlastNovaCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 74367 then
		if self.Options.CancelBuff and not tContains(CleaveArmorTargets, args.destName) then
			CleaveArmorTargets[#CleaveArmorTargets+1] = args.destName
		end
		local amount = args.amount or 1
		timerCleaveArmor:Start(args.destName)
		if args:IsPlayer() and amount >= 2 then
			specWarnCleaveArmor:Show(amount)
			specWarnCleaveArmor:Play("stackhigh")
		else
			warnCleaveArmor:Show(args.destName, amount)
		end
	elseif (spellId == 10278 or spellId == 642) and self.Options.CancelBuff and self:IsInCombat() and args:IsPlayer() and #CleaveArmorTargets > 0 then
		for i = 1, #CleaveArmorTargets do
			local targetName = CleaveArmorTargets[i]
			if targetName == DBM:GetMyPlayerInfo() then
				CancelUnitBuff("player", GetSpellInfo(10278))		-- Hand of Protection
				CancelUnitBuff("player", GetSpellInfo(642))		-- Divine Shield
				CleaveArmorTargets[i] = nil
			end
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_SUMMON(args)
	if args.spellId == 74398 and self:AntiSpam(5, 1) then -- Stalker summons Flamecaller (covers silent 25m stream too)
		warningAdds:Show()
		timerAddsCD:Start()
		timerAddsTravel:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, destName, _, spellId)
	if spellId == 74367 then -- Cleave Armor (instant, no cast event; core 15s repeat)
		timerCleaveCD:Start()
	elseif spellId == 74394 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then -- Lava Gout
		specWarnLavaGout:Show()
		specWarnLavaGout:Play("watchfeet")
	elseif spellId == 74394 then
		warnLavaGout:Show(destName)
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.SummonMinions or msg:find(L.SummonMinions)) and self:AntiSpam(5, 1) then
		warningAdds:Show()
		timerAddsCD:Start()
		timerAddsTravel:Start() -- Added timer for travel time on summoned adds
	end
end