ESX = exports['es_extended']:getSharedObject()

function SendDiscordLog(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = color or 16711680,
            ["footer"] = {
                ["text"] = Config.ServerName .. " | " .. os.date("%Y-%m-%d %H:%M:%S")
            },
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = Config.BotName,
        embeds = embed,
        avatar_url = Config.BotAvatar
    }), { ['Content-Type'] = 'application/json' })
end

function IsPlayerCop(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    for _, jobName in ipairs(Config.PoliceJobs) do
        if xPlayer.job.name == jobName then
            return true
        end
    end
    return false
end

function HasLicense(identifier, licenseType)
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM user_licenses WHERE type = @type AND owner = @owner', {
        ['@type'] = licenseType,
        ['@owner'] = identifier
    })
    return result > 0
end

RegisterServerEvent('j_licenseshop:giveLicense')
AddEventHandler('j_licenseshop:giveLicense', function(targetId, licenseType)
    local _source = source

    if not IsPlayerCop(_source) then
        TriggerClientEvent('esx:showNotification', _source, 'Du bist kein Polizist!')
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    local xOfficer = ESX.GetPlayerFromId(_source)

    if xTarget then
        if HasLicense(xTarget.identifier, licenseType) then
            TriggerClientEvent('esx:showNotification', _source, 'Dieser Spieler hat diese Lizenz bereits!')
            return
        end

        exports.oxmysql:execute('INSERT INTO user_licenses (type, owner) VALUES (@type, @owner)', {
            ['@type'] = licenseType,
            ['@owner'] = xTarget.identifier
        }, function()
            local licenseLabel = "Unbekannt"
            for _, license in ipairs(Config.Licenses) do
                if license.Type == licenseType then
                    licenseLabel = license.Label
                    break
                end
            end

            TriggerClientEvent('esx:showNotification', _source, licenseLabel .. ' erfolgreich ausgestellt!')
            TriggerClientEvent('esx:showNotification', targetId, 'Du hast eine ' .. licenseLabel .. ' erhalten!')

            local logMessage = string.format(
                "**Polizist:** %s (ID: %s)\n**Spieler:** %s (ID: %s)\n**Lizenz:** %s",
                xOfficer.getName(), _source,
                xTarget.getName(), targetId, licenseLabel
            )
            SendDiscordLog("Lizenz ausgestellt", logMessage, 65280) -- Grün
        end)
    end
end)

RegisterServerEvent('j_licenseshop:revokeLicense')
AddEventHandler('j_licenseshop:revokeLicense', function(targetId, licenseType)
    local _source = source

    if not IsPlayerCop(_source) then
        TriggerClientEvent('esx:showNotification', _source, 'Du bist kein Polizist!')
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    local xOfficer = ESX.GetPlayerFromId(_source)

    if xTarget then
        if not HasLicense(xTarget.identifier, licenseType) then
            TriggerClientEvent('esx:showNotification', _source, 'Dieser Spieler hat diese Lizenz nicht!')
            return
        end

        exports.oxmysql:execute('DELETE FROM user_licenses WHERE type = @type AND owner = @owner', {
            ['@type'] = licenseType,
            ['@owner'] = xTarget.identifier
        }, function()
            local licenseLabel = "Unbekannt"
            for _, license in ipairs(Config.Licenses) do
                if license.Type == licenseType then
                    licenseLabel = license.Label
                    break
                end
            end

            TriggerClientEvent('esx:showNotification', _source, licenseLabel .. ' erfolgreich entzogen!')
            TriggerClientEvent('esx:showNotification', targetId, 'Dir wurde eine ' .. licenseLabel .. ' entzogen!')

            local logMessage = string.format(
                "**Polizist:** %s (ID: %s)\n**Spieler:** %s (ID: %s)\n**Lizenz:** %s",
                xOfficer.getName(), _source,
                xTarget.getName(), targetId, licenseLabel
            )
            SendDiscordLog("Lizenz entzogen", logMessage, 16711680) -- Rot
        end)
    end
end)

RegisterServerEvent('j_licenseshop:getPlayerLicenses')
AddEventHandler('j_licenseshop:getPlayerLicenses', function(targetId)
    local _source = source
    local xTarget = ESX.GetPlayerFromId(targetId)

    if xTarget then
        MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = @owner', {
            ['@owner'] = xTarget.identifier
        }, function(result)
            local playerLicenses = {}
            for i=1, #result do
                table.insert(playerLicenses, result[i].type)
            end
            TriggerClientEvent('j_licenseshop:receivePlayerLicenses', _source, playerLicenses)
        end)
    end
end)
