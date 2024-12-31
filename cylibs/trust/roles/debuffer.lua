local ClaimedCondition = require('cylibs/conditions/claimed')
local Gambit = require('cylibs/gambits/gambit')
local GambitTarget = require('cylibs/gambits/gambit_target')
local ImmuneCondition = require('cylibs/conditions/immune')
local spell_util = require('cylibs/util/spell_util')

local Gambiter = require('cylibs/trust/roles/gambiter')
local Debuffer = setmetatable({}, {__index = Gambiter })
Debuffer.__index = Debuffer
Debuffer.__class = "Debuffer"

state.AutoDebuffMode = M{['description'] = 'Debuff Enemies', 'Off', 'Auto'}
state.AutoDebuffMode:set_description('Auto', "Okay, I'll debuff the monster.")

state.AutoSilenceMode = M{['description'] = 'Silence Casters', 'Off', 'Auto'}
state.AutoSilenceMode:set_description('Auto', "Okay, I'll try to silence monsters that cast spells.")

function Debuffer.new(action_queue, debuff_spells)
    local self = setmetatable(Gambiter.new(action_queue, {}, nil, state.AutoDebuffMode, true), Debuffer)

    self:set_debuff_spells(debuff_spells)

    self.last_debuff_time = os.time()

    return self
end

function Debuffer:set_debuff_spells(debuff_spells)
    local debuff_spells = (debuff_spells or L{}):filter(function(spell)
        return spell ~= nil and spell_util.knows_spell(spell:get_spell().id) and spell:get_status() ~= nil
    end)
    local gambit_settings = {
        Gambits = debuff_spells:map(function(spell)
            local conditions = L{
                SpellRecastReadyCondition.new(spell:get_spell().id),
                ClaimedCondition.new(),
                NotCondition.new(L{ HasDebuffCondition.new(spell:get_status().en) }),
                NotCondition.new(L{ ImmuneCondition.new(spell:get_name()) }),
                NumResistsCondition.new(spell:get_name(), Condition.Operator.LessThan, 4),
            }
            return Gambit.new(GambitTarget.TargetType.Enemy, conditions, spell, "Enemy")
        end)
    }
    self:set_gambit_settings(gambit_settings)
end

function Debuffer:allows_duplicates()
    return true
end

function Debuffer:get_type()
    return "debuffer"
end

function Debuffer:tostring()
    local result = ""

    result = result.."Spells:\n"
    if self.debuff_spells:length() > 0 then
        for spell in self.debuff_spells:it() do
            result = result..'• '..spell:description()..'\n'
        end
    else
        result = result..'N/A'..'\n'
    end

    return result
end

return Debuffer