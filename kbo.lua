-----------------
-- Backlog
--   [/]   Who is the most chattiest in /g?
--   [?]   Content of tables in Addon-Options
--   [x]   Announce how many achievements are left when getting one
--           total, completed = GetNumCompletedAchievements()
--   [?]   Add Death-Counter to MeDead()
--   [x]   Show gear sorted by iLvl
--   [x]   Gearcheck (crit, socket, enchange) for /kbo equip
--   [x]   Add coloring to announcement of "charname (class) is playername (rank)"
--   [x]   Encapsulate Addon in kbo-namespace
--   [ ]   ToDo tracker and check (have I already done XYZ this week/today?)
--   
-- Buglist
--   [x]   Roster is updates logoff-time prior to us parsing the login,
--         resulting in the user always appearing as having logged on today already
--   [x]   Last-Login not properly updated (remains at Thursday despite being Saturday?)
--   [x]   equip does not show actual iLvl of equiped item
--   [x]   Do not report missing enchant if offhand is not a weapon (e.g. shield)
--   [ ]   Lastlogin not processed correctly
-----------------

-----------------
-- Structure
--
--   kbo		Addon-Namespace
--     data		kboData instance
--     Events		Event functions and hooks
--     Frame		Frame to capture events
--     Greet		Autmated greetings
--     Gruppe6		Gruppe6 functions
--     Guild		Guild functions (parsing /g)
-----------------

-----------------
--- Guidelines
-- 
--   * Manipulated, local variables start with _
--   * Functions and "Classes" start with capital letters
--   * Tables and variables start with small letters
-----------------


-----------------
-- General Stuff
-----------------
kbo = {};
kbo.Frame = CreateFrame("Frame");
kbo.DEBUG = true;
kbo.REALMSUFFIX = "-Antonidas";

-- Standard-output
function kbo:PrintMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffe0kbo:|r " .. message);
end

-- Debug-output
function kbo:PrintDebug(message)
	if kbo.DEBUG then
		kbo:PrintMessage("|cffFFC125" .. message .."|r");
	end
end

-- Helper functions
function kbo:ContainsString(haystack, needle, strict)
	local _strict = (strict == true) and true or false;
	if _strict then return (haystack == needle)
	elseif string.find(haystack, needle) then return true; else return false;
	end
end
function kbo:ContainsKey(haystack, needle, strict)
	local _strict = (strict == true) and true or false;
	for key in pairs(haystack) do if kbo:ContainsString(key, needle, _strict) then return true; end end
	return false;
end
function kbo:ContainsValue(haystack, needle, strict)
	local _strict = (strict == true) and true or false;
	for key, value in pairs(haystack) do if kbo:ContainsString(value, needle, _strict) then return true; end end
	return false;
end
function kbo.IsFirstLoginToday()
	return kbo:IsToday(kbo.Data.lastonline);
end
function kbo:IsToday(timestamp)
	return date("%j") == date("%j", timestamp); -- Using day-of-year as granularity
end
function kbo:SanitizeName(name)
	return string.lower(string.gsub(name, kbo.REALMSUFFIX, ""));
end
function kbo:RoundNumber(number)
	local _number = number * 10;
	_number = _number + 0.5 - (_number + 0.5) % 1
	return _number / 10;
end

-----------------
-- Data Handling
-----------------
kbo.Data = { RESTORED = false };
kbo.Data.__index = KboData;

-- Event function for Player-Login
function kbo.Data:OnLogin()
	if kbo.Data.RESTORED == false then
		kbo.Data = KboData:New();
		kbo.Data:Initialize();
	end
	kbo.Data:UpdateLogin();
	kbo.Data:UpdateRoster();
end

-- Event function for Player-Logout
function kbo.Data:OnLogout()
	kbo.Data.RESTORED = true;
end


-----------------
-- Events
-----------------
kbo.Events = {};

-- Declare event-handling functions
function kbo.Events:ADDON_LOADED(addon)
	if addon == "kbo" then
		kbo.Data:OnLogin();
		kbo:PrintDebug("Last-Login reported as " .. date("%A (%R)", kbo.Data:GetLogin()));
		kbo.Greet:OnLogin();
	end
end
function kbo.Events:ACHIEVEMENT_EARNED(achievementID)
	kbo.Slash:AchievementsRemaining();
end
function kbo.Events:CHAT_MSG_SYSTEM(message)
	kbo.Greet:ParseSystemMessage(message);
