---------------------------
-- Action representing running away from a target.
-- @class module
-- @name RunAway

local serializer_util = require('cylibs/util/serializer_util')

local RunAway = {}
RunAway.__index = RunAway
RunAway.__type = "RunAway"
RunAway.__class = "RunAway"

-------
-- Default initializer for a new run away.
-- @treturn RunAway A run away.
function RunAway.new(distance, conditions)
    local self = setmetatable({}, RunAway)
    self.distance = distance or 12
    self.conditions = conditions or L{}
    return self
end

function RunAway:destroy()
end

-------
-- Adds a condition to the list of conditions.
-- @tparam Condition condition Condition to add
function RunAway:add_condition(condition)
    if not self:get_conditions():contains(condition) then
        self.conditions:append(condition)
    end
end

-------
-- Returns the list of conditions for turning around.
-- @treturn list List of conditions
function RunAway:get_conditions()
    return self.conditions
end

-------
-- Returns the maximum range in yalms.
-- @treturn number Range in yalms
function RunAway:get_range()
    return 999
end

-------
-- Returns the distance to run to in yalms.
-- @treturn number Distance in yalms
function RunAway:get_distance()
    return self.distance
end

-------
-- Returns the name for the action.
-- @treturn string Action name
function RunAway:get_name()
    return 'Run Away'
end

-------
-- Returns the localized name for the action.
-- @treturn string Localized name
function RunAway:get_localized_name()
    return 'Run Away'
end

-------
-- Returns the display name.
-- @treturn string Display name
function RunAway:get_display_name()
    return string.format("Run %d yalms from target", self.distance)
end

-------
-- Returns the config items that will be used when creating the config editor
-- to edit this ability.
-- @treturn list List of ConfigItem
function RunAway:get_config_items()
    return L{
        ConfigItem.new('distance', 3, 30, 1, function(value) return value.." yalms" end, "Distance from Target"),
    }
end

-------
-- Return the Action to use this action on a target.
-- @treturn Action Action to use ability
function RunAway:to_action(target_index, _)
    return SequenceAction.new(L{
        RunAwayAction.new(target_index, self.distance),
    }, self.__class..'_run_away')
end

function RunAway:serialize()
    local conditions_classes_to_serialize = Condition.defaultSerializableConditionClasses()
    local conditions_to_serialize = self.conditions:filter(function(condition)
        return conditions_classes_to_serialize:contains(condition.__class)
    end)
    return "RunAway.new(" .. serializer_util.serialize_args(self.distance, conditions_to_serialize) .. ")"
end

function RunAway:copy()
    local conditions = L{}
    for condition in self:get_conditions():it() do
        conditions:append(condition:copy())
    end
    return RunAway.new(self.distance, conditions)
end

function RunAway:__eq(otherItem)
    if otherItem.__type == self.__type and otherItem:get_name() == self:get_name()
            and otherItem:get_distance() == self:get_distance() then
        return true
    end
    return false
end

function RunAway:is_valid()
    return true
end

return RunAway