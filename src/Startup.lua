--
-- Created by IntelliJ IDEA.
-- User: Glenn Drescher aka. @Saneroki
-- Date: 11/08/2016
-- Time: 22:10
--

----------------------------------------------------------------------------------
--  Initialize Main Variables --
----------------------------------------------------------------------------------
SaneTextEditor = SaneTextEditor or {}

SaneTextEditor.addonName = "SaneTextEditor"
SaneTextEditor.addonVersion = 1

local savVar = {
    defaultColors = {
        [1] = "ffffff", -- White
        [2] = "2dc50e", -- Green
        [3] = "3a92ff", -- Blue
        [4] = "a02ef7", -- Purple
        [5] = "eeca2a", -- Yellow
        [6] = "c5c29e"  -- Golden (Default)
    },
    userColors = {
        [1] = "ffffff", -- White
        [2] = "2dc50e", -- Green
        [3] = "3a92ff", -- Blue
        [4] = "a02ef7", -- Purple
        [5] = "eeca2a", -- Yellow
        [6] = "c5c29e"  -- Golden (Default)
    },
    activeFrames = { -- TODO: If I make this possible, then there needs to be fixed:
        -- Frames that are not created have to be empty and prevent creation of Buttons
        [1] = true, -- Motd
        [2] = true, -- AboutUs
        [3] = true, -- Guild Note
        [4] = true  -- Send Mail
    },
    activeColorButtons = 5
}

local Data = {
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
    topLevelName = SaneTextEditor.addonName,
    buttonFrames = {},
    currentColorButton = nil,
    currentFrame = 1,
    lastControl = nil
}
----------------------------------------------------------------------------------
-- Functions of Color Buttons called from XML Template --
----------------------------------------------------------------------------------
function SaneTextEditor.InsertColorToEditbox(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    local editbox = control:GetParent():GetParent()
    editbox:InsertText("|c" .. savVar.userColors[buttonNumber] .. SaneTextEditor.InsertedHelpText .. "|r")
end

function SaneTextEditor.ShowColorPicker(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    local r, g, b, a = ZO_ColorDef:New(savVar.userColors[buttonNumber]):UnpackRGBA()

    COLOR_PICKER:Show(colorSelectedCallback, r, g, b, a)
    COLOR_PICKER:SetColor(r, g, b, a)
    Data.currentColorButton = control
end

function COLOR_PICKER:Confirm()
    ZO_Dialogs_ReleaseDialog("COLOR_PICKER")
    local buttonNumber = tonumber(string.match(Data.currentColorButton:GetName(), '%d+'))
    savVar.userColors[buttonNumber] = ZO_ColorDef:New(COLOR_PICKER:GetColors()):ToHex()
    SaneTextEditor.UpdateColorButton(Data.currentColorButton)
end

function COLOR_PICKER:Cancel()
end

function SaneTextEditor.UpdateColorButton(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    control:GetChild():SetColor(ZO_ColorDef:New(savVar.userColors[buttonNumber]):UnpackRGBA())
end

function SaneTextEditor.ResetDefaultColor(control)
    local buttonNumber = tonumber(string.match(control:GetName(), '%d+'))
    savVar.userColors[buttonNumber] = savVar.defaultColors[buttonNumber]
    SaneTextEditor.UpdateColorButton(control)
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
local function CountAktiveElements(elementTable)
    local i
    for i=0, 4, 1 do
        if elementTable[i] == true then
            i = i+1
        end
    end
    return i
end

local function FillFrameWithRedoButton(frame)
    local name = frame:GetName() .. "RedoButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualRedoButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, Data.lastControl, RIGHT)
    Data.lastControl = control
end

local function FillFrameWithUndoButton(frame)
    local name = frame:GetName() .. "UndoButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualUndoButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, Data.lastControl, RIGHT)
    Data.lastControl = control
end

local function FillFrameWithPictureButton(frame)
    local name = frame:GetName() .. "PictureButton"
    local control = GetWindowManager():CreateControlFromVirtual(
        name, frame, "VirtualPictureButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, Data.lastControl, RIGHT)
    Data.lastControl = control
end

local function FillFrameWithItemButton(frame)
    local name = frame:GetName() .. "ItemButton"
    local control = GetWindowManager():CreateControlFromVirtual(
    name, frame, "VirtualItemButton")
    control:ClearAnchors()
    control:SetAnchor(LEFT, Data.lastControl, RIGHT)
    Data.lastControl = control
end

local function FillFrameWithColorButtons(frame)
    for i=1, savVar.activeColorButtons, 1 do
        local name = frame:GetName() .. "ColorButton" .. tostring(i)
        local control = GetWindowManager():CreateControlFromVirtual(
            name, frame, "VirtualColorButton")
        control:GetChild():SetColor(
            ZO_ColorDef:New(savVar.userColors[i]):UnpackRGBA())
        table.insert(Data[Data.currentFrame].colorButtons, control)
        if i > 1 then
            control:ClearAnchors()
            control:SetAnchor(LEFT, Data.lastControl, RIGHT)
        end
        Data.lastControl = control
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
    local control
    for i=1, amount, 1 do
        control = CreateControl(
            Data[i].name, Data[i].parent, Data[i].point,
            Data[i].relativeTo, Data[i].relativePoint)
        table.insert(Data.buttonFrames, control)
        FillFrameWithColorButtons(control)
        --FillFrameWithItemButton(control)
        --FillFrameWithPictureButton(control)
        --FillFrameWithUndoButton(control)
        --FillFrameWithRedoButton(control)
        Data.currentFrame = Data.currentFrame +1
    end
    Data.currentFrame = 1
end

----------------------------------------------------------------------------------
-- Tooltip Handling --
----------------------------------------------------------------------------------
function SaneTextEditor.ShowTooltipForColorButton(control)
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, SaneTextEditor.ColorButtonTT)
end

function SaneTextEditor.ShowTooltipForItemButton(control)
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    SetTooltipText(InformationTooltip, SaneTextEditor.ItemButtonTT)
end

function SaneTextEditor.HideTooltip()
    ClearTooltip(InformationTooltip)
end
----------------------------------------------------------------------------------
-- Finally Initialize --
----------------------------------------------------------------------------------

-- Loads the AddOn
local function Initialize()
    savedVariables = ZO_SavedVars:NewAccountWide(
        "SavedVariables", SaneTextEditor.addonVersion, nil, savVar)
    CreateMultipleFrames(4)
    --p(Data.currentFrame:GetName())
    -- Unregister Event
    EVENT_MANAGER:UnregisterForEvent(
        SaneTextEditor.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

-- Initializes the addon after it is completly loaded
local function OnAddOnLoaded(event, loadedAddon)
    if loadedAddon ~= SaneTextEditor.addonName then return end
    Initialize()


end

----------------------------------------------------------------------------------
-- Register Events --
----------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(
    SaneTextEditor.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

