local _G = GLOBAL
local TheNet = _G.TheNet
local TheSim = _G.TheSim
local TheShard = _G.TheShard
local loadstring = _G.loadstring
local pcall = _G.pcall
local assert = _G.assert
-- Get/Set fEnv is Lua 5.1 specific!
print("Lua version: " .. _G._VERSION)
local setfenv = _G.setfenv
local getfenv = _G.getfenv


if TheNet and TheNet:GetIsServer() then	
	local SHARD_ID = TheShard:GetShardId()
	local SERVER_NAME = TheNet:GetDefaultServerName()
	local SERVER_DESCRIPTION = TheNet:GetDefaultServerDescription()
	local SERVER_MAXPLAYERS = TheNet:GetDefaultMaxPlayers()
	local SERVER_GAMEMODE = TheNet:GetDefaultGameMode()
	local SERVER_DEDICATED = TheNet:GetServerIsDedicated()
	local SERVER_PASSWORDED = TheNet:GetServerHasPassword()
	local SERVER_PVP = TheNet:GetDefaultPvpSetting()
	local SERVER_FO = TheNet:GetDefaultFriendsOnlyServer() 
	local SERVER_MODS = TheNet:GetServerModsEnabled()
	local SERVER_CLANID = TheNet:GetServerClanID()
	local SERVER_CLANONLY = TheNet:GetServerClanOnly()
	local SERVER_PASSWORD = TheNet:GetDefaultServerPassword()
	local SERVER_MODSLIST = TheNet:GetServerModNames()
	
	local CONFIG_APIURL = GetModConfigData("API_Server")
	local CONFIG_SENDSTATUS = GetModConfigData("Send_Status")
	local CONFIG_SENDSTATUS_FREQUENCY = GetModConfigData("Send_Status_Frequency")
	--local CONFIG_APIGETURL = GetModConfigData("API_GET_URL")
	local CONFIG_GETCOMMANDS = GetModConfigData("Get_Commands")
	local CONFIG_GETCOMMANDS_FREQUENCY = GetModConfigData("Get_Commands_Frequency")
	local CONFIG_SENDPASSWORD = GetModConfigData("Send_Password")


	-- Encoding pointers: https://docs.coronalabs.com/tutorial/data/encodeURL/index.html
	local APIURL_STATUS = CONFIG_APIURL .. "/servers/" .. SERVER_NAME:gsub(" ","%%20") .. "/" .. SHARD_ID
	local APIURL_COMMANDS = APIURL_STATUS .. "/commands"
	local APIFILE_PATH = "commands.lua"

	
	local function ApiRefresh()
		apiFile_commands = _G.kleiloadlua(MODROOT .. APIFILE_PATH)
		--modimport(APIFILE_PATH)
		--apiCmd = {}
		if apiFile_commands then
			setfenv(apiFile_commands, getfenv(0))
			--_G.setfenv(apiFile_commands, apiCmd)
			--_G.setmetatable(apiCmd, {__index = _G})
			pcall(apiFile_commands)
		end
	end
	ApiRefresh()

	-- For declaring global commands that the console will recognise.
	-- from "Show Me" id=666155465
	local GetGlobal=function(gname,default)
		local res=_G.rawget(_G,gname)
		if default and not res then
			_G.rawset(_G,gname,default)
			return false
		else
			return res
		end
	end


	local function BuildReport()
		local data = {}
		local settings = {}
		local players = {}
		local statevars = {}
		local world = {}

		settings["name"] = SERVER_NAME
		settings["description"] = SERVER_DESCRIPTION
		settings["maxplayers"] = SERVER_MAXPLAYERS
		settings["gamemode"] = SERVER_GAMEMODE
		settings["dedicated"] = SERVER_DEDICATED
		settings["passworded"] = SERVER_PASSWORDED
		settings["pvp"] = SERVER_PVP
		settings["friendsonly"] = SERVER_FO
		settings["mods"] = SERVER_MODS
		settings["clanid"] = SERVER_CLANID
		settings["clanonly"] = SERVER_CLANONLY
		settings["adminonline"] = TheNet:GetServerHasPresentAdmin()
		settings["session"] = TheNet:GetSessionIdentifier()
		
		if CONFIG_SENDPASSWORD == true then
			settings["password"] = SERVER_PASSWORD
		end
		
		n = 1
		for i, v in ipairs(TheNet:GetClientTable()) do
			players[n] = {}
			players[n]["name"] = v.name
			players[n]["prefab"] = v.prefab
			players[n]["age"] = v.playerage
			
			if v.steamid == nil or v.steamid == '' then
				players[n]["steamid"] = v.netid
			else
				players[n]["steamid"] = v.steamid
			end
			
			players[n]["userid"] = v.userid
			players[n]["admin"] = v.admin
			n = n+1
		end
		
		for k, v in pairs(_G.TheWorld.state) do
			statevars[k] = v
		end
		
		if _G.TheWorld.topology.overrides ~= nil then
			world["overrides"] = {}
		
			if _G.TheWorld.topology.overrides.original.preset ~= nil then
				world["preset"] = _G.TheWorld.topology.overrides.original.preset
			end
			
			if _G.TheWorld.topology.overrides.original.tweak ~= nil then
				for k, v in pairs( _G.TheWorld.topology.overrides.original.tweak ) do
					world["overrides"][k] = {}
					for l, b in pairs( v ) do
						world["overrides"][k][l] = b
					end
				end
			end
		else
			world = "unknown"
		end
		
		data["settings"] = settings
		data["mods"] = SERVER_MODSLIST
		data["world"] = world
		data["statevars"] = statevars
		data["players"] = players	
		
		--- As per scripts\json.lua: encode() is not json compliant, only use encode_compliant()
		data = _G.json.encode_compliant(data)

		return data
	end


	-------------
	-- I "suspect" async HTTP queries are handled like this:
	-- TheSim:QueryServer(URL, function(...) MyCallback(...) end, "GET")
	-- TheSim:QueryServer(URL, function(...) self:MyCallback(...) end, "POST", DATA)
	-- function EmailSignupScreen:OnPostComplete( result, isSuccessful, resultCode )
	-------------

	-- Generic Callback when posting a message to an external host:
	local function onStatusResponse(response, isSuccessful, resultCode)
		if isSuccessful and string.len(response) > 0 and resultCode == 200 then
			local result = "Successful POST"
		else
			local result = "POST Failed."
			--print("Failed to announce status ["..resultcode.."] response")
		end
	end

	-- Helper function
	local function fix_web_string(text)
		if type(text) ~= "string" then
			text = tostring(text)
		end
		text = string.gsub(tostring(text), "\\r\\n", "\\n")
		return text
	end

	-- PUT status
	local function SendStatus(inst, source)
		data = BuildReport()
		TheSim:QueryServer(
			APIURL_STATUS,
			function(...) onStatusResponse(...) end,
			"POST",
			data
		)
	end

	-- Execute Remote-Commands
	local function enactRPC(cmd)
		response = {}
		-- access the data via: cmd.id , cmd.command , cmd.result
		print("Processing RPC ID: " .. cmd.id .. " - Instruction: >> " .. cmd.command)
		-- start
		if cmd.command == "start" then
			response["status"] = "OK"
		elseif cmd.command == "test" then
			response["status"] = "OK"
		else
			-- Risky: _G.loadstring(cmd.command)()
			--loadstring("apiCmd."2 .. cmd.command)()
			myCmd = loadstring(cmd.command)
			--_G.setfenv(myCmd, getfenv(1))
			if pcall(myCmd) then
				response["status"] = "OK"
			else
				response["status"] = "FAIL"
			end
		end
		-- send response
		TheSim:QueryServer(
			APIURL_COMMANDS .. "/" .. cmd.id ,
			function(...) onStatusResponse(...) end,
			"POST",
			_G.json.encode_compliant(response)
		)
	end

	-- Get pending commands from external repo
	-- recieves: {"commands": [{"id": 0, "command": "start", "result": null}, {"id": 3, "command": "revive", "result": null}]}	
	local function onCommandsResponse(response, isSuccessful, resultCode)
		if isSuccessful and string.len(response) > 0 and resultCode == 200 then
			response = fix_web_string(response)
			print("New Commands... Raw data: " .. response)
			data = _G.json.decode(response)
			-- access: data["commands"][1..#]["command"]
			-- print(data.commands[1]["command"])
			for index,cmd in pairs(data.commands) do
				-- TODO: add the ID to a list (and call enactRPC) only if it's not already on there.
				enactRPC(cmd)
			end
		end
	end

	-- Noisy function!
	local function getCommandsQuery(inst, source)
		TheSim:QueryServer(
					APIURL_COMMANDS .. "?status=New",
					function(...) onCommandsResponse(...) end,
					"GET"
				)
	end

	----------------
	local function Console_Put()
		SendStatus(nil, "command")
	end
	GetGlobal("api_announce", Console_Put)

	local function Console_Get()
		getCommandsQuery(nil, "command")
	end
	GetGlobal("api_getcmd", Console_Get)

	local function Console_Refresh()
		pcall(ApiRefresh)
	end
	GetGlobal("api_refresh", Console_Refresh)
	--------------

	-- https://forums.kleientertainment.com/forums/topic/66075-world-gen-data-and-mod-changes/
	AddPrefabPostInit("world", function(inst)
		inst:ListenForEvent("phasechanged", function(inst) SendStatus(inst, "phasechanged") end)
		inst:ListenForEvent("ms_playerjoined", function(inst) SendStatus(inst, "ms_playerjoined") end)
		inst:ListenForEvent("ms_playerleft", function(inst) SendStatus(inst, "ms_playerleft") end)
		inst:DoPeriodicTask(CONFIG_SENDSTATUS_FREQUENCY, function(inst) SendStatus(inst, "schedule") end)
		inst:DoPeriodicTask(CONFIG_GETCOMMANDS_FREQUENCY, function(inst) getCommandsQuery(inst, "schedule") end)
	end)

	
end