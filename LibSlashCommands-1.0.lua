-- for more info and examples check the GitHub wiki
-- https://github.com/BellinRattin/LibSlashCommands-1.0/wiki

local MAJOR, MINOR = "LibSlashCommands-1.0", 1
local LSC = LibStub:NewLibrary(MAJOR, MINOR)

if not LSC then return end

-- check if the first character of a string is / otherwise add it
local function CheckForLeadingSlash(word)
	if not (string.sub(word,1,1) == "/") then
		word = "/"..word
	end
	return word
end

local function CheckForAlreadyExistingSlashCommand(sc)
	for id, val = in pairs(_G) do
		if id:sub(1,5) == "SLASH" and val = sc then
			return true
		end
	end
	return false
end

local SlashCommand = {}

function SlashCommand:AddIdentifier(identifier)
	if type(identifier) == "nil" then return end
	assert((type(identifier) == "string"), "error, string or table requested")
	self.identifier = identifier:upper()
end



local function AddAliasToTable(alias, tab, silent)
	local sc = CheckForLeadingSlash(alias)
	local exist = CheckForAlreadyExistingSlashCommand(sc)
	if not exist then 
		table.insert(tab, alias)
	elseif not silent then
		print("ERROR: "..sc.." already exists")
	end
end

function SlashCommand:AddAlias(alias)
	if type(alias) == "nil" then return end
	local ty = type(alias)
	assert((ty == "string") or (ty == "table"), "error, string or table requested")
	self.aliases = self.aliases or {}
	if ty == "string" then
		AddAliasToTable(alias, self.aliases, self.silentError)
	else
		for i = 1,#alias do
			AddAliasToTable(alias[i], self.aliases, self.silentError)
		end
	end
end

function SlashCommand:AddArgument(argument, handler)
	if type(argument) == "nil" then return end
	local arty = type(argument)
	assert((arty == "string") or (arty == "table"), "argument #1 error, string or table requested")
	local haty = type(handler)
	assert((haty == "function") or (haty == "nil"), "argument #2 error, function requested")
	self.arguments = self.arguments or {}

	if arty == "string" then
		self.arguments[argument] =  handler
	else
		for i = 1,#argument do
			self.arguments[argument[i][1]] = argument[i][2]
		end
	end
end

function SlashCommand:AddNoArgument(handler)
	if type(handler) == "nil" then return end
	self.noArgument = true
	self.noArgumentFunction = handler
end

function SlashCommand:AddWrongArgument(handler)
	if type(handler) == "nil" then return end
	self.wrongArgument = true
	self.wrongArgumentFunction = handler
end

-- return SlashCommand Object
function SlashCommand:New(identifier, aliases, arguments, noArgument, wrongArgument)
	local obj = {}
	setmetatable(obj, self)
	self.__index = self

	obj:AddIdentifier(identifier)
	obj:AddAlias(aliases)
	obj:AddArgument(arguments)
	obj:AddNoArgument(noArgument)
	obj:AddWrongArgument(wrongArgument)
	obj.silentError = false

	return obj
end

function SlashCommand:Done()
	if not self.identifier then
		self.identifier = string.match(debugstack(3), '%[string "@\Interface\\AddOns\\(%S+)\\'):upper()
	end 
	if #self.aliases == 0 then 
		if not self.silentError then
			print("You need at least one alias")
		end
		return 
	end
	for i = 1,#self.aliases do
		_G["SLASH_"..self.identifier..i] = self.aliases[i]
	end
	SlashCmdList[self.identifier] = function (msg, editBox)
		local others = {}
		for other in msg:gmatch("%S+") do table.insert(others, other) end
		--local argument = table.remove(others, 1)
		local argument = others[1]

		if next(self.arguments) and argument then
			table.remove(others,1)
			if self.arguments[argument] then
				self.arguments[argument](others, editBox)
			elseif self.wrongArgument then
				self.wrongArgumentFunction()
			end
		elseif self.noArgument then
			--table.insert(others, 1 ,argument)
			self.noArgumentFunction(others, editBox)
		end
	end
end

-- LSC:NewSlashCommand([identifier], [aliases], [arguments], [noArgument],[wrongArgument])
-- [identifier]	(string) 			- optional, unique identifier to the slash command. If omitted the addon name will be used
-- [aliases]	(string or table)	- optional, words the slash command respond to (i.e /myaddon, /myadd)
--									  single string (ie "/myaddon") or table of string (ie {"/myaddon","/myadd","/addonmy"})
-- [arguments]	(table)				- optional, table of pairs {argument, handler} (i.e. {{argument1,handler1},{argument2,handler2},{argument3,handler3}})
-- [noArgument]	(function)			- for when the slash command is called with no arguments
-- [wrongArgument](function)		- for when the slash command is called with an argument that does not exist
--
-- all arguments are optionals, can be added later with
-- identifier 	-> :AddIdentifier(identifier)
-- aliases		-> :AddAlias(aliases)
-- arguments	-> :AddArgument(arguments)
-- noArgument 	-> :AddNoArgument(handler)
-- wrongArgument-> :AddWrongArgument(handler)
function LSC:NewSlashCommand(identifier, aliases, arguments, noArgument, wrongArgument)
	return SlashCommand:New(identifier, aliases, arguments, noArgument, wrongArgument)
end

-- LSC:NewSimpeSlashCommand([identifier], aliases, handler)
-- simplified version, for a simplier slash command with no arguments (but with others)
function LSC:NewSimpeSlashCommand(aliases, handler, identifier)
	local sc = LSC:NewSlashCommand(identifier, aliases, nil, handler, nil)
	sc:Done()
end