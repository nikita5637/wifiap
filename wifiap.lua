#!/usr/bin/lua

local interface = "wlan0"

if (os.getenv("USER") ~= "root") then
	print("You must be root")
	return
end

local aps = {}
local cmd = "iwlist " .. interface .. " scan"

function list()
	local ap = {}
	local fd = io.popen(cmd, "r")
	local line = fd:read()
	while (line ~= nil) do
		if (string.match(line, "Cell")) then
			if ((ap.cell ~= nil) and (ap.address ~= nil) and (ap.sl ~= nil) and (ap.essid ~= nil)) then
				function ap:print()
					print(self.cell, self.address, self.channel, self.sl, self.essid)
				end
				aps[#aps + 1] = ap
				ap = {}
			end
		end

		if (string.match(line, "Cell")) then
			ap.cell = string.match(line, "Cell (%d*) -")
			ap.address = string.match(line, "Address: (.*)")
		end

		if (string.match(line, "Channel:")) then
			ap.channel = string.match(line, "Channel:(%d*)")
		end

		if (string.match(line, "Signal level=")) then
			ap.sl = string.match(line, "Signal level=(.*)")
		end

		if (string.match(line, "ESSID:")) then
			ap.essid = string.match(line, "ESSID:(.*)")
		end

		line = fd:read()
	end
	fd.close()
end

list()
table.sort(aps, function(a, b) return a.sl < b.sl end)
for i = 1, #aps do
	if (arg[1] ~= nil) then
		if (aps[i].essid == arg[1]) then
			aps[i]:print()
		end
	else
		aps[i]:print()
	end
end
