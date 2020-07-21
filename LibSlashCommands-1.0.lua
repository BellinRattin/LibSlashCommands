local MAJOR, MINOR = "LibSlashCommands-1.0", 1
local LSC = LibStub:NewLibrary(MAJOR, MINOR)

if not LSC then return end

<<<<<<< HEAD
-- check if the first character of a string is / and remove it
-- return the string (minus leading /)
local function CheckForLeadingSlash(word)
	if not (string.sub(word,1,1) == "/") then
		word = "/"..word
	end
	return word
end

=======
>>>>>>> parent of c44fa3a... Update LibSlashCommands-1.0.lua
local SlashCommand = {}

-- SlashCommand:AddIdentifier(identifier)
-- [identifier]	(string) 			- optional, unique identifier to the slash command. If omitted the addon name will be used
function SlashCommand:AddIdentifier(identifier)
	if type(identifier) == "nil" then return end
	assert((type(identifier) == "string"), "error, string or table requested")
	self.identifier = identifier:upper()
end

-- SlashCommand:AddAlias(alias)
-- [alias]		(string or table)	- words the slash command respond to (i.e /myaddon, /myadd)
--									  single string (ie "/myaddon") or table of string (ie {"/myaddon","/myadd","/addonmy"})
function SlashCommand:AddAlias(alias)
	if type(alias) == "nil" then return end
	local ty = type(alias)
	assert((ty == "string") or (ty == "table"), "error, string or table requested")
	self.aliases = self.aliases or {}
	if ty == "string" then
		print("string "..alias)
<<<<<<< HEAD
		table.insert(self.aliases, CheckForLeadingSlash(alias))
	else
		for i = 1,#alias do
			table.insert(self.aliases, CheckForLeadingSlash(alias[i]))
=======
		table.insert(self.aliases, alias)
	else
		for i = 1,#alias do
			table.insert(self.aliases, alias[i])
>>>>>>> parent of c44fa3a... Update LibSlashCommands-1.0.lua
		end
	end
end

-- SlashCommand:AddArgument(argument, handler)
-- for the slash command in the format "/mycommand argument1 other1 other2 .. otherX"
-- this function has two possible signatures
-- argument 	(string)		- the argument1 in the schema above
-- handler 		(function)		- the function to call in response of argument. all other arguments will be passed as a list (ie {other1, other2,.., otherX})
--								
-- or
--
-- argument 	(table)			- table of pairs {argument, handler} (i.e. {{argument1,handler1},{argument2,handler2},{argument3,handler3}})
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

-- SlashCommand:AddNoArgument(handler)
-- optional, for when the slash command is called with no arguments
--
-- handler 	(function)			- the function to call
function SlashCommand:AddNoArgument(handler)
	if type(handler) == "nil" then return end
	self.noArgument = true
	self.noArgumentFunction = handler
end

-- SlashCommand:AddWrongArgument(handler)
-- optional, for when the slash command is called with an argument that does not exist
--
-- handler 	(function)			- the function to call
function SlashCommand:AddWrongArgument(handler)
	if type(handler) == "nil" then return end
	self.wrongArgument = true
	self.wrongArgumentFunction = handler
end

