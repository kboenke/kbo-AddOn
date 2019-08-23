-----------------
-- Configuration Panel
-----------------

-- Static Definitions
kboConfig = {
	VERSION = 2,
}

-- Text Templates
kboConfig.Text = {
	title				= "kbo  Options",
	statsTitle			= "Offsets for /kbo stats",
	statsRatingMin		= "Minimum Rating",
	statsRatingTar		= "Target Rating",
	statsRatingMax		= "Maximum Rating",
	statsCritTitle		= "Spellcrit-Rating",
	statsHasteTitle		= "Spellhaste-Rating",
	greetTitle			= "Settings for Greeting-Module",
	greetGuildToggle	= "Greet Guild",
	greetGuildHello		= "On Join",
	greetGuildWelcome	= "Welcoming",
	greetG6Toggle		= "Greet Gruppe6",
	greetG6Hello		= "On Join",
	greetG6Back			= "When Back",
	debugTitle			= "Debugging Options",
	debugToggle			= "Toggle Debug-Mode",
}

-- Initialization
function kboConfig:Initialize()
	-- Create and register MainPanel
	kboConfig.Panel = CreateFrame("Frame", "kboConfigPanel", UIParent);
	kboConfig.Panel.name = "kbo";

	-- Create Sub-Panel
	kboConfig.TodoPanel = CreateFrame("Frame", "kboConfigTodoPanel", UIParent);
	kboConfig.TodoPanel.name = "Todo Options";
	kboConfig.TodoPanel.parent = kboConfig.Panel.name;

	-- Register Panels
	InterfaceOptions_AddCategory(kboConfig.Panel);
	InterfaceOptions_AddCategory(kboConfig.TodoPanel);

	-- Hook Scripts
	if kbo.Data:IsDebug() then
		kboConfig.Panel.refresh	= function(self) xpcall(function() kboConfig:UpdateOptions(self); end, geterrorhandler()) end
		kboConfig.Panel.okay	= function(self) xpcall(function() kboConfig:SaveOptions(self); end, geterrorhandler()) end
		kboConfig.Panel.cancel	= function(self) xpcall(function() kboConfig:CancelOptions(self); end, geterrorhandler()) end
		kboConfig.Panel.default	= function(self) xpcall(function() kboConfig:ResetOptions(self); end, geterrorhandler()) end
	else
		kboConfig.Panel.refresh	= function(self) kboConfig:UpdateOptions(self); end
		kboConfig.Panel.okay	= function(self) kboConfig:SaveOptions(self); end
		kboConfig.Panel.cancel	= function(self) kboConfig:CancelOptions(self); end
		kboConfig.Panel.default	= function(self) kboConfig:ResetOptions(self); end
	end

	-- Create Content
	kboConfig:CreateOptionsPanel(kboConfig.Panel);
	kboConfig:CreateTodoPanel(kboConfig.TodoPanel);
end


-----------------
-- Create Interface-Options Panels
-----------------

