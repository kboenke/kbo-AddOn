-----------------
-- General Stuff
-----------------
kbo = {};
kbo.Frame = CreateFrame("Frame");
kbo.DEBUG = true;
kbo.REALMSUFFIX = "-".. GetRealmName();

-- Saved Variables
kboData_Lastlogin = nil;

-- Standard-output
function kbo:PrintMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cffffffe0kbo:|r " .. message);
end

-- Debug-output
function kbo:PrintDebug(message)
	if kbo.DEBUG then kbo:PrintMessage("|cffFFC125" .. message .."|r"); end
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
kbo.Data = {};

-- Event function for Player-Login
function kbo.Data:OnLogin()
	if kboData_Lastlogin == nil then
		kbo.Data:Initialize();
		kbo:PrintDebug("No stored data available, initializing.")
	else
		kbo.Data = KboData:New();
		kbo:PrintDebug("Last login reported as " .. date("%A (%R)", kbo.Data:GetLogin() + (3 *60 *60))); -- Adjusting for offset
	end
	kbo.Data:UpdateLogin();
	kbo.Data:UpdateRoster();
end


-----------------
-- Events
-----------------
kbo.Events = {};

-- Declare event-handling functions
function kbo.Events:ADDON_LOADED(addon)
	if addon == "kbo" then
		kbo.Data:OnLogin();
	end
end
function kbo.Events:PLAYER_LOGIN(...)
	kbo.Greet:OnLogin();
end
function kbo.Events:PLAYER_ENTERING_WORLD(...)
	kbo.Gruppe6:OnLogin();
end
function kbo.Events:PLAYER_LEAVING_WORLD(...)
	kboData_Lastlogin = kbo.Data:GetLogin();
end
function kbo.Events:PLAYER_LOGOUT(...)
	kbo.Frame:UnregisterAllEvents();
end
function kbo.Events:ACHIEVEMENT_EARNED(achievementID)
	kbo.Slash:AchievementsRemaining();
end
function kbo.Events:CHAT_MSG_SYSTEM(message)
	kbo.Greet:ParseSystemMessage(message);
end
function kbo.Events:CHAT_MSG_CHANNEL(message, author, _, _, target, flags, _, channelnumber, channelname, ...)
	if channelname == kbo.Gruppe6:GetChannel() then kbo.Gruppe6:ParseMessage(message, author); end
end
--function kbo.Events:CHAT_MSG_CHANNEL_JOIN(_, name, _, _, channelnumber, channelname)
--	if channelname == gruppe6_Channel then Greet_WelcomeMessage(name); end
--end
function kbo.Events:PLAYER_GUILD_UPDATE(...)
	kbo.Data:UpdateRoster();
end
function kbo.Events:PLAYER_DEAD(...)
	kbo.Gruppe6:OnDead();
end