end
function kbo.Events:CHAT_MSG_CHANNEL(message, author, _, _, target, flags, _, channelnumber, channelname, ...)
	if channelname == kbo.Gruppe6:GetChannel() then
		kbo.Gruppe6:ParseMessage(message, author);
	end
end
--function kbo.Events:CHAT_MSG_CHANNEL_JOIN(_, name, _, _, channelnumber, channelname)
--	if channelname == gruppe6_Channel then
--		Greet_WelcomeMessage(name);
--	end
--end
function kbo.Events:CHAT_MSG_GUILD(message, author, _, _)
	kbo.Guild.ParseGuildMessage(message, author);
end
function kbo.Events:PLAYER_DEAD(...)
	kbo.Gruppe6:OnDead();
end
function kbo.Events:PLAYER_LOGIN(...)
	kbo.Greet:OnLogin();
	kbo.Gruppe6:OnLogin();
end
function kbo.Events:PLAYER_LOGOUT(...)
	kbo.Frame:UnregisterAllEvents();
	kbo.Data:OnLogout();
end

-- Hook event-handlers
kbo.Frame:SetScript("OnEvent", function(self, event, ...)
	kbo.Events[event](self, ...);
end)
kbo.Frame:UnregisterAllEvents();
for eventhandler in pairs(kbo.Events) do
	kbo.Frame:RegisterEvent(eventhandler);
end


-----------------
-- Commandline functions
-----------------
kbo.Slash = {};
SLASH_kbo1 = "/kbo";

-- Define slash-commands
local function SlashHandler(msg, editBox)
	if msg == nil or msg == "" then msg = "help" end
	-- Extract information
	local _msg, args = msg:match("^(%S*)%s*(.-)$");
	_msg = string.lower(_msg);
	local focuscolor = "|cffffff00";
	-- Standard actions
	if _msg == "babble" or _msg == "wordcount" then
		kbo.Slash:WordcountLeaderboard();
	elseif _msg == "chievies" then
		kbo.Slash:AchievementsRemaining();
	elseif _msg == "equip" then
		kbo.Slash:EquipmentCheck();
	elseif _msg == "quests" then
		kbo.Slash:QuestQueue();
	elseif _msg == "stats" then
		kbo.Slash:MyStats();
	elseif _msg == "todo" then
		kbo.Slash:Todo();
	elseif _msg == "twinks" then
		kbo.Slash:TwinkLeaderboard();
	elseif _msg == "whois" then
		local _charactername = (args ~= "") and args or "Kabori";
		kbo.Slash:WhoIs(_charactername);
	elseif _msg == "help" or _msg == "?" then
		kbo:PrintMessage(focuscolor .. "babble|r list most chattiest players");
		kbo:PrintMessage(focuscolor .. "chivies|r show achievment-progress");
		kbo:PrintMessage(focuscolor .. "equip|r analyse equiped items");
		kbo:PrintMessage(focuscolor .. "quests|r status of quest-queue");
		kbo:PrintMessage(focuscolor .. "stats|r list most important player-statistics");
		kbo:PrintMessage(focuscolor .. "twinks|r twink-leaderboard");
--		kbo:PrintMessage(focuscolor .. "update|r update guild-roster");
		kbo:PrintMessage(focuscolor .. "whois <name>|r show who the player behind that character is");
	-- Debug actions
	elseif _msg == "resetlastonline" then
		if kbo.DEBUG then kbo.Data:UpdatLogin(); end
	elseif _msg == "resetguild" then
		if kbo.DEBUG then
			kbo.Data:Initialize();
			kbo:PrintMessage("Player-Data has been reset");
			kbo.Data:UpdateRoster();
		end
	elseif _msg == "update" then
		kbo.Data:UpdateGuild();
	elseif _msg == "testwelcome" then
		local _playername = (args ~= "") and args or "Kabori";
		if kbo.DEBUG then kbo.Greet:WelcomeMessage(_playername); end
	elseif _msg == "showdata" then
		local _playername = (args ~= "") and args or false;
		if not _playername then
			_restored = kbo.Data.RESTORED and "true" or "false";
			kbo:PrintMessage(focuscolor .. "lastonline|r ".. kbo.Data.lastonline);
			kbo:PrintMessage(focuscolor .. "restored|r ".. _restored);
			kbo:PrintMessage(focuscolor .. "version|r ".. kbo.Data.VERSION);
		else
			local playerdata = kbo.Data:GetPlayerData(_playername)
			if playerdata ~= false then
				kbo:PrintMessage("Data for player " .. _playername);
				for key, val in pairs(playerdata) do
					if key ~= "characters" then kbo:PrintMessage(focuscolor .. key .." |r ".. val);
					else
						for _, _character in pairs(val) do kbo:PrintMessage(focuscolor .."Character|r ".. _character); end
					end
				end
			else kbo:PrintMessage("No such player, ".. _playername .."."); end
		end
	else
		kbo:PrintMessage("Unknown command, ".. _msg ..".");
	end
