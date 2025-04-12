---------------------------
-- Condition checking whether a given alter ego is in the party.
-- @class module
-- @name HasAlterEgoCondition
local serializer_util = require('cylibs/util/serializer_util')
local TextInputConfigItem = require('ui/settings/editors/config/TextInputConfigItem')
local trusts = require('cylibs/res/trusts')

local Condition = require('cylibs/conditions/condition')
local HasAlterEgoCondition = setmetatable({}, { __index = Condition })
HasAlterEgoCondition.__index = HasAlterEgoCondition
HasAlterEgoCondition.__class = "HasAlterEgoCondition"
HasAlterEgoCondition.__type = "HasAlterEgoCondition"

function HasAlterEgoCondition.new(name)
    local self = setmetatable(Condition.new(), HasAlterEgoCondition)
    self.name = name or "Kupipi"
    return self
end

function HasAlterEgoCondition:is_satisfied(target_index)
    local party = player.party
    if party then
        local sanitized_name = self.name
        if trusts:with('enl', self.name) then
            sanitized_name = trusts:with('enl', self.name).en
        end
        local party_member_names = party:get_party_members():map(function(p) return p:get_name() end)
        return party_member_names:contains(sanitized_name) or party_member_names:contains(self.name)
    end
    return false
end

function HasAlterEgoCondition:get_config_items()
    return L{
        TextInputConfigItem.new('name', self.name, 'Alter Ego Name', function(_) return true  end)
    }
end

function HasAlterEgoCondition:tostring()
    return "Has "..self.name.." in party"
end

function HasAlterEgoCondition.description()
    return "Alter ego in party."
end

function HasAlterEgoCondition.valid_targets()
    return S{ Condition.TargetType.Self }
end

function HasAlterEgoCondition:serialize()
    return "HasAlterEgoCondition.new(" .. serializer_util.serialize_args(self.name) .. ")"
end

return HasAlterEgoCondition



