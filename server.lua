local ESX = nil
local robberyCooldowns = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('robbery:canStart', function(source, cb, locationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    -- Check cooldown
    if robberyCooldowns[playerId] ~= nil and (os.time() - robberyCooldowns[playerId]) < Config.RobberyCooldown then
        cb(false, 'You must wait before attempting another robbery')
        return
    end

    -- Check if player is already robbing
    if robberyCooldowns[playerId] ~= nil and robberyCooldowns[playerId] == true then
        cb(false, 'You are already robbing a location')
        return
    end

    cb(true)
end)

RegisterNetEvent('robbery:start')
AddEventHandler('robbery:start', function(locationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    ESX.TriggerServerCallback('robbery:canStart', source, function(canStart, message)
        if canStart then
            robberyCooldowns[playerId] = true
            TriggerClientEvent('robbery:startClient', source, locationId)

            -- Log robbery start
            MySQL.Async.execute('INSERT INTO robberies (player_id, location, start_time, success, reward) VALUES (@player_id, @location, NOW(), false, 0)', {
                ['@player_id'] = playerId,
                ['@location'] = locationId
            })
        else
            TriggerClientEvent('esx:showNotification', source, message)
        end
    end, locationId)
end)

RegisterNetEvent('robbery:end')
AddEventHandler('robbery:end', function(locationId, success)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    local reward = 0

    if success then
        local location = Config.RobberyLocations[locationId]
        reward = math.random(Config.RobberyReward.min, Config.RobberyReward.max) * location.difficulty
        xPlayer.addMoney(reward)
    end

    robberyCooldowns[playerId] = os.time()

    -- Log robbery end
    MySQL.Async.execute('UPDATE robberies SET end_time = NOW(), success = @success, reward = @reward WHERE player_id = @player_id AND location = @location AND success = false', {
        ['@player_id'] = playerId,
        ['@location'] = locationId,
        ['@success'] = success,
        ['@reward'] = reward
    })

    TriggerClientEvent('robbery:endClient', source, success)
end)

RegisterNetEvent('robbery:alertPolice')
AddEventHandler('robbery:alertPolice', function(locationId)
    local xPlayers = ESX.GetPlayers()

    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)

        if xPlayer.job.name == Config.PoliceJobName then
            TriggerClientEvent('robbery:policeAlert', playerId, locationId)
        end
    end
end)