end

-- Hook slashcommand
SlashCmdList["kbo"] = SlashHandler

-- How much do I still have to do?
function kbo.Slash:AchievementsRemaining()
	local total, completed = GetNumCompletedAchievements();
	local _missing = total - completed;
	local _relation = (completed / total) * 100;
	local _percentage = kbo:RoundNumber(_relation);
	kbo:PrintMessage(_missing .. " achievements remaining (" .. _percentage .. "% done).");
end

-- Tell me how many quests I can still accept
function kbo.Slash:QuestQueue()
	local _numEntries, _numQuests = GetNumQuestLogEntries();
	kbo:PrintMessage(_numQuests .. " quests active, " .. 25-_numQuests .. " slots free.");
end

-- Check and list equipment
function kbo.Slash:EquipmentCheck()
	-- Get equipped items
	local items, enchantedSlots = {}, {10, 11, 12, 16, 17};
	for i = 0, 18, 1 do
		local _itemLink = GetInventoryItemLink("player", i);
		if _itemLink ~= nil and i ~= 4 then --skipping shirt
			-- Get item-details
			local _itemName, _itemLink, _, _, _, _, itemSubType , _, _, _, _ = GetItemInfo(_itemLink);
			local _itemLevel, _, _ = GetDetailedItemLevelInfo(_itemLink);
			-- Extract enchants and socketed gems (https://wow.gamepedia.com/ItemLink)
			local _remark = "";
			local _, _, _, _, _, _enchantID, gem1ID, gem2ID, gem3ID, gem4ID, _, _, _, _
			  = string.find(_itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
			local _stats = GetItemStats(_itemLink);
			-- Check for missing stuff
			if not (kbo:ContainsKey(_stats, "^ITEM_MOD_CRIT", false) or kbo:ContainsKey(_stats, "^ITEM_MOD_INTELLECT", false)) then
				_remark = "Wrong stats";
			end
			if kbo:ContainsValue(enchantedSlots, i) then
				if not itemSubType == "Shields" then
					if _enchantID == "" then _remark = "Enchantment missing"; end
				end
			end
			local _stats = GetItemStats(GetInventoryItemLink("player", i));
			if kbo:ContainsKey(_stats, "^EMPTY_SOCKET", false) then
				if gem1ID == "" then _remark = "Gem missing"; end
			end
			-- Store item
			table.insert(items, {
				name = _itemName,
				link = _itemLink,
				iLvl = _itemLevel,
				slot = i,
				remark = _remark,
			});
		end
	end
	-- Sort equipment by iLvl
	repeat
		local _sorted = true;
		for i = 1, table.getn(items) - 1, 1 do
			local j = i + 1;
			if items[i] and items[i]["iLvl"] < items[j]["iLvl"] then
				local _t = items[i];
				items[i] = items[j];
				items[j] = _t;
				_sorted = false;
			end
		end
	until _sorted
	-- Print everything
	local _avg = GetAverageItemLevel();
	kbo:PrintMessage("Avergage rating is " .. _avg);
	for _, item in pairs(items) do
		-- Determine relation to average iLvl
		local _trend = "o ";
		if item["iLvl"] > _avg then _trend = "▲" 
		elseif item["iLvl"] < _avg then _trend = "▼" end
		-- Print all items
		kbo:PrintMessage(_trend .. item["iLvl"] .. "  " .. item["link"] .. " |cFFFF5555" .. item["remark"] .. "|r");
	end
end

-- Stat-Analysis
function kbo.Slash:MyStats()
	local focuscolor, colorGood, colorTarget, colorBad = "|cffffff00", "|cff00ff00", "|cffFF4500", "|cffff0000";
	local _manaRegenBase, _manaRegenCast = GetManaRegen();
	local _crit = GetSpellCritChance(2);
	local _critColor = colorBad;
	if _crit > 30 then _critColor = colorGood;
	elseif _crit > 40 then _critColor = colorTarget;
	elseif _crit > 43 then _critColor = colorBad; end
	local _haste = GetHaste();
	local _hasteColor = colorBad;
	if _haste > 10 then _hasteColor = colorGood;
	elseif _haste > 15 then _hasteColor = colorTarget;
	elseif _haste > 20 then _hasteColor = colorOver; end
	kbo:PrintMessage(focuscolor .."1. Intellect|r ".. UnitStat("player", 4));
	kbo:PrintMessage(focuscolor .."2. Spell-Crit|r ".. _critColor .. kbo:RoundNumber(_crit) .."%|r");
	kbo:PrintMessage(focuscolor .."3. Haste|r ".. _hasteColor .. kbo:RoundNumber(_haste) .."%|r");
--	kbo:PrintMessage(focuscolor .."4. Versatility|r ".. kbo:RoundNumber(GetVersatility()));
	kbo:PrintMessage(focuscolor .."5. Mastery|r ".. kbo:RoundNumber(GetMastery()));
	kbo:PrintMessage(focuscolor .."Healing Bonus|r ".. kbo:RoundNumber(GetSpellBonusHealing()));
	kbo:PrintMessage(focuscolor .."Mana Regeneration|r ".. kbo:RoundNumber(_manaRegenBase) .." (".. kbo:RoundNumber(_manaRegenCast) ..")");
end

-- Wordcount!
function kbo.Slash:WordcountLeaderboard()
	local leaderboard = kbo.Guild.GetWordcountLeaderboard();
	local _l = (#leaderboard > 5) and 5 or #leaderboard;
	for i = 1, _l, 1 do
		kbo:PrintMessage(i ..". |c".. leaderboard[i]["rankcolor"] .. leaderboard[i]["playername"] .."|r (".. leaderboard[i]["wordcount"] ..")");
	end
end

-- Todo-List
function kbo.Slash:Todo()
	local focuscolor = "|cffffff00";
	-- Check instances
	local instances = {};
	for i = 1, GetNumSavedInstances(), 1 do
		local _name, _id GetSavedInstanceInfo(i);
		table.insert(instances, _id);
	end
--	if not kbo:ContainsValue(instances, ) then
--		kbo:PrintMessage();
--	end
end

-- Twinks...
function kbo.Slash:TwinkLeaderboard()
	local leaderboard = kbo.Guild.GetTwinkLeaderboard();
	local _l = (#leaderboard > 5) and 5 or #leaderboard;
	for i = 1, _l, 1 do
		kbo:PrintMessage(i ..". |c".. leaderboard[i]["rankcolor"] .. leaderboard[i]["playername"] .."|r (".. leaderboard[i]["twinkcount"] ..")");
	end
end

-- WhoIs this character?
function kbo.Slash:WhoIs(charactername)
	local _playername = kbo.Data:GetPlayerForCharacter(_charactername);
	if _playername then
		local _stats = kbo.Data:GetPlayerData(_playername);
		kbo:PrintMessage("[".. _charactername .."] is ".._data["rankcolor"] .. _playername .."|r.");
	else kbo:PrintMessage("No player for character ".. _charactername .."."); end
end

-----------------
-- Gruppe6
-----------------
kbo.Gruppe6 = {};
kbo.Gruppe6.CHANNEL = "gruppe6";
kbo.Gruppe6.text = {
	deathmessage = "{skull}",
}

-- Do some stuff during Login
function kbo.Gruppe6:OnLogin()
--	JoinPermanentChannel(gruppe6_Channel, nil, 6);
	ListChannelByName(kbo.Gruppe6:GetChannel());
end

-- Assume embarassment for your mishaps
function kbo.Gruppe6:OnDead()
	kbo.Gruppe6:SendMessage(kbo.Gruppe6.text.deathmessage);
end

-- Standard answers
function kbo.Gruppe6:ParseMessage(msg, author)
	if kbo.Data:GetPlayerForCharacter(author) == "Lilitu" then
		if kbo:ContainsString(msg, "^Nein[\.!]?$", false) then kbo.Gruppe6:SendMessage("Wohl.");
		elseif kbo:ContainsString("^Ja[\.!]?$", false) then kbo.Gruppe6:SendMessage("Nein.");
		end
	end
end

-- Return function
function kbo.Gruppe6:GetChannel()
	return kbo.Gruppe6.CHANNEL;
end

-- Send a message to our channel
function kbo.Gruppe6:SendMessage(msg)
	SendChatMessage(msg, "CHANNEL", nil, 6);
end


-----------------
-- Automated greetings and welcomes
-----------------
kbo.Greet = {};
kbo.Greet.text = {
	guildHello	= "Moin!",
	guildWelcome	= "Moin.",
	gruppe6Hello	= "\\o/",
	gruppe6Back	= "re",
}

-- Say Hi - if this is the first time joining today
function kbo.Greet:OnLogin()
	if kbo:IsFirstLoginToday() then
		if not kbo.DEBUG then
			SendChatMessage(kbo.Greet.text.guildHello, "GUILD");
			kbo.Gruppe6:SendMessage(kbo.Gruppe6.text.gruppe6Hello);
		else kbo:PrintDebug("Skipping hello-messages.");
		end
--	elseif not kbo.DEBUG then kbo.Gruppe6:SendMessage(kbo.Greet.text.gruppe6Back); end
	end
end

-- Parse system-messages for online-notifications of guild-members
function kbo.Greet:ParseSystemMessage(message)
	local MATCHSTRING_ONLINENOTIFICATION = ERR_FRIEND_ONLINE_SS:format(".+", "(.+)"):gsub("%[","%%[");
	if message ~= nil then
		local _charname = message:match(MATCHSTRING_ONLINENOTIFICATION);
		if _charname ~= nil then kbo.Greet:WelcomeMessage(_charname); end
	end
end

--- Give a welcome (if the person is just logging in for the first time)
function kbo.Greet:WelcomeMessage(charactername)
	local playername = kbo.Data:GetPlayerForCharacter(charactername);
	if playername then
		local _stats = kbo.Data:GetPlayerData(playername);
		kbo:PrintMessage("[".. charactername .."] is |c".. _stats["rankcolor"] .. playername .."|r.");
		-- Check if person has been online today already
		kbo:PrintDebug("Last online on " .. date("%T (%A)", _stats["lastonline"]));
--		if kbo:IsToday(_stats["lastonline"]) then
--			if not kbo.DEBUG then C_Timer.After(4, function()
--				SendChatMessage(kbo.Greet.text.guildWelcome, "GUILD");
--			end) end
--			kbo:PrintDebug("Skipping welcome-message.");
--		end
	else kbo:PrintDebug("Unknown character, ".. charactername ..".");
	end
	kbo.Data:UpdateRoster();
end


-----------------
-- Guild stuff
-----------------
kbo.Guild = {};

-- Parse guildchat-messages
function kbo.Guild:ParseGuildMessage(msg, author)
	if author == nil then return; end
	local playername = kbo.Data:GetPlayerByCharacter(author);
	if playername == false then return; end
	local _, _wordcount = string.gsub(msg, "%S+","")
	kbo.Data:AddPlayerWordcount(playername, _wordcount);
	kbo:PrintDebug(playername .. " earned " .. _wordcount .. " words");
end

-- Show Wordcount Leaderboard
function kbo.Guild:GetWordcountLeaderboard()
	local leaderboard = kbo.Data:GetWordcountTable();
	-- Sorting
	repeat
		local sorted = true;
		for i = 1, table.getn(leaderboard) - 1, 1 do
			local j = i + 1;
			if leaderboard[i] and leaderboard[i]["wordcount"] < leaderboard[j]["wordcount"] then
				local _t = leaderboard[i];
				leaderboard[i] = leaderboard[j];
				leaderboard[j] = _t;
				sorted = false;
			end
		end
	until sorted
	return leaderboard
end

-- Twink Leaderboard
function kbo.Guild:GetTwinkLeaderboard()
	local leaderboard = kbo.Data:GetTwinkcountTable();
	-- Sorting
	repeat
		local sorted = true;
		for i = 1, table.getn(leaderboard) - 1, 1 do
			local j = i + 1;
			if leaderboard[i] and leaderboard[i]["twinkcount"] < leaderboard[j]["twinkcount"] then
				local _t = leaderboard[i];
				leaderboard[i] = leaderboard[j];
				leaderboard[j] = _t;
				sorted = false;
			end
		end
	until sorted
	return leaderboard;
end