-- Hook event-handlers
kbo.Frame:SetScript("OnEvent", function(self, event, ...) kbo.Events[event](self, ...); end)
kbo.Frame:UnregisterAllEvents();
for eventhandler in pairs(kbo.Events) do kbo.Frame:RegisterEvent(eventhandler); end


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
	if _msg == "achievements" or _msg == "astats" then
		kbo.Slash:AchievementLeaderboard();
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
	elseif _msg == "who" or _msg == "whois" then
		local _charactername = (args ~= "") and args or "Kabori";
		kbo.Slash:WhoIs(_charactername);
	elseif _msg == "help" or _msg == "?" then
		kbo:PrintMessage(focuscolor .. "achievements|r print guild achievement rankings");
		kbo:PrintMessage(focuscolor .. "astats|r show achievment-progress");
		kbo:PrintMessage(focuscolor .. "babble|r list most chattiest players");
		kbo:PrintMessage(focuscolor .. "equip|r analyse equiped items");
		kbo:PrintMessage(focuscolor .. "quests|r status of quest-queue");
		kbo:PrintMessage(focuscolor .. "stats|r list most important player-statistics");
		kbo:PrintMessage(focuscolor .. "twinks|r twink-leaderboard");
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
		kbo.Data:UpdateRoster();
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
					else for _, _character in pairs(val) do kbo:PrintMessage(focuscolor .."Character|r ".. _character); end
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
	local focuscolor = "|cffffff00";
	-- Calculate achievements
	local total, completed = GetNumCompletedAchievements();
	local points = GetTotalAchievementPoints();
	local _missing, _relation = total - completed, (completed / total) * 100;
	local _percentage = kbo:RoundNumber(_relation);
	-- Get guild-ranking
	local leaderboard, _me, _rank, _nextrank = kbo.Guild:GetAchievementLeaderboard(), kbo.Data:GetPlayerForCharacter(UnitName("player")), 0, 0;
	for i = 1, #leaderboard, 1 do if leaderboard[i]["playername"] == _me then _rank = i; end end
	if (_rank > 1) then _nextrank = leaderboard[_rank-1]["achievements"]; end
	-- Output
	_output = "%s achievements remaining (%s %% done). Now at ".. focuscolor .."guild-rank #%s|r, %s to next rank.";
	kbo:PrintMessage(string.format(_output, _missing, _percentage, _rank, (_nextrank-points)));
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
			local _, _, _, _, _, _enchantID, gem1ID, gem2ID, gem3ID, gem4ID, _, _, _, _, _
			  = string.find(_itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
			local _stats = GetItemStats(_itemLink);
			-- Check for missing stuff
			if not (kbo:ContainsKey(_stats, "^ITEM_MOD_CRIT", false) or kbo:ContainsKey(_stats, "^ITEM_MOD_INTELLECT", false)) then
				_remark = "Wrong stats";
			end
			if kbo:ContainsValue(enchantedSlots, i, true) then
				if itemSubType ~= "Shields" then
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
	local _critColor, _hasteColor = colorBad, colorBad;
	-- Evaluate Crit-Ratings
	local _crit = GetSpellCritChance(2); -- Holy only
	if _crit > 30 then _critColor = colorGood;
	elseif _crit > 40 then _critColor = colorTarget;
	elseif _crit > 43 then _critColor = colorBad; end
	-- Evaluate Haste-Ratings
	local _haste = GetHaste();
	if _haste > 10 then _hasteColor = colorGood;
	elseif _haste > 15 then _hasteColor = colorTarget;
	elseif _haste > 20 then _hasteColor = colorOver; end
	-- Output
	kbo:PrintMessage(focuscolor .."1. Intellect|r ".. UnitStat("player", 4));
	kbo:PrintMessage(focuscolor .."2. Spell-Crit|r ".. _critColor .. kbo:RoundNumber(_crit) .."%|r");
	kbo:PrintMessage(focuscolor .."3. Haste|r ".. _hasteColor .. kbo:RoundNumber(_haste) .."%|r");
	kbo:PrintMessage(focuscolor .."4. Versatility|r ".. kbo:RoundNumber(GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) .."%|r");
	kbo:PrintMessage(focuscolor .."5. Mastery|r ".. kbo:RoundNumber(GetMastery()));
	kbo:PrintMessage(focuscolor .."Healing Bonus|r ".. kbo:RoundNumber(GetSpellBonusHealing()));
	kbo:PrintMessage(focuscolor .."Mana Regeneration|r ".. kbo:RoundNumber(_manaRegenBase) .." (".. kbo:RoundNumber(_manaRegenCast) ..")");
end

-- Achievement Rankings
function kbo.Slash:AchievementLeaderboard()
	local leaderboard = kbo.Guild.GetAchievementLeaderboard();
	local _foundme = false;
	local _me = kbo.Data:GetPlayerForCharacter(UnitName("player"));
	kbo:PrintMessage("Achievement-Leaderboard:");
	for i = 1, #leaderboard, 1 do
		if (i <= 5) or (_foundme == false and leaderboard[i]["playername"] == _me) then
			kbo:PrintMessage(i ..". |c".. leaderboard[i]["rankcolor"] .. leaderboard[i]["playername"] .."|r (".. leaderboard[i]["achievements"] ..")");
		end
		if leaderboard[i]["playername"] == UnitName("player") then _foundme = true; end
	end
end

-- Todo-List
kboData_Todo = {
	general = {
		{
			name = "Feed Ravenous Slime daily",
			location = "Nazjatar (71.71 25.70)",
			reason = {}
		},
		{
			name = "Feed Ravenous Slime daily",
			location = "Nazjatar (54.90 48.70)",
			reason = {}
		},
		{
			name = "Poseidon",
			location = "",
			reason = {}
		}
	},
	achievements = {
		{ name = "|cffffff00|Hachievement:7325:"..strsub(UnitGUID("player"), 3)..":0:0:0:0:0:0:0:0|h[Now I Am the Master]|h|r" },
	},
	instances = {
		{
			name = "Onyxia's Lair",
			boss = "Onyxia",
			items = { "|cffa335ee|Hitem:49636::::::::120:::::|h[Reins of the Onyxian Drake]|h|r" }
		},
		{
			name = "Tempest Keep",
			boss = "Kael'Thas",
			items = { "|cffa335ee|Hitem:32458::::::::120:::::|h[Ashes of Al'ar]|h|r" }
		},
		{
			name = "The Eye of Eternity",
			boss = "Malygos",
			items = { 
				"|cffa335ee|Hitem:43952::::::::120:::::|h[Reins of the Azure Drake]|h|r",
				"|cffa335ee|Hitem:43953::::::::120:::::|h[Reins of the Blue Drake]|h|r"
			},
		},
		{
			name = "Vault of Archavon",
			boss = "Archavon (10)",
			items = { "|cffa335ee|Hitem:39639::::::::120:::::|h[Heroes' Redemption Handguards]|h|r" }
		},
		{
			name = "Vault of Archavon",
			boss = "Emalon (10)",
			items = { "|cffa335ee|Hitem:40889::::::::120:::::|h[Furious Gladiator's Bracers of Triumph]|h|r" }
		},
	},
	quests = {
		{
			name = "Weekly: ",
			quest = "|cffffff00|Hquest:55121:-1|h[The Laboratory of Mardivas]|h|r",
			id = 55121,
			reason = "|cffffff00|Hachievement:13699:"..strsub(UnitGUID("player"), 3)..":0:0:0:0:0:0:0:0|h[Periodic Destruction]|h|r",
		}
	},
}
function kbo.Slash:Todo()
	local focuscolor = "|cffffff00";
	-- General stuff
	kbo:PrintMessage(focuscolor .."General:|r")
	for _, _todo in pairs(kboData_Todo["general"]) do
		kbo:PrintMessage(_todo["name"] .." in " .._todo["location"]);
	end
	-- Achiements
	kbo:PrintMessage(focuscolor .."Achievements:|r")
	for _, _todo in pairs(kboData_Todo["achievements"]) do
		kbo:PrintMessage(_todo["name"]);
	end
	-- Check instances
	kbo:PrintMessage(focuscolor .."Instances:|r")
	local instances = {};
	for i = 1, GetNumSavedInstances(), 1 do
		_name, _, _, _, _locked = GetSavedInstanceInfo(i);
		if _locked then table.insert(instances, _name); end
	end
	for _, _todo in pairs(kboData_Todo["instances"]) do
		if not kbo:ContainsValue(instances, _todo["name"]) then
			_items = "";
			for _, _item in pairs(_todo["items"]) do _items = _items .. ", " .. _item; end
			kbo:PrintMessage(_todo["name"] ..": ".. _todo["boss"] .." for ".. string.sub(_items, 3));
		end
	end
	-- Check Quests
	kbo:PrintMessage(focuscolor .."Quests:|r");
	local quests = GetQuestsCompleted();
	for _, _todo in pairs(kboData_Todo["quests"]) do
		if not kbo:ContainsKey(quests, _todo["id"]) then
			kbo:PrintMessage(_todo["name"] .. _todo["quest"] .." for ".. _todo["reason"])
		end
	end
end

-- Twinks...
function kbo.Slash:TwinkLeaderboard()
	local leaderboard = kbo.Guild.GetTwinkLeaderboard();
	local _l = (#leaderboard > 5) and 5 or #leaderboard;
	kbo:PrintMessage("Twink-Leaderboard:");
	for i = 1, _l, 1 do
		kbo:PrintMessage(i ..". |c".. leaderboard[i]["rankcolor"] .. leaderboard[i]["playername"] .."|r (".. leaderboard[i]["twinkcount"] ..")");
	end
end

-- WhoIs this character?
function kbo.Slash:WhoIs(charactername)
	local _playername = kbo.Data:GetPlayerForCharacter(charactername);
	if _playername then
		local _stats = kbo.Data:GetPlayerData(_playername);
		kbo:PrintMessage("|Hplayer:".. charactername .."|h[".. charactername .."]|h is |c".._stats["rankcolor"] .. _playername .."|r.");
	else kbo:PrintMessage("No player for character ".. charactername .."."); end
end

-----------------
-- Gruppe6
-----------------
kbo.Gruppe6 = {};
kbo.Gruppe6.CHANNEL = "gruppe6";
kbo.Gruppe6.text = {
	deathmessage = "{skull}",
}
local deathcounter = 0;

-- Do some stuff during Login
function kbo.Gruppe6:OnLogin()
--	JoinPermanentChannel(gruppe6_Channel, nil, 6);
	ListChannelByName(kbo.Gruppe6:GetChannel());
end

-- Assume embarassment for your mishaps
function kbo.Gruppe6:OnDead()
	local  _deathmessage = kbo.Gruppe6.text.deathmessage;
	deathcounter = deathcounter + 1;
	if(deathcounter > 1) then _deathmessage = _deathmessage .." Part "..deathcounter; end
	kbo.Gruppe6:SendMessage(_deathmessage);
end

-- Standard answers
function kbo.Gruppe6:ParseMessage(msg, author)
	if kbo.Data:GetPlayerForCharacter(author) == "Lilitu" then
		if kbo:ContainsString(msg, "^Nein[\.!]?$", false) then kbo.Gruppe6:SendMessage("Wohl.");
		elseif kbo:ContainsString(msg, "^Ja[\.!]?$", false) then kbo.Gruppe6:SendMessage("Nein.");
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
	guildHello		= "Moin!",
	guildWelcome	= "Moin.",
	gruppe6Hello	= "\\o/",
	gruppe6Back		= "re",
}

-- Say Hi - if this is the first time joining today
function kbo.Greet:OnLogin()
	if kbo.Data:IsFirstLoginToday() then
		if not kbo.DEBUG then
			SendChatMessage(kbo.Greet.text.guildHello, "GUILD");
			kbo.Gruppe6:SendMessage(kbo.Gruppe6.text.gruppe6Hello);
		else kbo:PrintDebug("Skipping hello-messages.");
		end
	--elseif not kbo.DEBUG then kbo.Gruppe6:SendMessage(kbo.Greet.text.gruppe6Back); end
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
		kbo:PrintMessage("|Hplayer:".. charactername .."|h[".. charactername .."]|h is |c".. _stats["rankcolor"] .. playername .."|r.");
		-- Check if person has been online today already
		kbo:PrintDebug("Last online at " .. date("%T (%A)", _stats["lastonline"]));
		if not kbo:IsToday(_stats["lastonline"]) then
		--	if not kbo.DEBUG then C_Timer.After(4, function()
		--		SendChatMessage(kbo.Greet.text.guildWelcome, "GUILD");
		--	end) end
			kbo:PrintDebug("Skipping welcome-message.");
		end
	else kbo:PrintDebug("Unknown character, ".. charactername ..".");
	end
	kbo.Data:UpdateRoster();
end


-----------------
-- Guild stuff
-----------------
kbo.Guild = {};

-- Twink Leaderboard
function kbo.Guild:GetAchievementLeaderboard()
	local leaderboard = kbo.Data:GetAchievementTable();
	-- Sorting
	repeat
		local sorted = true;
		for i = 1, table.getn(leaderboard) - 1, 1 do
			local j = i + 1;
			if leaderboard[i] and leaderboard[i]["achievements"] < leaderboard[j]["achievements"] then
				local _t = leaderboard[i];
				leaderboard[i] = leaderboard[j];
				leaderboard[j] = _t;
				sorted = false;
			end
		end
	until sorted
	return leaderboard;
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
