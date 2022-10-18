local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}
local Blip = nil


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
    end)
    if not Blip then 
        Blip = AddBlipForCoord(vec3(-809.26373291016,-607.45001220703,101.27024841309))
        SetBlipSprite(Blip, 476)
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.6)
        SetBlipAsShortRange(Blip, true)
        SetBlipColour(Blip, 66)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Floky Appartment')
        EndTextCommandSetBlipName(Blip)
    end
end)

CreateThread(function()
    Blip = AddBlipForCoord(vec3(-809.26373291016,-607.45001220703,101.27024841309))
    SetBlipSprite(Blip, 476)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 0.6)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, 66)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Floky Appartment')
    EndTextCommandSetBlipName(Blip)
    Wait(1000)
    for k, v in pairs(Config.Towers) do 
        Citizen.Wait(50)
        exports["qb-target"]:AddBoxZone("flokyappartmenttower"..v.name, v.coords, v.info1, v.info2, {
            name= "flokyappartmenttower"..v.name,
            heading= v.heading,
            debugPoly = v.debugPoly,
            minZ= v.minZ,
            maxZ= v.maxZ
            }, {
            options = {
                {
                    event = 'floky-appartment:client:lobbymenu',
                    icon = "far fa-clipboard",
                    label = "Interaction",
                    params = {
                        Tower = k
                    },
                },
            },
            job = {"all"},
            distance = 2.0
        })
    end
    for k, v in pairs(Config.Appartment) do 
        Citizen.Wait(50)
        exports["qb-target"]:AddBoxZone("flokyappartmentdoor"..k, v.Door.coords, v.Door.info1, v.Door.info2, {
            name= "flokyappartmentdoor"..k,
            heading= v.Door.heading,
            debugPoly = v.Door.debugPoly,
            minZ= v.Door.minZ,
            maxZ= v.Door.maxZ
            }, {
            options = {
                {
                    event = 'floky-appartment:client:tpOut',
                    icon = "far fa-clipboard",
                    label = "Door",
                    params = {
                        TpTo = v.TpFrom,
                        hFrom = v.hFrom
                    },
                },
            },
            job = {"all"},
            distance = 2.0
        })
        Wait(100)
        exports["qb-target"]:AddBoxZone("flokyappartmentdoorm"..k, v.DoorM.coords, v.DoorM.info1, v.DoorM.info2, {
            name= "flokyappartmentdoorm"..k,
            heading= v.DoorM.heading,
            debugPoly = v.DoorM.debugPoly,
            minZ= v.DoorM.minZ,
            maxZ= v.DoorM.maxZ
            }, {
            options = {
                {
                    event = 'floky-appartment:client:mPassword',
                    icon = "far fa-clipboard",
                    label = "Password",
                    params = {
                        Owner = v.Owner,
                        AppartmentID = v.AppartmentID
                    },
                },
                {
                    event = 'floky-appartment:client:allowvisit',
                    icon = "far fa-clipboard",
                    label = "Open door for visitor",
                    params = {
                        Owner = v.Owner,
                        AppartmentID = v.AppartmentID
                    },
                },
            },
            job = {"all"},
            distance = 2.0
        })
        Wait(100)
        exports["qb-target"]:AddBoxZone("flokyappartmentStash"..k, v.Stash.coords, v.Stash.info1, v.Stash.info2, {
            name= "flokyappartmentdoorm"..k,
            heading= v.Stash.heading,
            debugPoly = v.Stash.debugPoly,
            minZ= v.Stash.minZ,
            maxZ= v.Stash.maxZ
            }, {
            options = {
                {
                    event = 'floky-appartment:client:Stash',
                    icon = "far fa-clipboard",
                    label = "Stash",
                    params = {
                        AppartmentID = v.AppartmentID
                    },
                },
            },
            job = {"all"},
            distance = 2.0
        })

        local appartarea = BoxZone:Create(v.VisiPoly.coords, v.VisiPoly.info1, v.VisiPoly.info2, {
            name="appartarea"..v.AppartmentID,
            heading=v.VisiPoly.heading,
            --debugPoly=true,
            minZ=v.VisiPoly.minZ,
            maxZ=v.VisiPoly.maxZ,
        })
        appartarea:onPlayerInOut(function(isPointInside)
            if isPointInside then
                TriggerServerEvent('floky-appartment:server:rashidshit', true, v.AppartmentID)
            else
                TriggerServerEvent('floky-appartment:server:rashidshit', false, v.AppartmentID)
            end
        end)
    end
