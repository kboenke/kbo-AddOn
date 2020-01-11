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
	equipTitle			= "Stats to be checked by /kbo equip",
	equipInt			= "Intelligence",
	equipCrit			= "Spellcrit",
	equipHaste			= "Spellhaste",
	greetTitle			= "Settings for Greeting-Module",
	greetGuildToggle	= "Greet Guild",
	greetGuildHello		= "On Join",
	greetGuildWelcome	= "Welcoming",
	greetG6Toggle		= "Greet Gruppe6",
	greetG6Hello		= "On Join",
	greetG6Back			= "When Back",
	debugTitle			= "Debugging Options",
	debugToggle			= "Toggle Debug-Mode",
	todoTitle			= "kbo  Tracked Chores",
	todoMainTitle		= "Main",
	todoQuestsTitle		= "Quests",
	todoAchievementsTitle = "Achievements",
	todoInstancesTitle	= "Instances",
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
		kboConfig.TodoPanel.refresh	= function(self) xpcall(function() kboConfig:UpdateTodoOptions(self); end, geterrorhandler()) end
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

	-- Equipment Stats
	parent.pEquipTitle = kboConfig:CreateTitle(parent, nul, 10, -228);
	parent.pEquipTitle:SetText(kboConfig.Text.equipTitle);
	parent.cEquipInt = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cEquipInt:SetPoint("TOPLEFT", parent.pEquipTitle, 0, -18);
	parent.cEquipInt.Text:SetText(kboConfig.Text.equipInt);
	parent.cEquipCrit = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cEquipCrit:SetPoint("TOPLEFT", parent.pEquipTitle, 230, -18);
	parent.cEquipCrit.Text:SetText(kboConfig.Text.equipCrit);
	parent.cEquipHaste = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate");
	parent.cEquipHaste:SetPoint("TOPLEFT", parent.pEquipTitle, 460, -18);
	parent.cEquipHaste.Text:SetText(kboConfig.Text.equipHaste);

	-- Greetings
	parent.pGreetTitle = kboConfig:CreateTitle(parent, nil, 10, -278);
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
-- https://wowwiki.fandom.com/wiki/Creating_tabbed_windows
function kboConfig:CreateTodoPanel(parent)
	-- Add Header
	kboConfig:CreatePanelHeader(parent);
	parent.pTitle:SetText(kboConfig.Text.todoTitle);
	parent.Tabs = {};
	local _taboffset = -15;
	-- Main Tab
	parent.Tabs.fTodoMain = kboConfig:CreateTodoPanelTab(parent);
	parent.pTodoMainTitle = kboConfig:CreateTitle(parent.Tabs.fTodoMain, nil, 5, 5);
	parent.pTodoMainTitle:SetText(kboConfig.Text.todoMainTitle .." Chores");
	parent.bTodoMainTab = CreateFrame("Button", "$parentTab1", parent, "CharacterFrameTabButtonTemplate");
	parent.bTodoMainTab:SetPoint("BOTTOMLEFT", parent, 8, -28);
	parent.bTodoMainTab:SetText(kboConfig.Text.todoMainTitle);
	parent.bTodoMainTab:SetScript("OnClick", function(self) kboConfig:TodoTabClicked(self:GetName()); end);
	parent.Item = {};
	for i=0, 14, 1 do
		local item = kboConfig:CreateTodoItem(parent.Tabs.fTodoMain);
		local offset = (i * -30) -25;
		item:SetPoint("BOTTOMLEFT", parent.pTodoMainTitle, 0, offset);
		table.insert(parent.Item, item);
	end
	parent.Item[1].bScrollup:Disable();
	parent.Item[15].bScrolldown:Disable();
	-- Quests
	parent.Tabs.fTodoQuests = kboConfig:CreateTodoPanelTab(parent);
	parent.pTodoQuestsTitle = kboConfig:CreateTitle(parent.Tabs.fTodoQuests, nil, 5, 5);
	parent.pTodoQuestsTitle:SetText(kboConfig.Text.todoQuestsTitle .." Chores");
	parent.bTodoQuestsTab = CreateFrame("Button", "$parentTab2", parent, "CharacterFrameTabButtonTemplate");
	parent.bTodoQuestsTab:SetPoint("LEFT", parent.bTodoMainTab, "RIGHT", _taboffset, 0);
	parent.bTodoQuestsTab:SetText(kboConfig.Text.todoQuestsTitle);
	parent.bTodoQuestsTab:SetScript("OnClick", function(self) kboConfig:TodoTabClicked(self:GetName()); end);
	-- Achievements
	parent.Tabs.fTodoAchievements = kboConfig:CreateTodoPanelTab(parent);
	parent.pTodoAchievementsTitle = kboConfig:CreateTitle(parent.Tabs.fTodoAchievements, nil, 5, 5);
	parent.pTodoAchievementsTitle:SetText(kboConfig.Text.todoAchievementsTitle .." Chores");
	parent.bTodoAchievementsTab = CreateFrame("Button", "$parentTab3", parent, "CharacterFrameTabButtonTemplate");
	parent.bTodoAchievementsTab:SetPoint("LEFT", parent.bTodoQuestsTab, "RIGHT", _taboffset, 0);
	parent.bTodoAchievementsTab:SetText(kboConfig.Text.todoAchievementsTitle);
	parent.bTodoAchievementsTab:SetScript("OnClick", function(self) kboConfig:TodoTabClicked(self:GetName()); end);
	-- Instances
	parent.Tabs.fTodoInstances = kboConfig:CreateTodoPanelTab(parent);
	parent.pTodoInstancesTitle = kboConfig:CreateTitle(parent.Tabs.fTodoInstances, nil, 5, 5);
	parent.pTodoInstancesTitle:SetText(kboConfig.Text.todoInstancesTitle .." Chores");
	parent.bTodoInstancesTab = CreateFrame("Button", "$parentTab4", parent, "CharacterFrameTabButtonTemplate");
	parent.bTodoInstancesTab:SetPoint("LEFT", parent.bTodoAchievementsTab, "RIGHT", _taboffset, 0);
	parent.bTodoInstancesTab:SetText(kboConfig.Text.todoInstancesTitle);
	parent.bTodoInstancesTab:SetScript("OnClick", function(self) kboConfig:TodoTabClicked(self:GetName()); end);
	-- Setup initial view
	local _tabs = 0;
	for _ in pairs(parent.Tabs) do _tabs = _tabs + 1; end
	PanelTemplates_SetNumTabs(parent, _tabs);
	kboConfig:TodoTabClicked("kboConfigTodoPanelTab1");
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
	-- Equipment
	local equipInt, equipCrit, equipHaste = kbo.Data:GetEquipCheck();
	parent.cEquipInt:SetChecked(equipInt);
	parent.cEquipCrit:SetChecked(equipCrit);
	parent.cEquipHaste:SetChecked(equipHaste);
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
	-- Equipment
	kbo.Data:SetEquipCheck(
		parent.cEquipInt:GetChecked(),
		parent.cEquipCrit:GetChecked(),
		parent.cEquipHaste:GetChecked()
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
	parent.cEquipInt:SetChecked(DEFAULTS.equipInt);
	parent.cEquipCrit:SetChecked(DEFAULTS.equipCrit);
	parent.cEquipHaste:SetChecked(DEFAULTS.equipHaste);
	parent.cGreetGuild:SetChecked(DEFAULTS.greetGuild);
	parent.iGreetGuildHello:SetText(DEFAULTS.greetGuildHello);
	parent.iGreetGuildWelcome:SetText(DEFAULTS.greetGuildWelcome);
	parent.cGreetG6:SetChecked(DEFAULTS.greetGuild);
	parent.iGreetG6Hello:SetText(DEFAULTS.greetGruppe6Hello);
	parent.iGreetG6Back:SetText(DEFAULTS.greetGruppe6Back);
	parent.cDebug:SetChecked(DEFAULTS.Debug);
	kboConfig:SaveOptions(parent);
end

-- Set Values for Todo-Options
function kboConfig:UpdateTodoOptions(parent)
	kboConfig:TodoTabClicked("kboConfigTodoPanelTab1");
end

-- Tab-Button clicked; switch view!
function kboConfig:TodoTabClicked(tabname)
	-- Hide all Frames
	for tab in pairs(kboConfig.TodoPanel.Tabs) do kboConfig.TodoPanel.Tabs[tab]:Hide(); end
	-- Show the correct one
	if tabname == "kboConfigTodoPanelTab1" then
		kboConfig.TodoPanel.Tabs.fTodoMain:Show();
		PanelTemplates_SetTab(kboConfig.TodoPanel, 1);
	elseif tabname == "kboConfigTodoPanelTab2" then
		kboConfig.TodoPanel.Tabs.fTodoQuests:Show();
		PanelTemplates_SetTab(kboConfig.TodoPanel, 2);
	elseif tabname == "kboConfigTodoPanelTab3" then
		kboConfig.TodoPanel.Tabs.fTodoAchievements:Show();
		PanelTemplates_SetTab(kboConfig.TodoPanel, 3);
	elseif tabname == "kboConfigTodoPanelTab4" then
		kboConfig.TodoPanel.Tabs.fTodoInstances:Show();
		PanelTemplates_SetTab(kboConfig.TodoPanel, 4);
	else kbo:PrintDebug("No such tab, " ..tabname); end
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
	editbox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate");
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

-- Panel for Todo-Tabs
function kboConfig:CreateTodoPanelTab(parent)
	panel = CreateFrame("Frame", nil, parent);
	panel:SetPoint("TOPLEFT", 5, -63);
	panel:SetSize(600, 510);
--	panel.pActionTitle = kboConfig:CreateTitle(parent, "GameFontHighlightSmall", 10, -80);
--	panel.pActionTitle:SetText("Actions");
	panel.pObjectTitle = kboConfig:CreateTitle(parent, "GameFontHighlight", 50, -80);
	panel.pObjectTitle:SetText("Objective");
	panel.pGoalTitle = kboConfig:CreateTitle(parent, "GameFontHighlight", 380, -80);
	panel.pGoalTitle:SetText("Goal");
	return panel;
end

function kboConfig:CreateTodoItem(parent)
	local item = CreateFrame("Frame", nil, parent);
	item:SetSize(600, 20);
	item.cItemActive = CreateFrame("CheckButton", nil, item, "ChatConfigSmallCheckButtonTemplate");
	item.cItemActive:SetPoint("LEFT", item, 0, -25);
	item.cItemActive:SetHitRectInsets(0, 0, 0, 0);
	item.bScrollup = CreateFrame("Button", nil, item, "UIPanelScrollUpButtonTemplate");
	item.bScrollup:SetSize(12, 12);
	item.bScrollup:SetPoint("TOPLEFT", item.cItemActive, "TOPRIGHT", 0, 2);
	item.bScrolldown = CreateFrame("Button", nil, item, "UIPanelScrollDownButtonTemplate");
	item.bScrolldown:SetSize(12, 12);
	item.bScrolldown:SetPoint("BOTTOMLEFT", item.cItemActive, "BOTTOMRIGHT", 0, -2);
	item.iTodo = kboConfig:CreateEditbox(item, 310);
	item.iTodo:SetPoint("LEFT", item.cItemActive, "RIGHT", 22, 1);
	item.pSeparator = item:CreateFontString(nil, "BACKGROUND");
	item.pSeparator:SetSize(20, 20);
	item.pSeparator:SetPoint("LEFT", item.iTodo, "RIGHT", 0, 0);
	item.pSeparator:SetFontObject("GameFontNormal");
	item.pSeparator:SetText(">");
	item.iGoal = kboConfig:CreateEditbox(item, 200);
	item.iGoal:SetPoint("LEFT", item.pSeparator, "RIGHT", 4, 0);
	item.bDelete = CreateFrame("Button", nil, item,"UIPanelCloseButton");
	item.bDelete:SetSize(20, 20);
	item.bDelete:SetPoint("LEFT", item.iGoal, "RIGHT", 5, 1);
	item.bDelete:SetScript("OnClick", function(self) end);
	return item;
end