--[[
function SlashCommand:NewEmpty()
	local obj = {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end
]]

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

	return obj
end

function SlashCommand:Done()
	if not self.identifier then
		self.identifier = string.match(debugstack(3), '%[string "@\Interface\\AddOns\\(%S+)\\'):upper()
	end 
	for i = 1,#self.aliases do
		_G["SLASH_"..self.identifier..i] = self.aliases[i]
	end
	SlashCmdList[self.identifier] = function (msg, editBox)
		local others = {}
		for other in msg:gmatch("%S+") do table.insert(others, other) end
		local argument = table.remove(others, 1)
		if argument then
			if self.arguments[argument] then
				self.arguments[argument](others, editBox)
			elseif self.wrongArgument then
				self.wrongArgumentFunction()
			end
		elseif self.noArgument then
			self.noArgumentFunction(msg, editBox)
		end
	end
end

-- LSC:NewSlashCommand([identifier], [aliases], [arguments])
-- [identifier]	(string) 			- optional, unique identifier to the slash command. If omitted the addon name will be used
-- [aliases]	(string or table)	- optional, words the slash command respond to (i.e /myaddon, /myadd)
--									  single string (ie "/myaddon") or table of string (ie {"/myaddon","/myadd","/addonmy"})
-- [arguments]	(table)				- optional, table of pairs {argument, handler} (i.e. {{argument1,handler1},{argument2,handler2},{argument3,handler3}})
--
-- all arguments are optionals, can be added later with
-- identifier 	-> :AddIdentifier(identifier)
-- aliases		-> :AddAlias(aliases)
-- arguments	-> :AddArgument(arguments)
function LSC:NewSlashCommand(identifier, aliases, arguments, noArgument, wrongArgument)
	return SlashCommand:New(identifier, aliases, arguments, noArgument, wrongArgument)
end

-- alias for LSC:NewSlashCommand(identifier, aliases, arguments, noArgument, wrongArgument)
function LSC:NewSC(identifier, aliases, arguments, noArgument, wrongArgument) 
	--LSC:NewSlashCommand(identifier, aliases, arguments, noArgument, wrongArgument)
	return SlashCommand:New(identifier, aliases, arguments, noArgument, wrongArgument)
end

-- LSC:NewSimpeSlashCommand([identifier], aliases, handler)
-- aliases		(string or table)	- words the slash command respond to (i.e /myaddon, /myadd)
--									  single string (ie "/myaddon") or table of string (ie {"/myaddon","/myadd","/addonmy"})
-- handler		(function)			- function that do the work (msg,editBox as arguments)
-- [identifier]	(string) 			- optional, unique identifier to the slash command. If omitted the addon name will be used
function LSC:NewSimpeSlashCommand(aliases, handler, identifier)
	local sc = LSC:NewSlashCommand(identifier, aliases, nil, handler, nil)
	sc:Done()
end


--[[       EXAMPLES

*************************************************************
NewSimpleSlashCommand
for when you need the slash command to do one easy task
*************************************************************

-------------------------------------------------------------
ONE COMMANDS (/testaddon) THAT DO SOMENTHING
-------------------------------------------------------------

local LSC = LibStub("LibSlashCommands-1.0")
LSC:NewSimpeSlashCommand(/testaddon", function() --do stuff here-- end)


-------------------------------------------------------------
ONE COMMAND (/testaddon and /testadd) WITH TWO ALIASES
-------------------------------------------------------------

local LSC = LibStub("LibSlashCommands-1.0")

local funcion handler()
	-- do stuff here
end
LSC:NewSimpeSlashCommand({"/testaddon","/testadd"}, handler)


-------------------------------------------------------------
TWO COMMANDS THAT DO DIFFERENT THINGS
/testaddonstart (and alias /tastart) and /testaddonstop 
-------------------------------------------------------------

local LSC = LibStub("LibSlashCommands-1.0")

local funcion handlerStart()
	print("Slash command made with LibSlashCommands-1.0")
end
local funcion handlerStop()
	print("Slash command made with LibSlashCommands-1.0")
end
LSC:NewSimpeSlashCommand({"/testaddonstart","/tastart"}, handlerStart)
LSC:NewSimpeSlashCommand("/testaddonstop", handlerStop)


*************************************************************
More structured command 
for when you need the slash command to do complex things
	with multiple arguments even
*************************************************************

local LSC = LibStub("LibSlashCommands-1.0")

local handler_one(msg, editBox)
	-- do stuff here
end
local handler_two(msg, editBox)
	-- do stuff here
end
local handler_no(msg, editBox)
	-- do stuff here
end
local handler_wrong(msg, editBox)
	-- do stuff here
end

local sc = LSC:NewSlashCommand()
sc:AddIdentifier("TestAddon") 		-- unique identifier of the slash command
sc:AddAlias("/testaddon")			-- the command(s) itself
sc:AddArgument("one", handler_one)	-- add an argument to the command (i.e /testaddon start)
sc:AddArgument("two", handler_two)	-- add another argument 		  (i.e /testaddon stop)
sc:AddNoArgument(handler_no)		-- for when the command is called without arguments
sc:AddWrongArgument(handler_wrong)  -- for when the command is called with an argument that does not exist
sc:Done()							-- all done!


*************************************************************
ACTUAL EXAMPLE
/testaddon 				open addon settings
/testaddon start 		start something in the addon
/testaddon stop 		stop something in the addon
/testaddon add 15 BR	add 15 points to the character BR
*************************************************************
local LSC = LibStub("LibSlashCommands-1.0")

local add_handler(msg, editBox)
	-- msg[1] is 15 
	-- msg[2] is BR

	--do stuff here 
end

local sc = LSC:NewSlashCommand(nil, "/testaddon")
sc:AddArgument("start", function() --start something end)
sc:AddArgument("stop", function() --stop something end)
sc:AddArgument("add", add_handler)
sc:AddNoArgument(function() --open settings end)
sc.Done()
]]