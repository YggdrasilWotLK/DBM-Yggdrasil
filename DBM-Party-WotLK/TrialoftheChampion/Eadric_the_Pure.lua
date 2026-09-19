local mod	= DBM:NewMod("EadricthePure", "DBM-Party-WotLK", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(35119)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellCombatEnd)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 66935 66867",
	"SPELL_CAST_SUCCESS 66935",
	"SPELL_AURA_APPLIED 66940 66889 66905"
)

local warnHammerofRighteous		= mod:NewSpellAnnounce(66867, 3)
local warnVengeance				= mod:NewTargetNoFilterAnnounce(66889, 3)

local specwarnRadiance			= mod:NewSpecialWarningLookAway(66935, nil, nil, nil, 2, 2)
local specwarnHammerofJustice	= mod:NewSpecialWarningDispel(66940, "Healer", nil, nil, 1, 2)
local specwarnHammerofRighteous	= mod:NewSpecialWarningYou(66905, nil, nil, nil, 1, 2)

local timerVengeance			= mod:NewBuffActiveTimer(6, 66889)
local timerRadianceCD				= mod:NewCDTimer(16, 66935, nil, nil, nil, 2)--Core 16s repeat
local timerHammerRightCD			= mod:NewCDTimer(25, 66867, nil, nil, nil, 3)--Core 25s paired with HoJ

mod:AddSetIconOption("SetIconOnHammerTarget", 66940, true, true, {8})

function mod:OnCombatStart(delay)
	timerRadianceCD:Start(16-delay)--Core 16s
	timerHammerRightCD:Start(25-delay)--Core 25s
end

function mod:OnCombatEnd()
	timerRadianceCD:Cancel()
	timerHammerRightCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 66935 then					-- Radiance Look Away! (core 16s repeat)
		specwarnRadiance:Show(args.sourceName)
		specwarnRadiance:Play("turnaway")
		timerRadianceCD:Start()
	elseif args.spellId == 66867 then				-- Hammer of the Righteous (core 25s)
		warnHammerofRighteous:Show()
		timerHammerRightCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 66935 then -- Radiance fallback (core casts on nil, START may not log)
		timerRadianceCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 66940 then								-- Hammer of Justice on <Player>
		if self.Options.SetIconOnHammerTarget then
			self:SetIcon(args.destName, 8, 6)
		end
		if self:CheckDispelFilter() then
			specwarnHammerofJustice:Show(args.destName)
			specwarnHammerofJustice:Play("helpdispel")
		end
	elseif args.spellId == 66889 then							-- Vengeance
		warnVengeance:Show(args.destName)
		timerVengeance:Start(args.destName)
	elseif args.spellId == 66905 and args:IsPlayer() then
		specwarnHammerofRighteous:Show()
		specwarnHammerofRighteous:Play("useitem")
	end
end