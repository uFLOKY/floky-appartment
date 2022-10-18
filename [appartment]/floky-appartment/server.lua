local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('playerDropped', function(reason)
    local src = source
    for k, v in pairs(Config.Appartment) do 
        if v.inAppartAmount[src] then 
            v.inAppartAmount[src] = nil
        end
    end
end)

CreateThread(function()
    Wait(1000)
    exports['oxmysql']:execute("SELECT * FROM `flokyappartment`", function(result)
        if not result then return end
		for k, v in pairs(result) do 
			if result[k].isowned == 1 then
                local name = json.decode(result[k].ownername)
                Config.Appartment[result[k].id].isOwned = true 
                Config.Appartment[result[k].id].Owner = result[k].owner
                Config.Appartment[result[k].id].OwnerName = ""..name.firstname.." "..name.lastname..""
                Config.Appartment[result[k].id].Password = tonumber(result[k].password)
			end
		end
	end)
end)

QBCore.Functions.CreateCallback('floky-appartment:GetConfig', function(source, cb)
	cb(Config)
end)

RegisterNetEvent('floky-appartment:server:Buy', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid 
    local isAppartOwner = false 

    for k, v in pairs(Config.Appartment) do 
        if v.Owner == cid then 
            isAppartOwner = true 
            break 
        end
    end
    if not isAppartOwner then 
        if not Config.Appartment[data.AppartmentID].isOwned then 
            local bank = Player.PlayerData.money.bank 
            if bank then 
                if tonumber(bank) >= Config.Price then 
                    if Player.Functions.RemoveMoney('bank', Config.Price) then 
                        local name = {
                            firstname = Player.PlayerData.charinfo.firstname,
                            lastname = Player.PlayerData.charinfo.lastname,
                        }
                        exports['oxmysql']:execute("INSERT INTO `flokyappartment` (`id`, `isowned`, `owner`, `password`, `ownername`) VALUES ('"..Config.Appartment[data.AppartmentID].AppartmentID.."', '1', '"..Player.PlayerData.citizenid.."', '"..Config.Appartment[data.AppartmentID].Password.."', '"..json.encode(name).."')")
                        Config.Appartment[data.AppartmentID].isOwned = true 
                        Config.Appartment[data.AppartmentID].Owner = cid
                        Config.Appartment[data.AppartmentID].OwnerName = ""..name.firstname.." "..name.lastname..""
                        TriggerClientEvent("QBCore:Notify", src, 'You have purchased apartment # '..data.AppartmentID..' tower # '..Config.Appartment[data.AppartmentID].Tower..' your apartment password is 1234', 'success', 7500)
                    else
                        TriggerClientEvent("QBCore:Notify", src, 'You don\'t have money you noob', 'error', 7500)
                    end
                else
                    TriggerClientEvent("QBCore:Notify", src, 'You don\'t have money you noob', 'error', 7500)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, 'You don\'t have money you noob', 'error', 7500)
            end
        else
            TriggerClientEvent("QBCore:Notify", src, 'This appartment is already owned', 'error', 7500)
        end
    else
        TriggerClientEvent("QBCore:Notify", src, 'You can\'t have more than one appartment', 'error', 7500)
    end
end)

RegisterNetEvent('floky-appartment:server:mPassword', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid 
    if not data then return end 
    if cid and (Config.Appartment[data.AppartmentID].Owner == cid) then 
		exports['oxmysql']:execute("SELECT * FROM `flokyappartment`  WHERE `id` = '"..data.AppartmentID.."'", function(result)
			if result[1] ~= nil then
				exports['oxmysql']:execute("UPDATE `flokyappartment` SET `password` = '"..data.pasword.."' WHERE `id` = '"..data.AppartmentID.."'")
				Config.Appartment[data.AppartmentID].Password = tonumber(data.pasword)
				TriggerClientEvent("QBCore:Notify", src, 'You have changed your appartment password', 'success', 7500)
			end
		end)
	end
end)

RegisterNetEvent('floky-appartment:server:rashidshit', function(bool, ID)
    local src = source
    if not Config.Appartment[ID] then return end
    if bool then 
        Config.Appartment[ID].inAppartAmount[src] = src
    else
        if Config.Appartment[ID].inAppartAmount[src] then 
            Config.Appartment[ID].inAppartAmount[src] = nil 
        end
    end
end)

RegisterNetEvent('floky-appartment:server:ringdooe', function(ID)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid 
    if not Config.Appartment[ID] then return end
    if Config.Appartment[ID].Rings[cid] then return end
    Config.Appartment[ID].Rings[cid] = {
        cid = cid,
        name = ''..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname..''
    }
    TriggerClientEvent("QBCore:Notify", src, 'You have ringed the door', 'success', 7500)
    for k, v in pairs(Config.Appartment[ID].inAppartAmount) do 
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then 
            Wait(50)
            TriggerClientEvent('floky-appartment:client:ringdoorBill', Player.PlayerData.source)
        end
    end
end)

RegisterNetEvent('floky-appartment:server:allowvisit', function(data)
    local src = source
	local Player = QBCore.Functions.GetPlayerByCitizenId(data.visitor)
    if not Config.Appartment[data.AppartmentID] then return end
    if Player then 
        local coords = GetEntityCoords(GetPlayerPed(Player.PlayerData.source))
        if #(coords - data.checkDis) <= 7 then 
            TriggerClientEvent('floky-appartment:server:allowvisitsec', Player.PlayerData.source, data.AppartmentID, data.checkDis)
            Config.Appartment[data.AppartmentID].Rings[data.visitor] = nil
        else
            TriggerClientEvent("QBCore:Notify", src, 'Visitor is away form appartment', 'error', 7500)
            Config.Appartment[data.AppartmentID].Rings[data.visitor] = nil
        end
    else
        TriggerClientEvent("QBCore:Notify", src, 'Visitor is away form appartment', 'error', 7500)
        Config.Appartment[data.AppartmentID].Rings[data.visitor] = nil
    end
end)


QBCore.Commands.Add('appart', 'Check if you have appartment', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid 
    for k, v in pairs(Config.Appartment) do 
        if v.Owner == cid then 
            TriggerClientEvent("QBCore:Notify", src, 'You have appartment # '..v.AppartmentID..' Tower #'..v.Tower..'', 'success', 7500)
            break
        end
    end
end)

QBCore.Commands.Add('appartpass', 'Check your appartment password', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid 
    for k, v in pairs(Config.Appartment) do 
        if v.Owner == cid then 
            TriggerClientEvent("QBCore:Notify", src, 'Yout appartment password is '..v.Password..'', 'success', 7500)
            break
        end
    end
end)