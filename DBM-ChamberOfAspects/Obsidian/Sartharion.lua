local mod	= DBM:NewMod("Sartharion", "DBM-ChamberOfAspects", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,normal25"

mod:SetRevision("20220705003446")
mod:SetCreatureID(28860)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 56908 58956",
	"SPELL_CAST_SUCCESS 57579 59127",
	"SPELL_AURA_APPLIED 57491",
	"SPELL_DAMAGE 59128",
	"SPELL_SUMMON 57578 57697",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

local warnShadowFissure			= mod:NewSpellAnnounce(59127, 4, nil, nil, nil, nil, nil, 2)
local warnBreathSoon			= mod:NewSoonAnnounce(58956, 2, nil, "Tank|Healer")
local warnTenebron				= mod:NewAnnounce("WarningTenebron", 2, 61248)
local warnShadron				= mod:NewAnnounce("WarningShadron", 2, 58105)
local warnVesperon				= mod:NewAnnounce("WarningVesperon", 2, 61251)
local warnTenebronWhelpsSoon	= mod:NewAnnounce("WarningWhelpsSoon", 1, 1022, false)
local warnShadronPortalSoon		= mod:NewAnnounce("WarningPortalSoon", 1, 11420, false)
local warnVesperonPortalSoon	= mod:NewAnnounce("WarningReflectSoon", 1, 57988, false)
local warnLavaStrike			= mod:NewSpellAnnounce(57578, 3)

local specWarnFireWall			= mod:NewSpecialWarning("WarningFireWall", nil, nil, nil, 2, 2)
local specWarnVesperonPortal	= mod:NewSpecialWarning("WarningVesperonPortal", false, nil, nil, 1, 7)
local specWarnTenebronPortal	= mod:NewSpecialWarning("WarningTenebronPortal", false, nil, nil, 1, 7)
local specWarnShadronPortal		= mod:NewSpecialWarning("WarningShadronPortal", false, nil, nil, 1, 7)

local timerShadowFissure		= mod:NewCastTimer(5, 59128, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON) --Cast timer until Void Blast. it's what happens when shadow fissure explodes.
local timerShadowFissureCD	= mod:NewCDTimer(22.5, 59127, nil, nil, nil, 3)--Core 20s first, 22.5s repeat per drake
local timerBreath				= mod:NewCDTimer(20, 58956, nil, "Tank|Healer", nil, 5)--Core 15s first, 20s repeat
local timerWall					= mod:NewCDTimer(25, 43113, nil, nil, nil, 2)--Core 20s first, 25s repeat
local timerTenebron				= mod:NewTimer(30, "TimerTenebron", 61248, nil, nil, 1)
local timerShadron				= mod:NewTimer(80, "TimerShadron", 58105, nil, nil, 1)
local timerVesperon				= mod:NewTimer(120, "TimerVesperon", 61251, nil, nil, 1)
local timerTenebronWhelps		= mod:NewTimer(60, "TimerTenebronWhelps", 1022)
local timerShadronPortal		= mod:NewTimer(94, "TimerShadronPortal", 11420)
local timerVesperonPortal		= mod:NewTimer(150, "TimerVesperonPortal", 57988)--Core landing ~120s + 30s portal
local berserkTimer				= mod:NewBerserkTimer(900)--Core 15min

mod:AddBoolOption("AnnounceFails", true, "announce")

mod:GroupSpells(59127, 59128)--Shadow fissure with void blast

local lastvoids = {}
local lastfire = {}
local tsort, tinsert, twipe = table.sort, table.insert, table.wipe

local function isunitdebuffed(spellID)
	local name = DBM:GetSpellInfo(spellID)
	if not name then return false end

	for uId in DBM:GetGroupMembers() do
		local debuffname = DBM:UnitDebuff(uId, spellID)
		if debuffname == name then
			return true
		end
	end
	return false
end

local function CheckDrakes(self, delay)
	if not self:IsInCombat() then return end
	if self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(28860, "Sartharion")
	end
	if isunitdebuffed(61248) then	-- Power of Tenebron
		timerTenebron:Start(26 - delay) -- 30
		warnTenebron:Schedule(21 - delay) -- 25
		timerTenebronWhelps:Start(45 - delay)--Landing ~30s + 15s portal
		warnTenebronWhelpsSoon:Schedule(40 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30452, "Tenebron")
		end
	end
	if isunitdebuffed(58105) then	-- Power of Shadron
		timerShadron:Start(74 - delay) -- 75
		warnShadron:Schedule(69 - delay) -- 70
		timerShadronPortal:Start(95 - delay)--Landing ~80s + 15s portal
		warnShadronPortalSoon:Schedule(90 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30451, "Shadron")
		end
	end
	if isunitdebuffed(61251) then	-- Power of Vesperon
		timerVesperon:Start(119 - delay) -- 120
		warnVesperon:Schedule(114 - delay) -- 115
		timerVesperonPortal:Start(150 - delay)--Landing ~120s + 30s portal
		warnVesperonPortalSoon:Schedule(145 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30449, "Vesperon")
		end
	end
end

local sortedFails = {}
local function sortFails1(e1, e2)
	return (lastvoids[e1] or 0) > (lastvoids[e2] or 0)
end
local function sortFails2(e1, e2)
	return (lastfire[e1] or 0) > (lastfire[e2] or 0)
end

function mod:OnCombatStart(delay)
	--Cache spellnames so a solo player check doesn't fail in CheckDrakes in 8.0+
	self:Schedule(5, CheckDrakes, self, delay)
	timerWall:Start(20-delay)--Core 20s first
	warnBreathSoon:Schedule(10-delay)
	timerBreath:Start(15-delay)--Core 15s first
	berserkTimer:Start(-delay)

	twipe(lastvoids)
	twipe(lastfire)
end

function mod:OnCombatEnd()
	self:Unschedule(CheckDrakes)
	timerWall:Cancel()
	timerBreath:Cancel()
	timerShadowFissure:Cancel()
	timerShadowFissureCD:Cancel()
	berserkTimer:Cancel()
	if not self.Options.AnnounceFails then return end
	if DBM:GetRaidRank() < 1 or not self.Options.Announce then return end

	local voids = ""
	for k, _ in pairs(lastvoids) do
		tinsert(sortedFails, k)
	end
	tsort(sortedFails, sortFails1)
	for _, v in ipairs(sortedFails) do
		voids = voids.." "..v.."("..(lastvoids[v] or "")..")"
	end
	SendChatMessage(L.VoidZones:format(voids), "RAID")
	twipe(sortedFails)
	local fire = ""
	for k, _ in pairs(lastfire) do
		tinsert(sortedFails, k)
	end
	tsort(sortedFails, sortFails2)
	for _, v in ipairs(sortedFails) do
		fire = fire.." "..v.."("..(lastfire[v] or "")..")"
	end
	SendChatMessage(L.FireWalls:format(fire), "RAID")
	twipe(sortedFails)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(56908, 58956) then -- Flame breath (core 15s first, 20s repeat)
		warnBreathSoon:Schedule(15)
		timerBreath:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(57579, 59127) then -- Shadow fissure (core 22.5s repeat per drake)
		warnShadowFissure:Show()
		warnShadowFissure:Play("watchstep")
		timerShadowFissure:Start()
		timerShadowFissureCD:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(57578, 57697) then -- Lava Strike (core 5s first)
		warnLavaStrike:Show()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 30452 or cid == 30451 or cid == 30449 then -- Drake died, portals re-arm 30s after summons die
		timerShadronPortal:Start(30)
		timerVesperonPortal:Start(30)
		timerTenebronWhelps:Start(30)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if self.Options.AnnounceFails and self.Options.Announce and args.spellId == 57491 and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(args.destName) ~= "none" and args.destName then
		lastfire[args.destName] = (lastfire[args.destName] or 0) + 1
		SendChatMessage(L.FireWallOn:format(args.destName), "RAID")
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destName, _, spellId)
	if self.Options.AnnounceFails and self.Options.Announce and spellId == 59128 and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(destName) ~= "none" and destName then
		lastvoids[destName] = (lastvoids[destName] or 0) + 1
		SendChatMessage(L.VoidZoneOn:format(destName), "RAID")
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, mob)
	if msg == L.Wall or msg:find(L.Wall) then
		self:SendSync("FireWall")
	elseif msg == L.Portal or msg:find(L.Portal) then
		if mob == L.NameVesperon then
			self:SendSync("VesperonPortal")
		elseif mob == L.NameTenebron then
			self:SendSync("TenebronPortal")
		elseif mob == L.NameShadron then
			self:SendSync("ShadronPortal")
		end
	end
end
mod.CHAT_MSG_MONSTER_EMOTE = mod.CHAT_MSG_RAID_BOSS_EMOTE

function mod:OnSync(event)
	if event == "FireWall" then
		timerWall:Start()
		specWarnFireWall:Show()
		specWarnFireWall:Play("watchwave")
	elseif event == "VesperonPortal" then
		specWarnVesperonPortal:Show()
		specWarnVesperonPortal:Play("newportal")
	elseif event == "TenebronPortal" then
		specWarnTenebronPortal:Show()
		specWarnTenebronPortal:Play("newportal")
	elseif event == "ShadronPortal" then
		specWarnShadronPortal:Show()
		specWarnShadronPortal:Play("newportal")
	end
end