-- Main Panel
function kboConfig:CreateOptionsPanel(parent)
	-- Add Header
	kboConfig:CreatePanelHeader(parent);

	-- Stats Configuration
	parent.pStatTitle = kboConfig:CreateTitle(parent, nil, 10, -60);
	parent.pStatTitle:SetText(kboConfig.Text.statsTitle);
	parent.sStatCritTitle = kboConfig:CreateTitle(parent, "GameFontHighlight");
	parent.sStatCritTitle:SetPoint("BOTTOMLEFT", parent.pStatTitle, 3, -20);
	parent.sStatCritTitle:SetText(kboConfig.Text.statsCritTitle);
	parent.sStatCritMin = kboConfig:CreateSlider("CritMin", parent);
	parent.sStatCritMin:SetPoint("BOTTOMLEFT", parent.sStatCritTitle, 30, -30);
	parent.sStatCritMin.Text:SetText(kboConfig.Text.statsRatingMin);
	parent.sStatCritTar = kboConfig:CreateSlider("CritTar", parent);
	parent.sStatCritTar:SetPoint("BOTTOMLEFT", parent.sStatCritTitle, 233, -30);
	parent.sStatCritTar.Text:SetText(kboConfig.Text.statsRatingTar);
	parent.sStatCritMax = kboConfig:CreateSlider("CritMax", parent);
	parent.sStatCritMax:SetPoint("BOTTOMLEFT", parent.sStatCritTitle, 436, -30);
	parent.sStatCritMax.Text:SetText(kboConfig.Text.statsRatingMax);
	-- Haste-Rating
	parent.sStatHasteTitle = kboConfig:CreateTitle(parent, "GameFontHighlight");
	parent.sStatHasteTitle:SetPoint("BOTTOMLEFT", parent.pStatTitle, 3, -90);
	parent.sStatHasteTitle:SetText(kboConfig.Text.statsHasteTitle);
	parent.sStatHasteMin = kboConfig:CreateSlider("HasteMin", parent);
	parent.sStatHasteMin:SetPoint("BOTTOMLEFT", parent.sStatHasteTitle, 30, -30);
	parent.sStatHasteMin.Text:SetText(kboConfig.Text.statsRatingMin);
	parent.sStatHasteTar = kboConfig:CreateSlider("HasteTar", parent);
	parent.sStatHasteTar:SetPoint("BOTTOMLEFT", parent.sStatHasteTitle, 233, -30);
	parent.sStatHasteTar.Text:SetText(kboConfig.Text.statsRatingTar);
	parent.sStatHasteMax = kboConfig:CreateSlider("HasteGood", parent);
	parent.sStatHasteMax:SetPoint("BOTTOMLEFT", parent.sStatHasteTitle, 436, -30);
	parent.sStatHasteMax.Text:SetText(kboConfig.Text.statsRatingMax);

	-- Greetings
	parent.pGreetTitle = kboConfig:CreateTitle(parent, nil, 10, -228);
	parent.pGreetTitle:SetText(kboConfig.Text.greetTitle);
	-- Guild
	parent.cGreetGuild = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cGreetGuild:SetPoint("TOPLEFT", parent.pGreetTitle, 0, -18);
	parent.cGreetGuild.Text:SetText(kboConfig.Text.greetGuildToggle);
	parent.pGreetGuildHello = kboConfig:CreateTitle(parent, "GameFontHighlight")
	parent.pGreetGuildHello:SetSize(80, 16);
	parent.pGreetGuildHello:SetPoint("TOPLEFT", parent.cGreetGuild, 172, -5);
	parent.pGreetGuildHello:SetJustifyH("RIGHT");
	parent.pGreetGuildHello:SetText(kboConfig.Text.greetGuildHello);
	parent.iGreetGuildHello = kboConfig:CreateEditbox(parent);
	parent.iGreetGuildHello:SetPoint("TOPLEFT", parent.cGreetGuild, 260, -1);
	parent.pGreetGuildWelcome = kboConfig:CreateTitle(parent, "GameFontHighlight");
	parent.pGreetGuildWelcome:SetSize(80, 16);
	parent.pGreetGuildWelcome:SetPoint("TOPLEFT", parent.cGreetGuild, 393, -5);
	parent.pGreetGuildWelcome:SetJustifyH("RIGHT");
	parent.pGreetGuildWelcome:SetText(kboConfig.Text.greetGuildWelcome);
	parent.iGreetGuildWelcome = kboConfig:CreateEditbox(parent);
	parent.iGreetGuildWelcome:SetPoint("TOPLEFT", parent.cGreetGuild, 480, -1);
	-- Gruppe6
	parent.cGreetG6 = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cGreetG6:SetPoint("TOPLEFT", parent.pGreetTitle, 0, -41);
	parent.cGreetG6.Text:SetText(kboConfig.Text.greetG6Toggle);
	parent.pGreetG6Hello = kboConfig:CreateTitle(parent, "GameFontHighlight");
	parent.pGreetG6Hello:SetSize(80, 16);
	parent.pGreetG6Hello:SetPoint("TOPLEFT", parent.cGreetG6, 172, -5);
	parent.pGreetG6Hello:SetJustifyH("RIGHT");
	parent.pGreetG6Hello:SetText(kboConfig.Text.greetG6Hello);
	parent.iGreetG6Hello = kboConfig:CreateEditbox(parent);
	parent.iGreetG6Hello:SetPoint("TOPLEFT", parent.cGreetG6, 260, -1);
	parent.pGreetG6Back = kboConfig:CreateTitle(parent, "GameFontHighlight");
	parent.pGreetG6Back:SetSize(80, 16);
	parent.pGreetG6Back:SetPoint("TOPLEFT", parent.cGreetG6, 393, -5);
	parent.pGreetG6Back:SetJustifyH("RIGHT");
	parent.pGreetG6Back:SetText(kboConfig.Text.greetG6Back);
	parent.iGreetG6Back = kboConfig:CreateEditbox(parent);
	parent.iGreetG6Back:SetPoint("TOPLEFT", parent.cGreetG6, 480, -1);

	-- Debugging Settings
	parent.pDebugTitle = kboConfig:CreateTitle(parent);
	parent.pDebugTitle:SetPoint("BOTTOMLEFT", 10, 35);
	parent.pDebugTitle:SetText(kboConfig.Text.debugTitle);
	parent.cDebug = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cDebug:SetPoint("TOPLEFT", parent.pDebugTitle, 0, -18);
	parent.cDebug.Text:SetText(kboConfig.Text.debugToggle);
	parent.cDebug:SetScript("OnClick", function() kboConfig:ToggleDebugOptions(); end);
	parent.bDebugExport = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
	parent.bDebugExport:SetPoint("TOPLEFT", parent.cDebug, 255, 0);
	parent.bDebugExport:SetSize(100, 24);
	parent.bDebugExport:SetText("Show Data");
	parent.bDebugExport:SetScript("OnClick", function() end);
	parent.bDebugReloadUI = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate");
	parent.bDebugReloadUI:SetPoint("TOPRIGHT", parent.cDebug, 580, 0);
	parent.bDebugReloadUI:SetSize(100, 24);
	parent.bDebugReloadUI:SetText("Reload UI");
	parent.bDebugReloadUI:SetScript("OnClick", function() ReloadUI(); end);
