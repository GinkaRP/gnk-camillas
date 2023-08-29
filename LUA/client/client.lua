if Config.Framework then
    CORE = exports["es_extended"]:getSharedObject()
else
    CORE = exports["qb-core"]:GetCoreObject()
end

local tumbado_sentado = false
local menu_abierto = false

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5)

        for i=1, #Config.Camillas do
            local camillaID   = Config.Camillas[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)

            if distance < 1.5 and tumbado_sentado == false and menu_abierto == false then
                    ShowFloatingHelpNotification("Pulsa ~y~E~s~ para interactuar", vector3(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z))
                if IsControlJustReleased(0, 38) then
                    AbrirMenuCamillas()
                end
            end
        end
    end
end)

----- Menu
function AbrirMenuCamillas()
    CORE.UI.Menu.CloseAll()

    menu_abierto = true
    CORE.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_bads', {
		title    = ('Camilas hospital'),
		align    = 'bottom-right',
		elements = {
			{label = ('Tumbarse en la camilla boca arriba'), value = 'tumbarse_arriba'},
            {label = ('Tumbarse en la camilla boca abajo'), value = 'tumbarse_abajo'},
            {label = ('Sentarse en la camilla'), value = 'sentarse'},
		}
    }, 

    function(data, menu)
        if data.current.value == 'tumbarse_arriba' then       
                CORE.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'menu',
                    {
                        title    = ('¿Estás seguro?'),
                        elements = {
                            {label = ('Si'), value = 'yes'},
                            { label = ('No'), value = 'no'}
                        }
                    },
                    function(data, menu)
                        if data.current.value == 'yes' then
                            for i=1, #Config.Camillas do
                                local camillaID   = Config.Camillas[i]
                                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)
                                if distance < 1.5 and tumbado_sentado == false then
                                    tumbarseBocaArriba(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, camillaID.heading, camillaID)
                                    CORE.UI.Menu.CloseAll()
                                end
                            end
                        else
                            CORE.UI.Menu.CloseAll()
                        end
                    end,function(data, menu)
                    CORE.UI.Menu.CloseAll()
                end)
        elseif data.current.value == 'tumbarse_abajo' then
            CORE.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'menu',
                {
                    title    = ('¿Estás seguro?'),
                    elements = {
                        {label = ('Si'), value = 'yes'},
                        { label = ('No'), value = 'no'}
                    }
                },
                function(data, menu)
                    if data.current.value == 'yes' then
                        for i=1, #Config.Camillas do
                            local camillaID   = Config.Camillas[i]
                            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)
                            if distance < 1.5 and tumbado_sentado == false then
                                tumbarseBocaAbajo(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, camillaID.heading, camillaID)
                                CORE.UI.Menu.CloseAll()
                            end
                        end
                    else
                        CORE.UI.Menu.CloseAll()
                    end
                end,function(data, menu)
                CORE.UI.Menu.CloseAll()
            end)
        elseif data.current.value == 'sentarse' then
            CORE.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'menu',
                {
                    title    = ('¿Estás seguro?'),
                    elements = {
                        {label = ('Si'), value = 'yes'},
                        { label = ('No'), value = 'no'}
                    }
                },
                function(data, menu)
                    if data.current.value == 'yes' then
                        for i=1, #Config.Camillas do
                            local camillaID   = Config.Camillas[i]
                            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)
                            if distance < 1.5 and tumbado_sentado == false then
                                sentarse(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, camillaID.heading, camillaID)
                                CORE.UI.Menu.CloseAll()
                            end
                        end
                    else
                        CORE.UI.Menu.CloseAll()
                    end
                end,function(data, menu)
                CORE.UI.Menu.CloseAll()
            end)
        end
    end,function(data, menu)
		CORE.UI.Menu.CloseAll()
    end)
    menu_abierto = false
end

function tumbarseBocaArriba(x, y, z, heading)
    SetEntityCoords(PlayerPedId(), x, y, z + 0.3)
    RequestAnimDict('anim@gangops@morgue@table@')
    while not HasAnimDictLoaded('anim@gangops@morgue@table@') do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), 'anim@gangops@morgue@table@' , 'body_search' ,8.0, -8.0, -1, 1, 0, false, false, false )

    SetEntityHeading(PlayerPedId(), heading + 180.0)

    tumbado_sentado = true

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if tumbado_sentado == true then
                DrawSub('Pulsa ~g~H~w~ para levantarte')
                if IsControlJustReleased(0, 74) then
                    ClearPedTasks(PlayerPedId())
                    FreezeEntityPosition(PlayerPedId(), false)
                    SetEntityCoords(PlayerPedId(), x + 1.3, y, z)
                    tumbado_sentado = false 
                end
            end
        end
    end)
end

function tumbarseBocaAbajo(x, y, z, heading)
    SetEntityCoords(PlayerPedId(), x, y, z + 0.3)
    RequestAnimDict('missfbi3_sniping')
    while not HasAnimDictLoaded('missfbi3_sniping') do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), 'missfbi3_sniping' , 'prone_dave' ,8.0, -8.0, -1, 1, 0, false, false, false )

    SetEntityHeading(PlayerPedId(), heading)

    tumbado_sentado = true

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if tumbado_sentado == true then
                DrawSub('Pulsa ~g~H~w~ para levantarte')
                if IsControlJustReleased(0, 74) then
                    ClearPedTasks(PlayerPedId())
                    FreezeEntityPosition(PlayerPedId(), false)
                    SetEntityCoords(PlayerPedId(), x + 1.3, y, z)
                    tumbado_sentado = false 
                end
            end
        end
    end)
end

function sentarse(x, y, z, heading)
    SetEntityCoords(PlayerPedId(), x, y, z + 0.3)
    RequestAnimDict('amb@lo_res_idles@')
    while not HasAnimDictLoaded('amb@lo_res_idles@') do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), 'amb@lo_res_idles@' , 'world_human_picnic_male_lo_res_base' ,8.0, -8.0, -1, 1, 0, false, false, false )

    SetEntityHeading(PlayerPedId(), heading + 180.0)

    tumbado_sentado = true

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if tumbado_sentado == true then
                DrawSub('Pulsa ~g~H~w~ para levantarte')
                if IsControlJustReleased(0, 74) then
                    ClearPedTasks(PlayerPedId())
                    FreezeEntityPosition(PlayerPedId(), false)
                    SetEntityCoords(PlayerPedId(), x + 1.3, y, z)
                    tumbado_sentado = false 
                end
            end
        end
    end)
end
