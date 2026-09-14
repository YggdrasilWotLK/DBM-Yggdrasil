local mod	= DBM:NewMod("VarosCloudstrider", "DBM-Party-WotLK", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(27447)

mod:RegisterCombat("combat")

-- Amplify Magic tracking removed per tactic (not tracked for this group).
mod:RegisterEventsInCombat(
)
