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

        if not menu_abierto and not tumbado_sentado then
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for i = 1, #Config.Camillas do
                local camillaID = Config.Camillas[i]
                local distance = GetDistanceBetweenCoords(playerCoords, camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)

                if distance < 1.5 then
                    ShowFloatingHelpNotification("Pulsa ~y~E~s~ para interactuar", vector3(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z))
                    if IsControlJustReleased(0, 38) then
                        AbrirMenuCamillas()
                    end
                end
            end
        end
    end
end)

----- Menu
local function AbrirSubMenu(animacion)
    CORE.UI.Menu.Open('default', GetCurrentResourceName(), 'menu', {
        title = ('¿Estás seguro?'),
        elements = {
            {label = ('Si'), value = 'yes'},
            {label = ('No'), value = 'no'}
        }
    }, function(data, menu)
        if data.current.value == 'yes' then
            for i=1, #Config.Camillas do
                local camillaID   = Config.Camillas[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, true)
            if distance < 1.5 and not tumbado_sentado then
                animacion(camillaID.coordenadas_camilla.x, camillaID.coordenadas_camilla.y, camillaID.coordenadas_camilla.z, camillaID.heading, camillaID)
                CORE.UI.Menu.CloseAll()
            end
        end
        else
            CORE.UI.Menu.CloseAll()
        end
    end, function(data, menu)
        CORE.UI.Menu.CloseAll()
    end)
end

function AbrirMenuCamillas()
    CORE.UI.Menu.CloseAll()

    if menu_abierto then
        return
    end

    menu_abierto = true
    local elements = {
        {label = ('Tumbarse en la camilla boca arriba'), value = 'tumbarse_arriba'},
        {label = ('Tumbarse en la camilla boca abajo'), value = 'tumbarse_abajo'},
        {label = ('Sentarse en la camilla'), value = 'sentarse'},
    }

    CORE.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_bads', {
        title = ('Camillas hospital'),
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        local selectedValue = data.current.value

        if selectedValue == 'tumbarse_arriba' then
            AbrirSubMenu(tumbarseBocaArriba)
        elseif selectedValue == 'tumbarse_abajo' then
            AbrirSubMenu(tumbarseBocaAbajo)
        elseif selectedValue == 'sentarse' then
            AbrirSubMenu(sentarse)
        end
    end, function(data, menu)
        CORE.UI.Menu.CloseAll()
    end)

    menu_abierto = false
end

function tumbarseBocaArriba(x, y, z, heading)
    IniciarAnimacion(x, y, z, heading, {
        animDict = 'anim@gangops@morgue@table@',
        animName = 'body_search',
        headingOffset = 180.0
    })
end

function tumbarseBocaAbajo(x, y, z, heading)
    IniciarAnimacion(x, y, z, heading, {
        animDict = 'missfbi3_sniping',
        animName = 'prone_dave',
        headingOffset = 0.0
    })
end

function sentarse(x, y, z, heading)
    IniciarAnimacion(x, y, z, heading, {
        animDict = 'amb@lo_res_idles@',
        animName = 'world_human_picnic_male_lo_res_base',
        headingOffset = 180.0
    })
end

function PulsarH()
    DrawSub('Pulsa ~g~H~w~ para levantarte')
    if IsControlJustReleased(0, 74) then
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
        SetEntityCoords(PlayerPedId(), x + 1.3, y, z)
        tumbado_sentado = false
    end
end

function IniciarAnimacion(x, y, z, heading, animacion)
    SetEntityCoords(PlayerPedId(), x, y, z + 0.3)
    RequestAnimDict(animacion.animDict)
    while not HasAnimDictLoaded(animacion.animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), animacion.animDict, animacion.animName, 8.0, -8.0, -1, 1, 0, false, false, false)

    SetEntityHeading(PlayerPedId(), heading + animacion.headingOffset)

    tumbado_sentado = true

    Citizen.CreateThread(function()
        while tumbado_sentado do
            Citizen.Wait(0)
            PulsarH()
        end
    end)
end
