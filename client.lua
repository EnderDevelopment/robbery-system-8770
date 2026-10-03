local ESX = nil
local isRobbing = false
local robberyLocation = nil
local robberyBlip = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, location in ipairs(Config.RobberyLocations) do
            local distance = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))

            if distance < 2.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to rob this location')

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('robbery:start', location.id)
                end
            end
        end
    end
end)

RegisterNetEvent('robbery:startClient')
AddEventHandler('robbery:startClient', function(locationId)
    local location = Config.RobberyLocations[locationId]
    robberyLocation = location
    isRobbing = true

    -- Create robbery blip
    robberyBlip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(robberyBlip, Config.RobberyBlipSprite)
    SetBlipColour(robberyBlip, Config.RobberyBlipColor)
    SetBlipScale(robberyBlip, Config.RobberyBlipScale)
    SetBlipAsShortRange(robberyBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Robbery in Progress')
    EndTextCommandSetBlipName(robberyBlip)

    -- Start robbery timer
    Citizen.CreateThread(function()
        Citizen.Wait(Config.RobberyDuration * 1000)
        if isRobbing then
            TriggerServerEvent('robbery:end', locationId, true)
        end
    end)

    -- Alert police
    Citizen.CreateThread(function()
        Citizen.Wait(Config.PoliceAlertTime * 1000)
        if isRobbing then
            TriggerServerEvent('robbery:alertPolice', locationId)
        end
    end)
end)

RegisterNetEvent('robbery:endClient')
AddEventHandler('robbery:endClient', function(success)
    isRobbing = false
    robberyLocation = nil

    -- Remove robbery blip
    if robberyBlip ~= nil then
        RemoveBlip(robberyBlip)
        robberyBlip = nil
    end

    if success then
        ESX.ShowNotification('Robbery successful!')
    else
        ESX.ShowNotification('Robbery failed!')
    end
end)

RegisterNetEvent('robbery:policeAlert')
AddEventHandler('robbery:policeAlert', function(locationId)
    local location = Config.RobberyLocations[locationId]
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))

    if distance < 50.0 then
        ESX.ShowNotification('A robbery is in progress nearby!')
    end
end)