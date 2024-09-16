ESX = exports['es_extended']:getSharedObject()

local zones = {}

-- Funktion zum Abrufen und Erstellen der Blips
function loadZones()
    ESX.TriggerServerCallback('getSperzonen', function(data)
        for id, zone in pairs(zones) do
            RemoveBlip(zone.radiusBlip)
            RemoveBlip(zone.nameBlip)
        end
        zones = {}

        for _, zone in ipairs(data) do
            local blip = AddBlipForRadius(zone.x, zone.y, zone.z, zone.radius + 0.0)
            SetBlipColour(blip, 1)
            SetBlipAlpha(blip, 128)

            local nameBlip = AddBlipForCoord(zone.x, zone.y, zone.z)
            SetBlipSprite(nameBlip, 1)
            SetBlipScale(nameBlip, 0.0)
            SetBlipAsShortRange(nameBlip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Sperrzone: ' .. zone.name)
            EndTextCommandSetBlipName(nameBlip)

            zones[zone.id] = {
                radiusBlip = blip,
                nameBlip = nameBlip,
                x = zone.x,
                y = zone.y,
                z = zone.z,
                radius = zone.radius
            }
        end
    end)
end

-- Lade die Sperzonen beim Spielstart
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    loadZones()
end)

-- Regelmäßige Aktualisierung der Sperzonen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000) -- Alle 30 Sekunden aktualisieren
        loadZones()
    end
end)

-- Funktion zum aggressiven Entfernen von NPCs und NPC-Fahrzeugen in Sperzonen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Überprüfe jeden Frame
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, zone in pairs(zones) do
            local zoneCenter = vector3(zone.x, zone.y, zone.z)
            local extendedRadius = zone.radius + 100.0 -- Erweiterter Bereich für frühzeitiges Entfernen

            -- Verhindere das Spawnen neuer NPCs und Fahrzeuge in einem erweiterten Bereich
            ClearAreaOfPeds(zone.x, zone.y, zone.z, extendedRadius, 1)
            ClearAreaOfVehicles(zone.x, zone.y, zone.z, extendedRadius, false, false, false, false, false)
            
            -- Setze Dichte-Multiplikatoren auf 0 in der Nähe der Zone
            if #(playerCoords - zoneCenter) <= extendedRadius then
                SetPedDensityMultiplierThisFrame(0.0)
                SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
                SetVehicleDensityMultiplierThisFrame(0.0)
                SetRandomVehicleDensityMultiplierThisFrame(0.0)
                SetParkedVehicleDensityMultiplierThisFrame(0.0)
            end

            -- Entferne alle NPCs und NPC-Fahrzeuge in der Zone
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                if DoesEntityExist(ped) and not IsPedAPlayer(ped) and #(GetEntityCoords(ped) - zoneCenter) <= extendedRadius then
                    if not IsPedInAnyVehicle(ped, false) then
                        DeleteEntity(ped)
                    else
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        if DoesEntityExist(vehicle) then
                            SetEntityAsMissionEntity(vehicle, true, true)
                            DeleteVehicle(vehicle)
                        end
                        DeleteEntity(ped)
                    end
                end
            end

            -- Entferne alle verlassenen Fahrzeuge in der Zone
            local vehicles = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehicles) do
                if DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - zoneCenter) <= extendedRadius then
                    if not IsVehicleSeatFree(vehicle, -1) then
                        local driver = GetPedInVehicleSeat(vehicle, -1)
                        if not IsPedAPlayer(driver) then
                            SetEntityAsMissionEntity(vehicle, true, true)
                            DeleteVehicle(vehicle)
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('openSperzoneMenu')
AddEventHandler('openSperzoneMenu', function()
    ESX.TriggerServerCallback('getSperzonen', function(data)
        SendNUIMessage({action = 'open', zones = data})
        SetNuiFocus(true, true)
    end)
end)

RegisterNetEvent('addZone')
AddEventHandler('addZone', function(zone)
    if not zones[zone.id] then
        local blip = AddBlipForRadius(zone.x, zone.y, zone.z, zone.radius + 0.0)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 128)

        local nameBlip = AddBlipForCoord(zone.x, zone.y, zone.z)
        SetBlipSprite(nameBlip, 1)
        SetBlipScale(nameBlip, 0.0)
        SetBlipAsShortRange(nameBlip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Sperrzone: ' .. zone.name)
        EndTextCommandSetBlipName(nameBlip)

        zones[zone.id] = {
            radiusBlip = blip,
            nameBlip = nameBlip,
            x = zone.x,
            y = zone.y,
            z = zone.z,
            radius = zone.radius
        }
    end
end)

RegisterNetEvent('removeZone')
AddEventHandler('removeZone', function(id)
    if zones[id] then
        RemoveBlip(zones[id].radiusBlip)
        RemoveBlip(zones[id].nameBlip)
        zones[id] = nil
    end
end)

RegisterNUICallback('createSperzone', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent('createSperzone', data.sperzoneName, tonumber(data.sperzoneRadius), coords.x, coords.y, coords.z)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('deleteSperzone', function(data, cb)
    TriggerServerEvent('deleteSperzone', tonumber(data.id))
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)