end

-- Create Todo Panel
function kboConfig:CreateTodoPanel(parent)
	-- Add Header
	kboConfig:CreatePanelHeader(parent);
end


-----------------
-- Frame-Event Handling
-----------------

-- Set values according to current Data
function kboConfig:UpdateOptions(parent)
	-- Stats
	local critMin, critTar, critMax = kbo.Data:GetStatsCrit();
	parent.sStatCritMin:SetValue(critMin);
	parent.sStatCritMin.Valuebox:SetCursorPosition(0);
	parent.sStatCritTar:SetValue(critTar);
	parent.sStatCritTar.Valuebox:SetCursorPosition(0);
	parent.sStatCritMax:SetValue(critMax);
	parent.sStatCritMax.Valuebox:SetCursorPosition(0);
	local hasteMin, hasteTar, hasteMax = kbo.Data:GetStatsHaste();
	parent.sStatHasteMin:SetValue(hasteMin);
	parent.sStatHasteMin.Valuebox:SetCursorPosition(0);
	parent.sStatHasteTar:SetValue(hasteTar);
	parent.sStatHasteTar.Valuebox:SetCursorPosition(0);
	parent.sStatHasteMax:SetValue(hasteMax);
	parent.sStatHasteMax.Valuebox:SetCursorPosition(0);
	-- Greetings
	local greetGuildActive, greetGuildHello, greetGuildWelcome = kbo.Data:GetGreetingsGuild();
	parent.cGreetGuild:SetChecked(greetGuildActive);
	parent.iGreetGuildHello:SetText(greetGuildHello);
	parent.iGreetGuildHello:SetCursorPosition(0);
	parent.iGreetGuildWelcome:SetText(greetGuildWelcome);
	parent.iGreetGuildWelcome:SetCursorPosition(0);
	local greetG6Active, greetG6Hello, greetG6Back = kbo.Data:GetGreetingsGruppe6();
	parent.cGreetG6:SetChecked(greetG6Active);
	parent.iGreetG6Hello:SetText(greetG6Hello);
	parent.iGreetG6Hello:SetCursorPosition(0);
	parent.iGreetG6Back:SetText(greetG6Back);
	parent.iGreetG6Back:SetCursorPosition(0);

	-- Debug
	parent.cDebug:SetChecked(kbo.Data:GetDebug());
	kboConfig:ToggleDebugOptions();
end

-- Save Settings (Okay Button pressed)
function kboConfig:SaveOptions(parent)
	-- Stats
	kbo.Data:SetStatsCrit(
		parent.sStatCritMin:GetValue(),
		parent.sStatCritTar:GetValue(),
		parent.sStatCritMax:GetValue()
	);
	kbo.Data:SetStatsHaste(
		parent.sStatHasteMin:GetValue(),
		parent.sStatHasteTar:GetValue(),
		parent.sStatHasteMax:GetValue()
	);
	-- Greetings
	kbo.Data:SetGreetingsGuild(
		parent.cGreetGuild:GetChecked(),
		parent.iGreetGuildHello:GetText(),
		parent.iGreetGuildWelcome:GetText()
	);
	kbo.Data:SetGreetingsGruppe6(
		parent.cGreetG6:GetChecked(),
		parent.iGreetG6Hello:GetText(),
		parent.iGreetG6Back:GetText()
	);
	-- Debug
	kbo.Data:SetDebug(parent.cDebug:GetChecked());
end

-- Reverse Changes (Cancel Button pressed)
function kboConfig:CancelOptions(parent) end