end)

RegisterNetEvent('floky-appartment:client:allowvisit', function(data)
    if not data then return end
    if not Config.Appartment[data.params.AppartmentID] then return end
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
        local amount = 0
        for k, v in pairs(Config.Appartment[data.params.AppartmentID].Rings) do 
            amount = amount + 1
        end
        if amount > 0 then 
            local menu = {}
            for k, v in pairs(Config.Appartment[data.params.AppartmentID].Rings) do 
                menu[#menu + 1] = {
                    header = "Visitor ",
                    txt = "Name: "..v.name.."",
                    params = {
                        isServer = true,
                        event = "floky-appartment:server:allowvisit",
                        args = {
                            AppartmentID = data.params.AppartmentID,
                            visitor = v.cid,
                            checkDis = Config.Appartment[data.params.AppartmentID].TpFrom
                        }
                    }
                }
            end
            if #menu <= 0 then 
                return 
            end
            exports['qb-menu']:openMenu(menu)
        else
            QBCore.Functions.Notify('No one has ringed the door', 'error', 7500)
        end
    end)
end)

RegisterNetEvent('floky-appartment:client:ringdoorBill', function()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
end)

RegisterNetEvent('floky-appartment:server:allowvisitsec', function(AppartmentID)
    if not Config.Appartment[AppartmentID] then return end
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), Config.Appartment[AppartmentID].TpTo)
    SetEntityHeading(PlayerPedId(), Config.Appartment[AppartmentID].hTo)
    Wait(500)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('floky-appartment:client:lobbysecmenu', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    local cid = PlayerData.citizenid
    if not data then return end
    local menu = {}
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
        if data.action == 1 then 
            for k, v in pairs(Config.Appartment) do 
                if v.Tower == data.Tower then 
                    if v.isOwned then 
                        menu[#menu + 1] = {
                            header = "Appartment ",
                            txt = "Appartment #: "..v.AppartmentID.."",
                            params = {
                                isServer = false,
                                event = "floky-appartment:client:enterappartment",
                                args = {
                                    AppartmentID = v.AppartmentID
                                }
                            }
                        }
                    end
                end
            end
            if #menu <= 0 then 
                QBCore.Functions.Notify('All appartment have been rented', 'error', 7500)
                return 
            end
            exports['qb-menu']:openMenu(menu)
        elseif data.action == 2 then 
            for k, v in pairs(Config.Appartment) do 
                if v.Tower == data.Tower then 
                    if v.isOwned then 
                        menu[#menu + 1] = {
                            header = "Appartment ",
                            txt = "Appartment #: "..v.AppartmentID.."",
                            params = {
                                isServer = false,
                                event = "floky-appartment:client:ringdooe",
                                args = {
                                    AppartmentID = v.AppartmentID
                                }
                            }
                        }
                    end
                end
            end
            if #menu <= 0 then 
                QBCore.Functions.Notify('All appartment have been rented', 'error', 7500)
                return 
            end
            exports['qb-menu']:openMenu(menu)
        end
    end)
end)

RegisterNetEvent('floky-appartment:client:ringdooe', function(data)
    if not data then return end
    if not Config.Appartment[data.AppartmentID] then return end
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
        local amount = 0
        for k, v in pairs(Config.Appartment[data.AppartmentID].inAppartAmount) do 
            amount = amount + 1
        end
        if amount > 0 then 
            TriggerServerEvent('floky-appartment:server:ringdooe', data.AppartmentID)
        else
            QBCore.Functions.Notify('No one in this appartment', 'error', 7500)
        end
    end)
end)

