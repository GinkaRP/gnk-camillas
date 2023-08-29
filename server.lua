if Config.Framework then
    CORE = exports["es_extended"]:getSharedObject()
else
    CORE = exports["qb-core"]:GetCoreObject()
end

if Config.Framework then
        CORE.RegisterServerCallback('gnk-camillas:curar', function(source, cb)
                local xPlayer = CORE.GetPlayerFromId(source)

	        if(xPlayer.getMoney() >= 0) then
                        xPlayer.removeMoney(0)
                        cb(true)
	        else
                        cb(false)
	        end
        end)
else
        CORE.Functions.CreateCallback('gnk-camillas:curar', function(source, cb)
                local player = CORE.Functions.GetPlayer(source)
                
                if player.getMoney() >= 0 then
                    player.removeMoney(0)
                    cb(true)
                else
                    cb(false)
                end
        end)
end