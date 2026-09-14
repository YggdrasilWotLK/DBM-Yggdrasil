local mod	= DBM:NewMod("Auriaya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")

mod:SetCreatureID(33515)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64678 64389 64386 64688 64422",
	"SPELL_AURA_APPLIED 64396 64455",
	"SPELL_DAMAGE 64459 64675",
	"SPELL_MISSED 64459 64675",
	"UNIT_DIED"
)

local warnSwarm		= mod:NewTargetAnnounce(64396, 2)
local warnFearSoon		= mod:NewSoonAnnounce(64386, 1)
local warnCatDied		= mod:NewAnnounce("WarnCatDied", 3, 64455)
local warnCatDiedOne	= mod:NewAnnounce("WarnCatDiedOne", 3, 64455)

local specWarnFear		= mod:NewSpecialWarningSpell(64386, nil, nil, nil, 2, 2)
local specWarnBlast		= mod:NewSpecialWarningInterrupt(64389, "HasInterrupt", nil, 2, 1, 2)
local specWarnVoid		= mod:NewSpecialWarningMove(64675, nil, nil, nil, 1, 2)
local specWarnSonic		= mod:NewSpecialWarningMoveTo(64688, nil, nil, nil, 2, 2)

local enrageTimer		= mod:NewBerserkTimer(600)
local timerDefender	= mod:NewTimer(25, "timerDefender", 64455, nil, nil, 1)--Core 60s first, 25s respawn
local timerFear			= mod:NewCastTimer(64386, nil, nil, nil, 4)
local timerNextFear	= mod:NewNextTimer(35, 64386, nil, nil, nil, 4)--Core 35s first and repeat
local timerNextSwarm	= mod:NewNextTimer(40, 64396, nil, nil, nil, 1)--Core 70s first, 40s repeat
local timerNextSonic	= mod:NewNextTimer(50, 64688, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--Core 45s first, 50s repeat
local timerSonic		= mod:NewCastTimer(64688, nil, nil, nil, 2)
local timerBlastCD	= mod:NewCDTimer(35, 64389, nil, "HasInterrupt", nil, 5)--Core 36s first, 35s repeat

mod.vb.catLives = 9

function mod:OnCombatStart(delay)
	self.vb.catLives = 9
	enrageTimer:Start(-delay)
	timerNextFear:Start(35-delay)--Core 35s first
	timerNextSonic:Start(45-delay)--Core 45s first
	timerDefender:Start(60-delay)--Core 60s first
	timerBlastCD:Start(36-delay)--Core 36s first
	timerNextSwarm:Start(70-delay)--Core 70s first
end

function mod:OnCombatEnd()
	timerNextFear:Cancel()
	timerNextSonic:Cancel()
	timerNextSwarm:Cancel()
	timerDefender:Cancel()
	timerBlastCD:Cancel()
	warnFearSoon:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64678, 64389) then -- Sentinel Blast (core 35s repeat)
		specWarnBlast:Show(args.sourceName)
		specWarnBlast:Play("kickcast")
		timerBlastCD:Start()
	elseif args.spellId == 64386 then -- Terrifying Screech (core 35s repeat)
		specWarnFear:Show()
		specWarnFear:Play("fearsoon")
		timerFear:Start()
		timerNextFear:Start()
		warnFearSoon:Schedule(30)
	elseif args:IsSpellID(64688, 64422) then --Sonic Screech (core 50s repeat)
		specWarnSonic:Show(TANK)
		specWarnSonic:Play("gathershare")
		timerSonic:Start()
		timerNextSonic:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 64396 then -- Guardian Swarm
		warnSwarm:Show(args.destName)
		timerNextSwarm:Start()
	elseif spellId == 64455 then -- Feral Essence
		DBM.BossHealth:AddBoss(34035, L.Defender:format(9))
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if (spellId == 64459 or spellId == 64675) and destGUID == UnitGUID("player") and self:AntiSpam(3) then -- Feral Defender Void Zone
		specWarnVoid:Show()
		specWarnVoid:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34035 then
		self.vb.catLives = self.vb.catLives - 1
		if self.vb.catLives > 0 then
			if self.vb.catLives == 1 then
				warnCatDiedOne:Show()
				timerDefender:Start(25)--Core 25s respawn
			else
				warnCatDied:Show(self.vb.catLives)
				timerDefender:Start(25)--Core 25s respawn
			end
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
				DBM.BossHealth:AddBoss(34035, L.Defender:format(self.vb.catLives))
			end
		else
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
			end
		end
	end
end