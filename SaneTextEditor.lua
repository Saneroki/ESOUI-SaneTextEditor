----------------------------------------------------------------------------------
--  Initialize Variables --
----------------------------------------------------------------------------------

--local STE = {}
SaneTextEditor = STE or {}

STE.name = "SaneTextEditor"
STE.version = 1

STE.amountOfColorButtons = 5
STE.defaultColors = {
	"ffffff", -- White
	"2dc50e", -- Green
	"3a92ff", -- Blue
	"a02ef7", -- Purple
	"eeca2a",  -- Yellow
	"c5c29e" -- Golden (Default)
}

local defaultButtonFrames = {
	frameGuildMotd = "MotdButtonFrame",
	frameGuildAboutUs = "AboutUsButtonFrame",
	frameGuildeNote = "NoteButtonFrame",
	frameSendMail = "MailButtonFrame",
	parentGuildMotd = ZO_GuildHomeInfoMotDSavingEdit,
	parentGuildAboutUs = ZO_GuildHomeInfoDescriptionSave,
	parentGuildeNote = ZO_EditNoteDialog,
	parentSendMail = ZO_MailSendToLabel,
	amountOfFrames = 4
}

local buttonFrames = {}
local colorControls = {}
local currentColorButton = nil

----------------------------------------------------------------------------------
-- PictureButton Functions  --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- ItemButton Functions  --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- ColorButton Functions  -- some called from xml template
----------------------------------------------------------------------------------
function STE.InsertColorToEditbox(control)
	local buttonNumber = tonumber(control:GetParent():GetName())
	local editbox = nil
	if control:GetParent():GetParent():GetName() == "MotdButtonFrame" then
		editbox = ZO_GuildHomeInfoMotDSavingEdit
	end
	editbox:InsertText("|c" .. STE.savedVariables[buttonNumber] .. " Doubleclick_here_and_write|r")
end

function STE.ShowColorPicker(control)
	local buttonNumber = tonumber(control:GetParent():GetName())
	local r, g, b, a = ZO_ColorDef:New(STE.savedVariables[buttonNumber]):UnpackRGBA()
	
	COLOR_PICKER:Show(colorSelectedCallback, r, g, b, a)
	COLOR_PICKER:SetColor(r, g, b, a)
	currentColorButton = control
end

function COLOR_PICKER:Confirm()
	ZO_Dialogs_ReleaseDialog("COLOR_PICKER")
	local buttonNumber = tonumber(currentColorButton:GetParent():GetName())
    STE.savedVariables[buttonNumber] = ZO_ColorDef:New(COLOR_PICKER:GetColors()):ToHex()
    STE.UpdateColorButton(currentColorButton)
end

function COLOR_PICKER:Cancel()
end

function STE.UpdateColorButton(control)
	local buttonNumber = tonumber(control:GetParent():GetName())
    colorControls[buttonNumber]:GetChild():GetChild():SetColor(ZO_ColorDef:New(STE.savedVariables[buttonNumber]):UnpackRGBA())
end

function STE.ResetDefaultColor(control)
	local buttonNumber = tonumber(control:GetParent():GetName())
    STE.savedVariables[buttonNumber] = STE.defaultColors[buttonNumber]
    STE.UpdateColorButton(control)
end


----------------------------------------------------------------------------
-- Used to Initialize --
----------------------------------------------------------------------------------
function STE.CreateColorButtons(parent)
	local name = "Color"
	for i=1, STE.amountOfColorButtons, 1 do
    	table.insert(colorControls,  GetWindowManager():CreateControlFromVirtual(i, parent, "VirtualColorButton"))
    	colorControls[i]:GetChild():GetChild():SetColor(ZO_ColorDef:New(STE.savedVariables[i]):UnpackRGBA())
		if i > 1 then
			colorControls[i]:ClearAnchors()
			colorControls[i]:SetAnchor(LEFT, lastControl, RIGHT)
		end
		lastControl = colorControls[i]
	end
end

function STE.CreateButtonFrames()
	for i=1, defaultButtonFrames.amountOfFrames, 1 do
		table.insert(buttonFrames,  GetWindowManager():CreateControlFromVirtual(defaultButtonFrames[i], defaultButtonFrames[i+4], "VirtualButtonFrame"))
		for j=1, STE.amountOfColorButtons, 1 do

			lastControl = colorControls[j]
		end	
	end
end

function STE.ShowTooltip(control)
	local buttonNumber = tonumber(control:GetParent():GetName())
   InitializeTooltip(InformationTooltip, colorControls[buttonNumber], BOTTOM, 0, 0, TOP)
   SetTooltipText(InformationTooltip, "Leftclick = Insert Colorcode to editbox \nRightclick = Change color \nMiddleclick = Reset color to default")
end
 
function STE.HideTooltip(self)
   ClearTooltip(InformationTooltip)
end


----------------------------------------------------------------------------
-- Finally Initialize --
----------------------------------------------------------------------------------


-- Checks if the AddOn is loaded and if not initializes it
function STE.OnAddOnLoaded(event, addonName)
	if addonName ~= STE.name then return end
		STE:Initialize()
end

-- Loads the AddOn
function STE:Initialize()
	STE.savedVariables = ZO_SavedVars:NewAccountWide("STEVars", STE.version, "savedColors", STE.defaultColors)
	STE.CreateButtonFrames()
	--STE.MotdFrame = GetWindowManager():CreateControlFromVirtual("MotdFrame", ZO_GuildHomeInfoMotDSave, "VirtualButtonFrame")
	--STE.CreateColorButtons(STE.MotdFrame)

	-- Unregister Event
	EVENT_MANAGER:UnregisterForEvent(STE.name, EVENT_ADD_ON_LOADED, STE.OnAddOnLoaded)
end


----------------------------------------------------------------------------------
-- Register Events --
----------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(STE.name, EVENT_ADD_ON_LOADED, STE.OnAddOnLoaded)