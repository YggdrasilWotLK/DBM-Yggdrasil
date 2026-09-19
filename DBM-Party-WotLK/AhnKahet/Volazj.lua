local mod	= DBM:NewMod("Volazj", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29311)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START 60848 57941 57949"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 60848 57941 57949",
	"SPELL_AURA_APPLIED 57949",
	"UNIT_SPELLCAST_START boss1"
)

local warnShadowCrash			= mod:NewTargetAnnounce(60848, 4)
local warnFlay					= mod:NewTargetNoFilterAnnounce(57941, 3, nil, "Tank")
local warnShiver				= mod:NewSpellAnnounce(57949, 3)
local warningInsanity			= mod:NewCastAnnounce(57496, 3)--Not currently working, no CLEU for it

local specWarnShadowCrash		= mod:NewSpecialWarningDodge(60848, nil, nil, nil, 1, 2)
local specWarnShadowCrashNear	= mod:NewSpecialWarningClose(60848, nil, nil, nil, 1, 2)
local specWarnShiver			= mod:NewSpecialWarningDispel(57949, "RemoveCurse", nil, nil, 1, 2)
local specWarnFlay				= mod:NewSpecialWarningYou(57941, nil, nil, nil, 1, 2)
local yellShadowCrash			= mod:NewYell(60848)

local timerFlayCD			= mod:NewCDTimer(20, 57941, nil, "Tank", nil, 3)--Core 8s first, 20s repeat
local timerShiverCD		= mod:NewCDTimer(15, 57949, nil, nil, nil, 3)--Core 15s first and repeat

local timerInsanity				= mod:NewCastTimer(5, 57496, nil, nil, nil, 6)
local timerAchieve				= mod:NewAchievementTimer(120, 1862)

function mod:OnCombatStart(delay)
	if not self:IsDifficulty("normal5") then
		timerAchieve:Start(-delay)
	end
	timerFlayCD:Start(8-delay)--Core 8s first
	timerShiverCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerFlayCD:Cancel()
	timerShiverCD:Cancel()
end

function mod:ShadowCrashTarget(targetname)
	if not targetname then
		if DBM.Options.DebugMode then
			warnShadowCrash:Show(DBM_COMMON_L.UNKNOWN)
		end
		return
	end
	if self:AntiSpam(2, targetname) then--In case more than 1 pulled and target same person, avoid double/tripple warn
		if targetname == UnitName("player") then
			specWarnShadowCrash:Show()
			specWarnShadowCrash:Play("watchstep")
			yellShadowCrash:Yell()
		elseif self:CheckNearby(5, targetname) then
			specWarnShadowCrashNear:Show(targetname)
			specWarnShadowCrashNear:Play("watchstep")
		else
			warnShadowCrash:Show(targetname)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 60848 then -- Shadow Crash (restored per tactic)
		self:BossTargetScanner(args.sourceGUID, "ShadowCrashTarget", 0.1, 12, nil, nil, nil, nil, true)
	elseif args.spellId == 57941 then -- Mind Flay (warn target only)
		self:BossTargetScanner(args.sourceGUID, "FlayTarget", 0.1, 12)
		timerFlayCD:Start()
	elseif args.spellId == 57949 then -- Shiver
		warnShiver:Show()
		timerShiverCD:Start()
	end
end

function mod:FlayTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFlay:Show()
		specWarnFlay:Play("targetyou")
	else
		warnFlay:Show(targetname)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 57949 then -- Shiver on friendly, curse dispellers care
		specWarnShiver:Show(args.destName)
		specWarnShiver:Play("helpdispel")
	end
end

function mod:UNIT_SPELLCAST_START(_, spellName)
	if spellName == GetSpellInfo(57496) then -- Insanity
		warningInsanity:Show()
		timerInsanity:Start()
	end
end