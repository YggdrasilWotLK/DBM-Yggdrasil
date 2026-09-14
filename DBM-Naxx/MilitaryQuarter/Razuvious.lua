local mod	= DBM:NewMod("Razuvious", "DBM-Naxx", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220629223621")
mod:SetCreatureID(16061)

mod:RegisterCombat("combat_yell", L.Yell1, L.Yell2, L.Yell3, L.Yell4)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55543 29107",
	"SPELL_CAST_SUCCESS 55543 29107 29060",
	"SPELL_AURA_APPLIED 605",
	"SPELL_DAMAGE 26613 55550",
	"SPELL_MISSED 26613 55550",
	"UNIT_DIED"
)

local warnShoutNow		= mod:NewSpellAnnounce(29107, 1)
local warnShoutSoon		= mod:NewSoonAnnounce(29107, 3)
local warnUnbalancing		= mod:NewTargetNoFilterAnnounce(26613, 3, nil, "Tank|Healer")
local warnJaggedKnife		= mod:NewTargetNoFilterAnnounce(55550, 2)

local timerShout		= mod:NewNextTimer(15, 29107, nil, nil, nil, 2)--Core 15s first and repeat
local timerUnbalancingCD	= mod:NewCDTimer(20, 26613, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 20s first and repeat
local timerJaggedKnifeCD	= mod:NewCDTimer(10, 55550, nil, nil, nil, 3)--Core 10s first and repeat
local timerTaunt		= mod:NewCDTimer(20, 29060, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Player MC tool, not a boss cast
local timerMindControl	= mod:NewBuffActiveTimer(60, 605, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
	timerShout:Start(15 - delay)--Core 15s first
	warnShoutSoon:Schedule(10 - delay)
	timerUnbalancingCD:Start(20 - delay)--Core 20s first
	timerJaggedKnifeCD:Start(10 - delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerShout:Cancel()
	timerUnbalancingCD:Cancel()
	timerJaggedKnifeCD:Cancel()
	timerMindControl:Cancel()
	warnShoutSoon:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(55543, 29107) then -- Disrupting Shout (SUCCESS fallback shares AntiSpam key below)
		if self:AntiSpam(5, "Shout") then
			warnShoutNow:Show()
			warnShoutSoon:Schedule(10)
		end
		timerShout:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if args:IsSpellID(55543, 29107) then  -- Disrupting Shout fallback
		if self:AntiSpam(5, "Shout") then
			warnShoutNow:Show()
			warnShoutSoon:Schedule(10)
		end
		timerShout:Start()
	elseif spellId == 29060 then -- Taunt (cast by MC'd Understudy, resets boss)
		timerTaunt:Start(20, args.sourceGUID)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destName, _, spellId)
	if spellId == 26613 then -- Unbalancing Strike (core 20s loop, tank swap)
		warnUnbalancing:Show(destName)
		timerUnbalancingCD:Start()
	elseif spellId == 55550 then -- Jagged Knife (core 10s loop)
		warnJaggedKnife:Show(destName)
		timerJaggedKnifeCD:Start()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 605 and args:IsSrcTypePlayer() then -- Mind Control
		timerMindControl:Start(nil, args.sourceName)
	end
end

function mod:UNIT_DIED(args)
	local guid = args.destGUID
	local cid = self:GetCIDFromGUID(guid)
	if cid == 16803 then--Deathknight Understudy
		timerTaunt:Stop(args.destGUID)
	end
end