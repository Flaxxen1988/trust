local PickerConfigItem = require('ui/settings/editors/config/PickerConfigItem')

local TrustCommands = require('cylibs/trust/commands/trust_commands')
local PullTrustCommands = setmetatable({}, {__index = TrustCommands })
PullTrustCommands.__index = PullTrustCommands
PullTrustCommands.__class = "PullTrustCommands"

function PullTrustCommands.new(trust, action_queue, puller)
    local self = setmetatable(TrustCommands.new(), PullTrustCommands)

    self.trust = trust
    self.action_queue = action_queue
    self.puller = puller

    -- AutoPullMode
    self:add_command('default', function(_) return self:handle_toggle_mode('AutoPullMode', 'Auto', 'Off')  end, 'Toggle pulling on and off')
    self:add_command('auto', function(_) return self:handle_set_mode('AutoPullMode', 'Auto')  end, 'Automatically pull monsters for the party from the target list')
    self:add_command('aggroed', function(_) return self:handle_set_mode('AutoPullMode', 'Aggroed')  end, 'Automatically pull any monster aggressive to the party')
    self:add_command('all', function(_) return self:handle_set_mode('AutoPullMode', 'All')  end, 'Automatically pull nearby monsters')
    self:add_command('off', function(_) return self:handle_set_mode('AutoPullMode', 'Off')  end, 'Disable pulling')
    self:add_command('camp', self.handle_camp, 'Automatically return to camp after battle')

    self:add_command('action', function(_, _, mode_value)
        return self:handle_set_mode('PullActionMode', mode_value or 'Auto')
    end, 'Action to pull monsters with', L{
        PickerConfigItem.new('mode_value', 'auto', L{ 'auto', 'target', 'approach' }, nil, "Pull Action")
    }, true)

    return self
end

function PullTrustCommands:get_command_name()
    return 'pull'
end

function PullTrustCommands:get_puller()
    return self.puller
end

-- // trust pull camp
function PullTrustCommands:handle_camp(_)
    local success
    local message

    handle_set('AutoCampMode', 'Auto')

    local position = ffxi_util.get_mob_position(windower.ffxi.get_player().name)
    self:get_puller():set_camp_position(V{ position[1], position[2] })

    success = true
    message = "Return to the current position after battle"

    return success, message
end

-- // trust pull [auto, party, all]
function PullTrustCommands:handle_toggle_mode(mode_var_name, on_value, off_value)
    local success = true
    local message

    local mode_var = get_state(mode_var_name)
    if mode_var.value == on_value then
        handle_set(mode_var_name, off_value)
    else
        handle_set(mode_var_name, on_value)
    end

    return success, message
end

return PullTrustCommands