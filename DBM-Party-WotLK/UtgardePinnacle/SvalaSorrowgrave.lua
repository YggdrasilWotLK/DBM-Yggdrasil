local mod	= DBM:NewMod("SvalaSorrowgrave", "DBM-Party-WotLK", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26668)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 48258 48276",
	"SPELL_AURA_APPLIED 48267 48276",
	"SPELL_AURA_REMOVED 48276"
)

local warningSacrifice	= mod:NewTargetNoFilterAnnounce(48267, 4)
local warnFlames		= mod:NewSpellAnnounce(48258, 3)

local timerSacrifice	= mod:NewBuffActiveTimer(25, 48276, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerFlamesCD		= mod:NewCDTimer(10, 48258, nil, nil, nil, 3)--Core 11s first, 8-12s repeat
local timerRoleplay		= mod:NewTimer(72, "timerRoleplay", "Interface\\Icons\\Spell_Holy_BorrowedTime") --roleplay for boss is active (core ~72s chain)

function mod:OnCombatStart(delay)
	timerFlamesCD:Start(11-delay)--Core 11s first
end

function mod:OnCombatEnd()
	timerFlamesCD:Cancel()
	timerSacrifice:Cancel()
	timerRoleplay:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 48258 then -- Call Flames (core 8-12s repeat, was untracked)
		warnFlames:Show()
		timerFlamesCD:Start()
	elseif args.spellId == 48276 then
		timerSacrifice:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 48267 then
		warningSacrifice:Show(args.destName)
	elseif args.spellId == 48276 then
		timerSacrifice:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 48276 then
		timerSacrifice:Stop()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SvalaRoleplayStart or msg:find(L.SvalaRoleplayStart) then
		timerRoleplay:Start()
	end
end