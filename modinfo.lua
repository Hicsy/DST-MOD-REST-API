name = "REST API"
description = "Get pending inbound Commands, and Send server status to a remote web server periodically."
author = "Hicsy (Jack'lul v1.2.4)"
version = "0.02"
api_version = 10
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
client_only_mod = false
all_clients_require_mod = false
server_filter_tags = {"api"}

configuration_options = {
	{
		name = "API_Server",
		label = "API Server",
		hover = "Set API Server in modoverrides.lua after hitting \"APPLY\"",
		options =
		{
			{description = "modoverrides.lua", data = "http://127.0.0.1:8080", hover = "default: \"http://127.0.0.1:8080\""}
		},
		default = "http://127.0.0.1:8080"
	},
	{
		name = "Send_Status",
		label = "Send status",
		hover = "Regularly send server status updates?",
		options =
		{
			{description = "Yes", data = true},
			{description = "No", data = false}
		},
		default = true
	},
	{
		name = "Send_Status_Frequency",
		label = "Freq: Status-Announce (seconds)",
		hover = "Set frequency in modoverrides.lua after hitting \"APPLY\"",
		options =
		{
			{description = "modoverrides.lua", data = 60, hover = "default: 60  [seconds]"}
		},
		default = 60
	},
	--[[{
		name = "API_GET_URL",
		label = "API \"GET\" URL",
		hover = "[optional] Override this in modoverrides.lua",
		options =
		{
			{description = "modoverrides.lua", data = ""},
		},
		default = "/commands",
	},--]]
	{
		name = "Get_Commands",
		label = "Get Remote Commands",
		hover = "Regularly check for pending external commands?",
		options =
		{
			{description = "Yes", data = true},
			{description = "No", data = false}
		},
		default = true
	},
	{
		name = "Get_Commands_Frequency",
		label = "Freq: Check New Commands (s)",
		hover = "Set frequency in modoverrides.lua after hitting \"APPLY\"",
		options =
		{
			{description = "modoverrides.lua", data = 3, hover = "default: 3  [seconds]"}
		},
		default = 3
	},
	--[[
	{
		name = "Commands_Use_Whitelist",
		label = "Commands: Use Whitelist",
		hover = "Execute commands from the whitelist.",
		options =
		{
			{description = "Yes", data = true, hover = "Add any functions to commands.lua in mod's dir."},
			{description = "No", data = false, hover = "Add any functions to commands.lua in mod's dir."}
		},
		default = true
	},
	]]
	{
		name = "Send_Password",
		label = "Send Password",
		hover = "Send server password with the status data?",
		options =
		{
			{description = "Yes", data = true},
			{description = "No", data = false}
		},
		default = false
	}
}