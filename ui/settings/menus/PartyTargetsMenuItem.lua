local ButtonItem = require('cylibs/ui/collection_view/items/button_item')
local DisposeBag = require('cylibs/events/dispose_bag')
local FFXIClassicStyle = require('ui/themes/FFXI/FFXIClassicStyle')
local FFXIPickerView = require('ui/themes/ffxi/FFXIPickerView')
local MenuItem = require('cylibs/ui/menu/menu_item')
local MultiPickerConfigItem = require('ui/settings/editors/config/MultiPickerConfigItem')
local SwitchTargetAction = require('cylibs/actions/switch_target')
local TargetInfoView = require('cylibs/battle/monsters/ui/target_info_view')

local PartyTargetsMenuItem = setmetatable({}, {__index = MenuItem })
PartyTargetsMenuItem.__index = PartyTargetsMenuItem

function PartyTargetsMenuItem.new(party)
    local self = setmetatable(MenuItem.new(L{
        ButtonItem.default('Info', 18),
    }, {}, nil, "Targets", "View info on enemies the party is fighting."), PartyTargetsMenuItem)

    self.target_tracker = party.target_tracker
    self.disposeBag = DisposeBag.new()

    self.contentViewConstructor = function(_, infoView)
        self.targets = party.target_tracker:get_targets()

        local targetNames = party.target_tracker:get_targets():map(function(target) return target:get_name() end)
        local selectedTargetNames = L{}
        if targetNames:length() > 0 then
            selectedTargetNames:append(targetNames[1])
            self.selectedTargetIndex = 1
        end

        local configItem = MultiPickerConfigItem.new("Targets", selectedTargetNames, targetNames, function(targetName)
            return targetName
        end)

        local targetsView = FFXIPickerView.new(L{ configItem }, false, FFXIClassicStyle.WindowSize.Editor.ConfigEditor)
        targetsView:setAllowsCursorSelection(true)

        self.disposeBag:add(targetsView:getDelegate():didMoveCursorToItemAtIndexPath():addAction(function(indexPath)
            self.selectedTargetIndex = indexPath.row

            local selectedTarget = self.targets[self.selectedTargetIndex]
            if selectedTarget then
                infoView:setDescription(selectedTarget:description())
            else
                infoView:setDescription("View info on enemies the party is targeting.")
            end
        end), targetsView:getDelegate():didMoveCursorToItemAtIndexPath())

        return targetsView
    end

    self:reloadSettings()

    return self
end

function PartyTargetsMenuItem:destroy()
    MenuItem.destroy(self)

    self.disposeBag:destroy()
end

function PartyTargetsMenuItem:reloadSettings()
    self:setChildMenuItem("Info", self:getTargetInfoMenuItem())
    self:setChildMenuItem("Target", MenuItem.action(function()
        local switchTarget = SwitchTargetAction.new(self.targets[self.selectedTargetIndex]:get_mob().index, 3)
        action_queue:push_action(switchTarget, true)
    end, "Target", "Switch targets to the selected mob."))
end

function PartyTargetsMenuItem:getTargetInfoMenuItem()
    local targetInfoMenuItem = MenuItem.new(L{
        ButtonItem.default('Info', 18),
        ButtonItem.default('Target', 18),
    }, {},
            function(args)
                local target = self.targets[self.selectedTargetIndex]
                if target then
                    local targetInfoView = TargetInfoView.new(target)
                    targetInfoView:setShouldRequestFocus(true)
                    return targetInfoView
                end
                return nil
            end, "Targets", "View info on the selected target.", false, function()
                return self.selectedTargetIndex and self.targets[self.selectedTargetIndex]
            end)
    return targetInfoMenuItem
end

return PartyTargetsMenuItem