-----------------
-- Player "class"
-----------------
KboPlayer = {};
KboPlayer.__index = KboPlayer;

-- Constructor
function KboPlayer:New(playername)
	local self = {};
	setmetatable(self, KboPlayer);
	self.VERSION = 1;
	self.characters = {};
	self.name = playername or "Unknown";
	self.rank = "Unknown";
	self.lastlogin = 0;
	self.wordcount = 0;
	return self;
end


-----------------
-- Login Functionality
-----------------

-- Update timestamp for this player
function KboPlayer:UpdatePlayerLogin(timestamp)
	if timestamp == nil then timestamp = time(); end
	if timestamp > self.lastlogin then self.lastlogin = timestamp; end
end

-- Return whether or not this player is logging in for the first time today
function KboPlayer:IsFirstLoginToday()
	return kbo:IsToday(self.lastlogin);
end


-----------------
-- Character Functionality
-----------------

-- Add Character for this player
function KboPlayer:AddCharacter(charactername)
	if self:HasCharacter(charactername) == false then
		table.insert(self.characters, kbo:SanitizeName(charactername));
	end
end

-- Return whether or not this player has a character by this name
function KboPlayer:HasCharacter(charactername)
	if charactername == nil or charactername == "__index" then return false; end
	return kbo:ContainsValue(self.characters, kbo:SanitizeName(charactername), true);
end


-----------------
-- Lookup functions
-----------------

-- Get Rank-based colors
function KboPlayer:GetRankColor()
	local _color = "ff9d9d9d";
	if self.rank == "Offi" then
		_color = "ffe6cc80";
	elseif self.rank == "Twix" then
		_color = "ffff8000";
	elseif self.rank == "Raider" then
		_color = "ffa335ee";
	elseif self.rank == "Member" then
		_color = "ff1eff00";
	elseif self.rank == "F&F" then
		_color = "ffffffff";
	end
	return _color;
end


-----------------
-- Wordcount Functionality
-----------------

-- Add a number to this players wordcount
function KboPlayer:AddWordcount(number)
	self.wordcount = self.wordcount + number;
end


-----------------
-- Other Get/Set functions
-----------------

-- Set functions
function KboPlayer:SetRank(rank)
	self.rank = rank;
end

-- Return Functions
function KboPlayer:GetLastLogin()
	return self.lastlogin;
end
function KboPlayer:GetPlayername()
	return self.name;
end
function KboPlayer:GetRank()
	return self.rank;
end
function KboPlayer:GetNumTwinks()
	return table.getn(self.characters);
end
function KboPlayer:GetWordcount()
	return self.wordcount;
end
