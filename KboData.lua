-----------------
-- Data "class"
-----------------
KboData = {};
KboData.__index = KboData;

-- Constructor
function KboData:New(kboDatabase)
	self = {
		RESTORED	= false,
		VERSION		= 2,
		lastonline	= kboData_Lastlogin or (time() - (27*60*60)), -- let's just assume yesterday as a default
	};
	setmetatable(self, KboData);
	self.db = {};
	self.db.__index = KboPlayer;
	-- Restore previous data
	if kboDatabase ~= nil then
		self.RESTORED	= true;
	end
	return self;
end

-- Reset player-data
function KboData:Initialize(force)
	if force == true then wipe(self.db); end
	self:UpdateLogin();
end


-----------------
-- Login functions
-----------------

-- Check if this is the first time logging in today
function KboData:IsFirstLoginToday()
	return kbo:IsToday(self.lastonline);
end

-- Store first time (daily) we have been online
function KboData:UpdateLogin()
	if kbo:IsToday(self.lastonline) == false then
		self.lastonline = time() - (3 *60 *60); --Adjusting timestamp so that the new day starts at 3AM
	end
end


-----------------
-- Guild functions
-----------------

-- Update guild-roster
function KboData:UpdateRoster()
	for i = 1, GetNumGuildMembers() do
		-- Extract information for all guild-members and build guild-tables
		local charactername, rank, _, _, _, _, note, _, isOnline, _, _, achievements, _, _, _, _ = GetGuildRosterInfo(i);
		local playername = (note ~= "") and note or charactername; -- in case no note is given, use charactername
		-- Store character
		local _playername = kbo:SanitizeName(playername);
		if self:HasPlayer(playername) == false then self.db[_playername] = KboPlayer:New(playername); end
		self.db[_playername]:SetRank(rank);
		self.db[_playername]:SetAchievements(achievements);
		self.db[_playername]:AddCharacter(charactername);
		-- Store last login-time
		local _charlogoff = 0;
		if isOnline then
			_charlogoff = time();
		else
			local years, months, days, hours = GetGuildRosterLastOnline(i);
			--Sanitize and convert to timestamp
			years, months, days, hours = years or 0, months or 0, days or 0, hours or 0;
			local _logoff = ((((years*12) + months) * 30.5 + days) * 24 + hours) * 60 * 60;
			-- Subtract from current time for comparison with time()
			_charlogoff = time() - _logoff;
		end
		self.db[_playername]:UpdatePlayerLogin(_charlogoff);
	end
end

-- Create Achievement table
function KboData:GetAchievementTable()
	local achievementTable = {};
	local _players = self:GetPlayernames();
	for _, _playername in pairs(_players) do
		local _stats = kbo.Data:GetPlayerData(_playername);
		if _stats ~= false then
			table.insert(achievementTable, {
				playername = _stats["playername"],
				rankcolor = _stats["rankcolor"],
				achievements = _stats["achievements"],
			});
		end
	end
	return achievementTable;
end
-- Create Player/TwinkCount table
function KboData:GetTwinkcountTable()
	local twinkcount = {};
	local _players = self:GetPlayernames();
	for _, _playername in pairs(_players) do
		local _stats = kbo.Data:GetPlayerData(_playername);
		if _stats ~= false then
			table.insert(twinkcount, {
				playername = _stats["playername"],
				rankcolor = _stats["rankcolor"],
				twinkcount = _stats["twinkcount"],
			});
		end
	end
	return twinkcount;
end


-----------------
-- Player functions
-----------------

-- Check wether or not this player exists
function KboData:HasPlayer(playername)
	if playername == "__index" then return false; end
	return kbo:ContainsKey(self.db, kbo:SanitizeName(playername), true);
end

-- Return amount of players
function KboData:GetNumPlayers()
	local _players = self:GetPlayernames()
	return table.getn(_players);
end

-- Return a list of playernames
function KboData:GetPlayernames()
	local _playernames = {}
	for _playername in pairs(self.db) do
		if _playername ~= "__index" then table.insert(_playernames, _playername); end
	end
	return _playernames;
end

-- Find the playername for a given character
function KboData:GetPlayerForCharacter(charactername)
	if charactername == nil then return false; end
	local _players = self:GetPlayernames();
	for _, _playername in pairs(_players) do
		if self.db[_playername]:HasCharacter(charactername) then return self.db[_playername]:GetPlayername(); end
	end
	return false;
end

-- Return player-data
function KboData:GetPlayerData(playername)
	if self:HasPlayer(playername) == false then return false; end
	local _playername = kbo:SanitizeName(playername);
	return {
		playername	= self.db[_playername]:GetPlayername(),
		lastonline	= self.db[_playername]:GetLastLogin(),
		rank		= self.db[_playername]:GetRank(),
		rankcolor	= self.db[_playername]:GetRankColor(),
		twinkcount	= self.db[_playername]:GetNumTwinks(),
		achievements= self.db[_playername]:GetAchievements(),
	}
end


-----------------
-- Generic Get/Set functions
-----------------

-- Return function
function KboData:GetLogin()
	return self.lastonline;
end
function KboData:GetDB()
	return self.db;
end
