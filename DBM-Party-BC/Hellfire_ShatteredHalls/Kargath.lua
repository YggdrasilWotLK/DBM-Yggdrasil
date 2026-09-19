local mod	= DBM:NewMod(569, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic"

mod:SetRevision("20260914132425")
mod:SetCreatureID(16808)

mod:SetModelID(19799)
mod:SetModelOffset(-0.4, 0.1, -0.4)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"UNIT_SPELLCAST_START"
)

--134170 Some Random Orc Icon. Could not find red fel orc icon. Only green orcs or brown orcs. Brown closer to red than green is.
local warnHeathenGuard			= mod:NewAnnounce("warnHeathen", 2, 134170)
local warnReaverGuard			= mod:NewAnnounce("warnReaver", 2, 134170)
local warnSharpShooterGuard		= mod:NewAnnounce("warnSharpShooter", 2, 134170)

local specWarnBladeDance		= mod:NewSpecialWarningSpell(30739, nil, nil, nil, 2, 2)

local timerHeathenCD			= mod:NewTimer(20.6, "timerHeathen", 134170, nil, nil, 1)--Core 20.6s portal cycle
local timerReaverCD				= mod:NewTimer(20.6, "timerReaver", 134170, nil, nil, 1)
local timerSharpShooterCD		= mod:NewTimer(20.6, "timerSharpShooter", 134170, nil, nil, 1)
local timerBladeDanceMin			= mod:NewCDTimer(32.85, 30739, nil, nil, nil, 2)--Core repeat min 32.85s: earliest recast
local timerBladeDanceCD			= mod:NewCDTimer(41.35, 30739, nil, nil, nil, 2)--Core 30s first, 32.85-41.35s repeat RNG; max bar

mod.vb.addSet = 0
mod.vb.addType = 0

local function Adds(self)
	self.vb.addSet = self.vb.addSet + 1
	self.vb.addType = self.vb.addType + 1
	if self.vb.addType == 1 then--Heathen
		warnHeathenGuard:Show(self.vb.addSet.."-"..self.vb.addType)
		timerReaverCD:Start()
	elseif self.vb.addType == 2 then--Reaver
		warnReaverGuard:Show(self.vb.addSet.."-"..self.vb.addType)
		timerSharpShooterCD:Start()
	elseif self.vb.addType == 3 then--SharpShooter
		warnSharpShooterGuard:Show(self.vb.addSet.."-"..self.vb.addType)
		timerHeathenCD:Start()
		self.vb.addType = 0
	end
	self:Schedule(20.6, Adds, self)
end

function mod:OnCombatStart(delay)
	self.vb.addSet = 0
	self.vb.addType = 0
	timerHeathenCD:Start(20.6-delay)--Core 20.6s first
	self:Schedule(20.6-delay, Adds, self)--When reaches stairs, not when enters/spawns way down hallway.
	timerBladeDanceCD:Start(30-delay)--Core 30s first
end

function mod:OnCombatEnd()
	self:Unschedule(Adds)
	timerHeathenCD:Cancel()
	timerReaverCD:Cancel()
	timerSharpShooterCD:Cancel()
	timerBladeDanceMin:Cancel()
	timerBladeDanceCD:Cancel()
end

--Change to no sync if blizz adds IEEU(boss1)
function mod:UNIT_SPELLCAST_START(_, spellName)
   if spellName == GetSpellInfo(30738) then -- Blade Dance Targeting
		self:SendSync("BladeDance")
	end
end

function mod:OnSync(msg)
	if msg == "BladeDance" and self:AntiSpam(3, 1) then
		specWarnBladeDance:Show()
		timerBladeDanceMin:Cancel()
		timerBladeDanceCD:Cancel()
		timerBladeDanceMin:Start(32.85)
		timerBladeDanceCD:Start(41.35)
		specWarnBladeDance:Play("aesoon")
	end
end