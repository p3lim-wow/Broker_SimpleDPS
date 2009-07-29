--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local addon = CreateFrame('Frame')
local broker = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_SimpleDPS', {type = 'data source', text = '0'})

local total, length = 0, 0
local events = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true
}

local function shortVal(value)
	if(value >= 1e3) then
		return string.format('%.1fk', value / 1e3)
	else
		return string.format('%.0f', value)
	end
end

local function onUpdate(self, elapsed)
	length = UnitAffectingCombat('player') and (length or 0) + elapsed
	broker.text = shortVal((total or 0) / (length or 1))
end

function broker:OnClick()
	total, length = 0, 0
	broker.text = '0'
end

function addon:PLAYER_LOGIN()
	self.player, self.pet = UnitGUID('player'), UnitGUID('pet') or '0x0'
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

function addon:PLAYER_REGEN_ENABLED()
	self:SetScript('OnUpdate', nil)
end

function addon:PLAYER_REGEN_DISABLED()
	self:SetScript('OnUpdate', onUpdate)
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(_, event, source, _, _, _, _, _, melee, _, _, spell)
	if(not events[event] or (source ~= self.player and source ~= self.pet)) then return end

	total = total + (event == 'SWING_DAMAGE' and melee or spell)
end

addon:RegisterEvent('PLAYER_LOGIN')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)