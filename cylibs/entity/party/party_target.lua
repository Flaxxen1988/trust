local DisposeBag = require('cylibs/events/dispose_bag')
local Event = require('cylibs/events/Luvent')

local PartyTarget = {}
PartyTarget.__index = PartyTarget
PartyTarget.__type = "PartyTarget"
PartyTarget.__class = "PartyTarget"

-- Event called when the party member's target changes.
function PartyTarget:on_target_change()
    return self.target_change
end

function PartyTarget.new(target_tracker, ignore_assist_target)
    local self = setmetatable({}, PartyTarget)

    self.target_tracker = target_tracker
    self.ignore_assist_target = ignore_assist_target
    self.action_events = {}
    self.assist_target_dispose_bag = DisposeBag.new()
    self.dispose_bag = DisposeBag.new()
    self.target_change = Event.newEvent()

    self.action_events.zone_change = windower.register_event('zone change', function(_, _)
        self:set_target_index(nil)
    end)

    return self
end

function PartyTarget:destroy()
    for _, event in pairs(self.action_events) do
        windower.unregister_event(event)
    end

    self:on_target_change():removeAllActions()

    self.dispose_bag:destroy()
end

function PartyTarget:monitor()
    if self.is_monitoring then
        return
    end
    self.is_monitoring = true
end

function PartyTarget:set_assist_target(assist_target)
    self.assist_target_dispose_bag:dispose()

    if assist_target then
        self.assist_target_dispose_bag:add(assist_target:on_target_change():addAction(function(p, new_target_index, old_target_index)
            logger.notice(self.__class, 'set_assist_target', 'on_target_change', p:get_name(), new_target_index)
            if assist_target and assist_target:is_valid() and p:get_name() == assist_target:get_name() then
                logger.notice(self.__class, 'set_assist_target', 'on_party_target_change', p:get_name(), new_target_index)
                if not self:should_ignore_assist_target() then
                    self:set_target_index(new_target_index)
                end
            end
        end), assist_target:on_target_change())
        self:set_target_index(assist_target:get_target_index())
    end
end

function PartyTarget:set_target_index(target_index)
    if self.target_index == target_index then
        return
    end
    self.target_tracker:add_mob_by_index(target_index)
    local old_target_index = self.target_index
    self.target_index = target_index
    self:on_target_change():trigger(self, self.target_index, old_target_index)
end

function PartyTarget:get_target_index()
    return self.target_index
end

function PartyTarget:get_target()
    if self.target_index then
        return self:get_alliance():get_target_by_index(self.target_index)
    end
    return nil
end

function PartyTarget:set_should_ignore_assist_target(ignore_assist_target)
    self.ignore_assist_target = ignore_assist_target
end

function PartyTarget:should_ignore_assist_target()
    return self.ignore_assist_target
end


return PartyTarget