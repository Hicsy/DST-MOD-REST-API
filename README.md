# DST-MOD-REST-API
A basic REST API mod for Don't Starve which pings a command queue server for a new command and executes it.


ModMain.lua is where the actual mod lies, the rest is boilerplate and defaults.
Basically every major game event (day/night, player join/leave...) the shard will announce it's status to the API host.
Then it regularly phones-home to see if there are any new commands pending (pull-request).