RegisterNetEvent('floky-appartment:client:Stash', function(data)
    if not data then return end
    if not Config.Appartment[data.params.AppartmentID] then return end
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "floky_appartment"..data.params.AppartmentID, {
        maxweight = 2000000,
        slots = 30,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "floky_appartment"..data.params.AppartmentID)
end)

RegisterNetEvent('floky-appartment:client:mPassword', function(data)
    if not data then return end
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
        if not Config.Appartment[data.params.AppartmentID] then return end
        PlayerData = QBCore.Functions.GetPlayerData()
        local cid = PlayerData.citizenid
        if Config.Appartment[data.params.AppartmentID].Owner == cid then 
            local dialog = exports['qb-input']:ShowInput({
                header = "Password",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Please enter password", -- text you want to be displayed as a place holder
                        name = "password", -- name of the input should be unique otherwise it might override
                        type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                        isRequired = true -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                    },
                },
            })
        
            if dialog ~= nil then
                if dialog.password and tonumber(dialog.password) > 0 then 
                    local appInfo = {
                        AppartmentID = data.params.AppartmentID,
                        pasword = tonumber(dialog.password),
                        owner = cid
                    }
                    TriggerServerEvent('floky-appartment:server:mPassword', appInfo)
                else
                    QBCore.Functions.Notify("Wrong Password", "error", 3500)
                end
            end
        else
            QBCore.Functions.Notify("You are not the owner", "error", 3500)
        end
    end)
end)

RegisterNetEvent('floky-appartment:client:tpOut', function(data)
    if not data then return end
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), data.params.TpTo)
    SetEntityHeading(PlayerPedId(), data.params.hFrom)
    Wait(500)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('floky-appartment:client:lobbymenu', function(data)
    exports['qb-menu']:openMenu({
        {
            header = "Appartment",
            isMenuHeader = true, -- Set to true to make a nonclickable title
        },
        {
            header = "Enter",
            txt = "Enter owned appartment",
            params = {
                event = "floky-appartment:client:lobbysecmenu",
                args = {
                    action = 1,
                    Tower = data.params.Tower
                }
            }
        },
        {
            header = "Visit",
            txt = "Visit appartment",
            params = {
                event = "floky-appartment:client:lobbysecmenu",
                args = {
                    action = 2,
                    Tower = data.params.Tower
                }
            }
        },
    })
end)

RegisterNetEvent('floky-appartment:client:enterappartment', function(data)
    if not data then return end
    if not Config.Appartment[data.AppartmentID] then return end
    local dialog = exports['qb-input']:ShowInput({
        header = "Password",
        submitText = "Submit",
        inputs = {
            {
                text = "Please enter password", -- text you want to be displayed as a place holder
                name = "password", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        },
    })

    if dialog ~= nil then
        if dialog.password and tonumber(dialog.password) == Config.Appartment[data.AppartmentID].Password then 
            DoScreenFadeOut(500)
            Wait(500)
            SetEntityCoords(PlayerPedId(), Config.Appartment[data.AppartmentID].TpTo)
            SetEntityHeading(PlayerPedId(), Config.Appartment[data.AppartmentID].hTo)
            Wait(500)
            DoScreenFadeIn(500)
        else
            QBCore.Functions.Notify("Wrong Password", "error", 3500)
        end
    end
end)

RegisterNetEvent('floky-appartment:client:menu', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    local cid = PlayerData.citizenid
    local menu = {}
    QBCore.Functions.TriggerCallback('floky-appartment:GetConfig', function(GG)
        Config = GG
        for k, v in pairs(Config.Appartment) do 
            if not v.isOwned then 
                menu[#menu + 1] = {
                    header = "Appartment "..k.."",
                    txt = "Tower: "..v.Tower.."<br>Buy this appartment for "..Config.Price.." $",
                    params = {
                        isServer = true,
                        event = "floky-appartment:server:Buy",
                        args = {
                            AppartmentID = v.AppartmentID
                        }
                    }
                }
            end
        end
        if #menu <= 0 then 
            QBCore.Functions.Notify('All appartment have been rented', 'error', 7500)
            return 
        end
        exports['qb-menu']:openMenu(menu)
    end)
end)

