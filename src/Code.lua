--
-- Created by IntelliJ IDEA.
-- User: Glenn Drescher aka. @Saneroki
-- Date: 11/08/2016
-- Time: 22:10
--

----------------------------------------------------------------------------------
--  Initialize Defaults and Variables --
----------------------------------------------------------------------------------
STE = STE or {}
local LAM2 = LibStub("LibAddonMenu-2.0")
local addonName = "SaneTextEditor"
local addonVersion = 1.00

local defaultVar = {
    general = {
      tooltips = true
    },
    defaultColors = {
        [1] = "c5c29e", -- Golden (Default)
        [2] = "2dc50e", -- Green
        [3] = "3a92ff", -- Blue
        [4] = "a02ef7", -- Purple
        [5] = "eeca2a", -- Yellow
        [6] = "ff0000" -- Red
    },
    activeFrames = { -- TODO: If I make this possible, then there needs to be fixed:
        -- Frames that are not created have to be empty and prevent creation of Buttons
        [1] = true, -- Motd
        [2] = true, -- AboutUs
        [3] = true, -- Guild Note
        [4] = true  -- Send Mail
    },
    colorButtons = {
        activeColorButtons = 5,
        insertedHelpTextShort = false
    }
}

local savedVar = {}

local data = {
        [1] = { -- Guild Motd Frame
            name = "MotdFrame",
            parent = ZO_GuildHomeInfoMotDSavingEdit,
            point = RIGHT,
            relativeTo = ZO_GuildHomeInfoMotDSave,
            relativePoint = LEFT,
            colorButtons = {}
        },
        [2] = { -- Guild About Us
            name = "AboutUsFrame",
            parent = ZO_GuildHomeInfoDescriptionSavingEdit,
            point = RIGHT,
            relativeTo = ZO_GuildHomeInfoDescriptionSave,
            relativePoint = LEFT,
            colorButtons = {}
        },
        [3] = { --Guild Note
            name = "NoteFrame",
            parent = ZO_EditNoteDialogNoteEdit,
            point = BOTTOM,
            relativeTo = ZO_EditNoteDialog,
            relativePoint = TOP,
            colorButtons = {}
        },
        [4] = { -- Mail Send
            name = "MailFrame",
            parent = ZO_MailSendBodyField,
            point = LEFT,
            relativeTo = ZO_MailSendToLabel,
            relativePoint = RIGHT,
            colorButtons = {}
        },
        [5] = {

        },

    topLevelName = addonName,
    buttonFrames = {},
    currentColorButton = nil,
    currentFrame = 1,
    lastControl = nil
}

local function SaveVariables()
    savedVar = ZO_SavedVars:NewAccountWide(
        "savedVariableTable", addonVersion, nil, defaultVar)
end
----------------------------------------------------------------------------------
-- Settings Menu --
----------------------------------------------------------------------------------
local function SetActiveColorButtons(value)
    savedVar.colorButtons.activeColorButtons = value
    SaveVariables()
    ReloadUI()
end

local settings = {
    panel = {
        type = "panel",
        name = addonName,
        displayName = "Sane Text Editor",
        author = "Saneroki [EU]",
        version = tostring(addonVersion),
        website = "http://www.esoui.com",
        keywords = "settings",
        registerForRefresh = true,
        registerForDefaults = true,
    },
    options = {
        [1] = {
            type = "header",
            name = STE.HeaderGeneralName,
            width = "full",	--or "half" (optional)
        },
        [2] = {
            type = "checkbox",
            name = STE.CheckboxTooltipsName,
            getFunc = function() return savedVar.general.tooltips end,
            setFunc = function(value) savedVar.general.tooltips = value end,
        },
        [3] = {
            type = "header",
            name = STE.HeaderColorButtonsName,
            width = "full",	--or "half" (optional)
        },
        [4] = {
            type = "checkbox",
            name = STE.CheckboxInsertedHelpTextShortName,
            tooltip = STE.InsertedHelpTextShortTT,
            getFunc = function() return savedVar.colorButtons.insertedHelpTextShort end,
            setFunc = function(value) savedVar.colorButtons.insertedHelpTextShort = value end,
        },
        [5] = {
            type = "slider",
            name = STE.SliderColorButtonsName,
            min = 0,
            max = 6,
            step = 1,
            default = 5,
            warning = STE.WarningReloadUI,
            getFunc = function() return savedVar.colorButtons.activeColorButtons end,
            setFunc = function(value) SetActiveColorButtons(value) end,
        },
    }
}


