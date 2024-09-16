ESX = exports['es_extended']:getSharedObject()

-- Funktion zum Senden einer Discord-Nachricht
function sendDiscordMessage(webhookUrl, title, message)
    local embeds = {
        {
            ["color"] = 3447003, -- Blau
            ["title"] = title,
            ["description"] = message,
            ["thumbnail"] = {
                ["url"] = Config.LogoURL
            }
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({username = "Sperrzonen Bot", embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

-- Funktion zum Senden einer Benachrichtigung an alle Spieler
function notifyAllPlayers(message)
    TriggerClientEvent('esx:showNotification', -1, message)
end

RegisterCommand('sperzone', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job.name == 'police' then
        TriggerClientEvent('openSperzoneMenu', source)
    else
        TriggerClientEvent('esx:showNotification', source, 'Du hast keine Berechtigung, diesen Befehl zu verwenden.')
    end
end, false)

RegisterNetEvent('createSperzone')
AddEventHandler('createSperzone', function(name, radius, x, y, z)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifiers = GetPlayerIdentifiers(_source)
    local discord, fivem, license, license2

    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discord = id
        elseif string.find(id, "fivem:") then
            fivem = id
        elseif string.find(id, "license:") then
            license = id
        elseif string.find(id, "license2:") then
            license2 = id
        end
    end

    local playerName = xPlayer.getName()
    local discordMessage = string.format("Eine neue Sperrzone wurde von %s erstellt.\n\n**Sperrzone Informationen**\nName: %s\nRadius: %d Meter\nKoordinaten: (%.2f, %.2f, %.2f)\n\n**Player Identifiers**\nDiscord: %s\nFiveM: %s\nLicense: %s\nLicense2: %s", playerName, name, radius, x, y, z, discord or "N/A", fivem or "N/A", license or "N/A", license2 or "N/A")

    exports.oxmysql:insert('INSERT INTO sperzonen (name, radius, x, y, z) VALUES (?, ?, ?, ?, ?)', {name, radius, x, y, z}, function(id)
        if id then
            TriggerClientEvent('addZone', -1, {id = id, name = name, radius = radius, x = x, y = y, z = z})
            notifyAllPlayers('LSPD hat eine Sperrzone erichtet: ' .. name)
            sendDiscordMessage(Config.DiscordWebhooks.CreateZone, "Neue Sperrzone erstellt", discordMessage)
        else
            TriggerClientEvent('esx:showNotification', _source, 'Fehler beim Erstellen der Sperrzone.')
        end
    end)
end)

RegisterNetEvent('deleteSperzone')
AddEventHandler('deleteSperzone', function(id)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifiers = GetPlayerIdentifiers(_source)
    local discord, fivem, license, license2

    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discord = id
        elseif string.find(id, "fivem:") then
            fivem = id
        elseif string.find(id, "license:") then
            license = id
        elseif string.find(id, "license2:") then
            license2 = id
        end
    end

    local playerName = xPlayer.getName()
    exports.oxmysql:execute('SELECT name, radius, x, y, z FROM sperzonen WHERE id = ?', {id}, function(result)
        if result and #result > 0 then
            local zoneName = result[1].name
            local zoneRadius = result[1].radius
            local zoneX = result[1].x
            local zoneY = result[1].y
            local zoneZ = result[1].z
            exports.oxmysql:execute('DELETE FROM sperzonen WHERE id = ?', {id}, function(deleteResult)
                if deleteResult and deleteResult.affectedRows > 0 then
                    TriggerClientEvent('removeZone', -1, id)
                    notifyAllPlayers('LSPD hat eine Sperrzone entfernt: ' .. zoneName)
                    local discordMessage = string.format("Die Sperrzone '%s' wurde von %s entfernt.\n\n**Sperrzone Informationen**\nName: %s\nRadius: %d Meter\nKoordinaten: (%.2f, %.2f, %.2f)\n\n**Player Identifiers**\nDiscord: %s\nFiveM: %s\nLicense: %s\nLicense2: %s", zoneName, playerName, zoneName, zoneRadius, zoneX, zoneY, zoneZ, discord or "N/A", fivem or "N/A", license or "N/A", license2 or "N/A")
                    sendDiscordMessage(Config.DiscordWebhooks.DeleteZone, "Sperrzone entfernt", discordMessage)
                else
                    TriggerClientEvent('esx:showNotification', source, 'Fehler beim Löschen der Sperrzone.')
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, 'Sperrzone nicht gefunden.')
        end
    end)
end)

ESX.RegisterServerCallback('getSperzonen', function(source, cb)
    exports.oxmysql:execute('SELECT * FROM sperzonen', {}, function(results)
        cb(results)
    end)
end)

-- Stilisierte Nachricht beim Serverstart
print("^2====================================^0")
print("^2|          Clever Scripts           |^0")
print("^2|         Sperzonen Skript         |^0")
print("^2====================================^0")
