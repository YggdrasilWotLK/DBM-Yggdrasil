local mod	= DBM:NewMod("Archavon", "DBM-VoA")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220705003611")
mod:SetCreatureID(31125)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 58663 60880 58960 60894",
	"SPELL_CAST_SUCCESS 58960 60894",
	"SPELL_AURA_APPLIED 58678 58941 58666 60882",
	"SPELL_AURA_APPLIED_DOSE 58666 60882",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--11/19 19:20:12.949  SPELL_AURA_APPLIED,0xF150007995000007,"Archavon the Stone Watcher",0xa48,0xF140544DF3000002,"Teufelssaurier",0x1114,58678,"Rock Shards",0x1,DEBUFF
--11/19 19:20:16.527  SPELL_AURA_REMOVED,0xF150007995000007,"Archavon the Stone Watcher",0xa48,0xF140544DF3000002,"Teufelssaurier",0x1114,58678,"Rock Shards",0x1,DEBUFF

local warnShards			= mod:NewTargetNoFilterAnnounce(58678, 2)
local warnGrab				= mod:NewAnnounce("WarningGrab", 4, 53041)
local warnLeap				= mod:NewSpellAnnounce(58960, 3)--Core casts 58960/60894, not 58963/60895
local warnStomp				= mod:NewSpellAnnounce(60880, 3)
local warnStompSoon			= mod:NewPreWarnAnnounce(60880, 5, 2)
local warnImpale			= mod:NewStackAnnounce(58666, 2, nil, "Tank|Healer")--Core 3s after every Stomp

local timerNextStomp		= mod:NewNextTimer(45, 60880, nil, nil, nil, 2)
local timerLeapCD			= mod:NewCDTimer(30, 58960, nil, nil, nil, 3)--Core 30s repeat
local timerShards			= mod:NewTargetTimer(4, 58678, nil, nil, nil, 3)
local timerShardsCD		= mod:NewCDTimer(15, 58678, nil, nil, nil, 3)--Core 15s repeat
local timerArchavonEnrage	= mod:NewBerserkTimer(300, nil, "ArchavonEnrage")

function mod:OnCombatStart(delay)
	timerArchavonEnrage:Start()
	timerNextStomp:Start(-delay)
	warnStompSoon:Schedule(40-delay)
	timerLeapCD:Start(30-delay)--Core 30s first
	timerShardsCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerNextStomp:Cancel()
	timerLeapCD:Cancel()
	timerShardsCD:Cancel()
	warnStompSoon:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(58663, 60880) then
		warnStomp:Show()
		timerNextStomp:Start()
		warnStompSoon:Schedule(40)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(58960, 60894) then -- Crushing Leap (core IDs)
		warnLeap:Show()
		timerLeapCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(58678, 58941) then
		warnShards:Show(args.destName)
		timerShards:Start(args.destName)
		timerShardsCD:Start()
	elseif args:IsSpellID(58666, 60882) then -- Impale, 3s after every Stomp
		warnImpale:Show(args.destName, args.amount or 1)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
	if msg and msg:match(L.TankSwitch) or msg:find(L.TankSwitch) then
		warnGrab:Show(DBM:GetUnitFullName(target))
	end
end