----------------------------------------------------------------------------------
-- Functions of Color Buttons called from XML Template --
----------------------------------------------------------------------------------
function STE.InsertColorToEditbox(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    local editbox = control:GetParent():GetParent()
    local insertedText

    if savedVar.colorButtons.insertedHelpTextShort == false then
        insertedText = STE.InsertedHelpText
    else
        insertedText = STE.InsertedHelpTextShort
    end

    editbox:InsertText(
        "|c" .. savedVar.userColors[buttonNumber] .. insertedText .. "|r")
end

local function UpdateColorButton(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    control:GetChild():SetColor(ZO_ColorDef:New(
        savedVar.userColors[buttonNumber]):UnpackRGBA())
end

function STE.ShowColorPicker(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    local r, g, b, a = ZO_ColorDef:New(savedVar.userColors[buttonNumber]):UnpackRGBA()

    COLOR_PICKER:Show(colorSelectedCallback, r, g, b, a)
    COLOR_PICKER:SetColor(r, g, b, a)
    data.currentColorButton = control
end

function COLOR_PICKER:Confirm()
    ZO_Dialogs_ReleaseDialog("COLOR_PICKER")
    local buttonNumber = tonumber(string.match(data.currentColorButton:GetName(), '%d+'))
    savedVar.userColors[buttonNumber] = ZO_ColorDef:New(
        COLOR_PICKER:GetColors()):ToHex()
    UpdateColorButton(data.currentColorButton)
end

function COLOR_PICKER:Cancel()
end

function STE.ResetDefaultColor(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    savedVar.userColors[buttonNumber] = savedVar.defaultColors[buttonNumber]
    UpdateColorButton(control)
end


----------------------------------------------------------------------------------
-- Functions of Item Button --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Functions of Picture Button --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Functions of Undo and Redo Buttons --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Functions to build GUI --
----------------------------------------------------------------------------------
local function CreateCharacterCounter(control, i)
    local label = GetWindowManager():CreateControlFromVirtual(
        data[i].name .. "CharCounterLabel",
        control, "VirtualLabel")
        label:SetText("1000")
end

function STE.ButtonSizeUp(control)
    local animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ButtonScale")
    animation:ApplyAllAnimationsToControl(control:GetChild())
    animation:PlayInstantlyToEnd()
end

function STE.ButtonSizeDown(control)
    local animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ButtonScale")
    animation:ApplyAllAnimationsToControl(control:GetChild())
    animation:PlayInstantlyToStart()
end

local function FillFrameWithRedoButton(frame)
    local name = frame:GetName() .. "RedoButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualRedoButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, data.lastControl, RIGHT)
    data.lastControl = control
end

local function FillFrameWithUndoButton(frame)
    local name = frame:GetName() .. "UndoButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualUndoButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, data.lastControl, RIGHT)
    data.lastControl = control
end

local function FillFrameWithPictureButton(frame)
    local name = frame:GetName() .. "PictureButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualPictureButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, data.lastControl, RIGHT)
    data.lastControl = control
end

local function FillFrameWithItemButton(frame)
    local name = frame:GetName() .. "ItemButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualItemButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, data.lastControl, RIGHT)
    data.lastControl = control
end

local function FillFrameWithColorButtons(frame)
    for i=1, savedVar.colorButtons.activeColorButtons, 1 do
        local name = frame:GetName() .. "ColorButton" .. tostring(i)
        local control = GetWindowManager():CreateControlFromVirtual(
            name, frame, "VirtualColorButton")
        control:GetChild():SetColor(
            ZO_ColorDef:New(savedVar.userColors[i]):UnpackRGBA())
        table.insert(data[data.currentFrame].colorButtons, control)
        if i > 1 then
            control:ClearAnchors()
            control:SetAnchor(LEFT, data.lastControl, RIGHT)
        end
        data.lastControl = control
    end
end

local function CreateControl(
controlName, parent, anchorPoint, anchorRelativeTo, anchorRelativePoint )
    local control = GetWindowManager():CreateControlFromVirtual(
        controlName, parent, "VirtualButtonFrame")
    control:ClearAnchors()
    control:SetAnchor(anchorPoint, anchorRelativeTo, anchorRelativePoint)
    return control
end

local function CreateMultipleFrames(amount)
    for i=1, amount, 1 do
        local control = CreateControl(
            data[i].name, data[i].parent, data[i].point,
            data[i].relativeTo, data[i].relativePoint)
        table.insert(data.buttonFrames, control)
        FillFrameWithColorButtons(control)
        FillFrameWithItemButton(control)
        FillFrameWithPictureButton(control)
        FillFrameWithUndoButton(control)
        FillFrameWithRedoButton(control)
        CreateCharacterCounter(control, i)
        data.currentFrame = data.currentFrame +1
    end
    data.currentFrame = 1
end


----------------------------------------------------------------------------------
-- Tooltip Handling --
----------------------------------------------------------------------------------
function STE.ShowTooltipForColorButton(control)
    if savedVar.general.tooltips == false then
    else
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
        SetTooltipText(InformationTooltip, STE.ColorButtonTT)
    end
end

function STE.ShowTooltipForItemButton(control)
    if savedVar.general.tooltips == false then
    else
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, STE.ItemButtonTT)
    end
end

function STE.ShowTooltipForPictureButton(control)
    if savedVar.general.tooltips == false then
    else
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, STE.PictureButtonTT)
    end
end

function STE.ShowTooltipForUndoButton(control)
    if savedVar.general.tooltips == false then
    else
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, STE.UndoButtonTT)
    end
end

function STE.ShowTooltipForRedoButton(control)
    if savedVar.general.tooltips == false then
    else
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, STE.RedoButtonTT)
    end
end

function STE.HideTooltip()
    ClearTooltip(InformationTooltip)
end


----------------------------------------------------------------------------------
-- Initialize --
----------------------------------------------------------------------------------

-- Loads the AddOn
local function Initialize()
    SaveVariables()
    CreateMultipleFrames(4)


    -- Unregister Event
    EVENT_MANAGER:UnregisterForEvent(
        addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

-- Initializes the addon after it is completly loaded
local function OnAddOnLoaded(event, loadedAddon)
    if loadedAddon ~= addonName then return end
    SaveVariables()
    Initialize()
    LAM2:RegisterAddonPanel("Sane Text Editor Options", settings.panel)
    LAM2:RegisterOptionControls("Sane Text Editor Options", settings.options)
end

----------------------------------------------------------------------------------
-- Register Events --
----------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(
    addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


