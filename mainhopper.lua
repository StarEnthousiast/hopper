-- petrnghopper.lua
local placeId = _G.placeId or 16732694052  -- Use the default placeId if not set

local function hopToServer()
    -- Start with page 1 and ascending order, limit to 50 servers
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true&page=%s"
    local page = 1  -- Start from page 1
    local req = request({ Url = string.format(sfUrl, placeId, "Asc", 50, page) })
    local body = game:GetService("HttpService"):JSONDecode(req.Body)

    if body and body.data then
        local servers = {}
        for _, server in pairs(body.data) do
            -- Only consider servers with fewer than 5 players and not full
            if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) and 
               server.playing < 5 and server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end

        if #servers > 0 then
            -- Select a random server from the list of servers with fewer than 5 players
            local selectedServer = servers[math.random(1, #servers)]
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, selectedServer, game.Players.LocalPlayer)
            print("Hopping to server with fewer than 5 players: " .. selectedServer)
        else
            print("No available servers with fewer than 5 players.")
        end
    else
        print("Failed to retrieve server data.")
    end
end

-- Start hopping
hopToServer()
