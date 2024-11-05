-- petrnghopper.lua
local placeId = _G.placeId or 16732694052  -- Use the default placeId if not set

local function hopToServer()
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local req = request({ Url = string.format(sfUrl, placeId, "Desc", 50) })
    local body = game:GetService("HttpService"):JSONDecode(req.Body)

    if body and body.data then
        local servers = {}
        for _, server in pairs(body.data) do
            if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) and 
               server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end

        if #servers > 0 then
            local selectedServer = servers[math.random(1, #servers)]
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, selectedServer, game.Players.LocalPlayer)
            print("Hopping to server: " .. selectedServer)
        else
            print("No available servers to hop to.")
        end
    else
        print("Failed to retrieve server data.")
    end
end

-- Start hopping
hopToServer()
