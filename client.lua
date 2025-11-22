ESX = exports['es_extended']:getSharedObject()

local isMenuOpen = false
local isPolice = false

function CheckPoliceJob()
    local playerJob = ESX.GetPlayerData().job
    if playerJob and playerJob.name then
        for _, jobName in ipairs(Config.PoliceJobs) do
            if playerJob.name == jobName then
                isPolice = true
                return
            end
        end
    end
    isPolice = false
end

function GetNearbyPlayers()
    local players = ESX.Game.GetPlayers()
    local nearbyPlayers = {}
    local playerCoords = GetEntityCoords(PlayerPedId())

    for i = 1, #players do
        local target = GetPlayerPed(players[i])
        local targetCoords = GetEntityCoords(target)
        local distance = #(playerCoords - targetCoords)

        if distance < 5.0 and players[i] ~= PlayerId() then
            table.insert(nearbyPlayers, {
                id = GetPlayerServerId(players[i]),
                name = GetPlayerName(players[i])
            })
        end
    end

    return nearbyPlayers
end

RegisterNUICallback('closeMenu', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('giveLicense', function(data, cb)
    TriggerServerEvent('j_licenseshop:giveLicense', data.playerId, data.licenseType)
    cb('ok')
end)

RegisterNUICallback('revokeLicense', function(data, cb)
    TriggerServerEvent('j_licenseshop:revokeLicense', data.playerId, data.licenseType)
    cb('ok')
end)

RegisterNUICallback('getPlayerLicenses', function(data, cb)
    TriggerServerEvent('j_licenseshop:getPlayerLicenses', data.playerId)
    cb('ok')
end)

RegisterNetEvent('j_licenseshop:receivePlayerLicenses')
AddEventHandler('j_licenseshop:receivePlayerLicenses', function(licenses)
    SendNUIMessage({
        type = 'updatePlayerLicenses',
        licenses = licenses
    })
end)

function OpenLicenseMenu()
    if isMenuOpen then return end
    isMenuOpen = true

    local players = GetNearbyPlayers()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openMenu',
        players = players,
        licenses = Config.Licenses
    })
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    CheckPoliceJob()
end)

CreateThread(function()
    CheckPoliceJob()
    while true do
        local wait = 1000
        if isPolice then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.MenuPosition)

            if distance < Config.MenuDistance then
                wait = 0
                if Config.Marker.Enabled then
                    DrawMarker(
                        Config.Marker.Type, 
                        Config.MenuPosition, 
                        0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 
                        Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, 
                        Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, Config.Marker.Color.a, 
                        false, true, 2, nil, nil, false
                    )
                end
                
                ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um das Lizenzmenü zu öffnen')

                if IsControlJustReleased(0, 38) then -- E Taste
                    OpenLicenseMenu()
                end
            end
        end
        Wait(wait)
    end
end)
