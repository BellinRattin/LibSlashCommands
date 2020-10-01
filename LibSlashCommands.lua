-- for more info and examples check the GitHub wiki
-- https://github.com/BellinRattin/LibSlashCommands/wiki

local MAJOR, MINOR = "LibSlashCommands", 1
local LSC = LibStub:NewLibrary(MAJOR, MINOR)

if not LSC then return end

-- check if the first character of a string is / otherwise add it
local function CheckForLeadingSlash(word)
	if not (string.sub(word,1,1) == "/") then
		word = "/"..word
	end
	return word
end

-- remove leading / 
local function RemoveLeadingSlash(word)
	if (string.sub(word,1,1) == "/") then
		word = string.sub(word,2)
	end
	return word
end

local function CheckForAlreadyExistingSlashCommand(sc)
	for id, val  in pairs(_G) do
		if id:sub(1,5) == "SLASH" and val == sc then
			return true
		end
	end
	return false
end

local function GetCallerAddonName()
	return string.match(debugstack(4), '%[string "@\Interface\\AddOns\\(%S+)\\')
end

-- check if identifier exists, otherwise get it. Capitalized of course
local function CheckIdentifier(identifier, alias)
	if not identifier then
		return GetCallerAddonName():upper().."_"..RemoveLeadingSlash(alias):upper()
	else
		assert(type(identifier) == "string", "ERROR, if given, identifier must be string")
		return identifier:upper()
	end
end

-- check if aliases are of the correct type and count them
local function CheckAliases(aliases)
	local aty = type(aliases)
	assert(aliases, "ERROR, you need at least one alias")
	assert((aty == "string") or (aty == "table"), "ERROR, aliases must be string or table")

	if aty == "string" then
		return {CheckForLeadingSlash(aliases)}, 1
	else
		local t = {}
		local count = #aliases
		for i = 1,count do
			t[i] = CheckForLeadingSlash(aliases[i])
		end
		return t, count
	end
end

-- check if arguments are of the correct type and count them
local function CheckArguments(arguments)
	if not arguments then return end
	assert(type(arguments) == "table", "ERROR, arguments must be a table")
	local count = 0
	for k,v in pairs(arguments) do
		assert(((type(k) == "string") and (type(v) == "function")), "ERROR, in argument "..(count+1)..": argument must be in the format string = function")
		count = count + 1
	end
	return arguments, count
end

-- check if noArgument is of the correct type
local function CheckNoArgument(noArgument)
	if not noArgument then return end
	assert(type(noArgument) == "function", "ERROR, noArgument must be a function")
	return noArgument
end

-- check if handler is of the correct type
local function CheckHandler(handler)
	if not handler then return end
	assert(type(handler) == "function", "ERROR, handler must be a function")
	return handler
end

-- Create a new Slash Command
function LSC:NewSlashCommand(description)
	local aliases,   aliasesCount		= CheckAliases(description.aliases)
	local arguments, argumentsCount 	= CheckArguments(description.arguments)
	local noArgument 					= CheckNoArgument(description.noArgument)
	local handler						= CheckHandler(description.handler)
	local identifier 					= CheckIdentifier(description.identifier, aliases[1])
	
	for i = 1,aliasesCount do
		_G["SLASH_"..identifier..i] = aliases[i]
	end

	SlashCmdList[identifier] = function (msg, editBox)
		local others = {}
		for other in msg:gmatch("%S+") do table.insert(others, other) end

		if #others == 0 then
			handler()
		else
			if argumentsCount == 0 then
				noArgument(others, editBox)
			else
				local argument = table.remove(others, 1)
				if arguments[argument] then
					arguments[argument](others,editBox)
				else
					if noArgument then
						table.insert(others, 1, argument)
						noArgument(others,editBox)
					else
						handler()
					end
				end
			end
		end
	end
end

-- Shorter name for NewSlashCommand
function LSC:New(description)
	LSC:NewSlashCommand(description)
end

-- Create a simplified Slash Command (/command -> do something)
function LSC:NewSimpleSlashCommand(alias, handler)
	LSC:NewSlashCommand{aliases = alias, handler = handler}
end

-- Shorter name for NewSimpleSlashCommand
function LSC:NewSimple(alias, handler)
	LSC:NewSimpleSlashCommand(alias, handler)
end