-- Restore Default Settings (Reset Button pressed)
function kboConfig:ResetOptions(parent)
	local DEFAULTS = kbo.Data:GetDefaults();
	parent.sStatCritMin:SetValue(DEFAULTS.statsCritMin);
	parent.sStatCritTar:SetValue(DEFAULTS.statsCritTar);
	parent.sStatCritMax:SetValue(DEFAULTS.statsCritMax);
	parent.sStatHasteMin:SetValue(DEFAULTS.statsHasteMin);
	parent.sStatHasteTar:SetValue(DEFAULTS.statsHasteTar);
	parent.sStatHasteMax:SetValue(DEFAULTS.statsHasteMax);
	parent.cGreetGuild:SetChecked(DEFAULTS.greetGuild);
	parent.iGreetGuildHello:SetText(DEFAULTS.greetGuildHello);
	parent.iGreetGuildWelcome:SetText(DEFAULTS.greetGuildWelcome);
	parent.cGreetG6:SetChecked(DEFAULTS.greetGuild);
	parent.iGreetG6Hello:SetText(DEFAULTS.greetGruppe6Hello);
	parent.iGreetG6Back:SetText(DEFAULTS.greetGruppe6Back);
	parent.cDebug:SetChecked(DEFAULTS.Debug);
	kboConfig:SaveOptions(parent);
end


-----------------
-- Helper Functions
-----------------

-- Title Factory
function kboConfig:CreateTitle(parent, font, x, y)
	title = parent:CreateFontString(nil, "BACKGROUND");
	title:SetSize(300, 16);
	if x ~= nil and y ~= nil then title:SetPoint("TOPLEFT", x, y); end
	title:SetJustifyH("LEFT");
	title:SetFontObject((font ~= nil) and font or "GameFontNormal");
	return title;
end

-- Slider Factory
function kboConfig:CreateSlider(name, parent)
	-- Create Standardized Slider
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate");
	slider:SetWidth(150);
	slider:SetMinMaxValues(0, 100);
	slider:SetValueStep(0.1);
	slider:SetObeyStepOnDrag(true);
	-- Allow direct access to subelements
	slider.TextMin = getglobal(slider:GetName().."Low");
	slider.TextMax = getglobal(slider:GetName().."High");
	slider.Text = getglobal(slider:GetName().."Text");
	local min, max = slider:GetMinMaxValues();
	slider.TextMin:SetText(min.."%");
	slider.TextMax:SetText(max.."%");
	-- Add direct-input GameFontNormal
	slider.Valuebox = kboConfig:CreateEditbox(parent, 35, 12);
	slider.Valuebox:SetPoint("BOTTOM", slider, 0, -12);
	slider.Valuebox:SetMaxLetters(4);
	slider.Valuebox:SetJustifyH("CENTER");
	slider.Valuebox:SetFontObject("GameFontNormalGraySmall");
	-- Dynamic Updates
	slider.Valuebox:SetScript("OnEnterPressed",
		function(self)
			self:ClearFocus();
			self:SetCursorPosition(0);
			local parent = getglobal(self:GetParent());
			parent:SetValue(tonumber(self:GetText()));
		end
	);
	slider:SetScript("OnValueChanged", function(self) self.Valuebox:SetText(self:GetValue()); end);
	-- Return new slider object
	return slider;
end

-- EditBox Factory
function kboConfig:CreateEditbox(parent, width, height)
	local editbox;
	if parent == kboConfig.Panel then
		editbox = CreateFrame("EditBox", nil, kboConfig.Panel, "InputBoxTemplate");
	elseif parent == kboConfig.TodoPanel then
		editbox = CreateFrame("EditBox", nil, kboConfig.TodoPanel, "InputBoxTemplate");
	end
	editbox:SetSize(((width ~= nil) and width or 120), ((height ~= nil) and height or 20));
	editbox:SetAutoFocus(false);
	editbox:SetCursorPosition(0);
	return editbox;
end

-- Add a nifty looking header to a panel
function kboConfig:CreatePanelHeader(parent)
	-- Add Title
	parent.pTitle = kboConfig:CreateTitle(parent, "GameFontNormalLarge", 10, -25);
	parent.pTitle:SetText(kboConfig.Text.title);
	-- Add Logo
	parent.pLogo = parent:CreateTexture(nil, "ARTWORK");
	parent.pLogo:SetTexture("Interface\\AddOns\\kbo\\kbo.blp");
	parent.pLogo:SetPoint("TOPLEFT", 10, -10);
end

-- Show/Hide Debug Options
function kboConfig:ToggleDebugOptions()
	local parent = kboConfig.Panel;

	if (parent.cDebug:GetChecked() == true) then
		parent.bDebugExport:Show();
		parent.bDebugReloadUI:Show();
	else
		parent.bDebugExport:Hide();
		parent.bDebugReloadUI:Hide();
	end

	-- Let's handle this setting in a special way and set it right away...
	kbo.Data:SetDebug(parent.cDebug:GetChecked());
end
