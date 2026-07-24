local showHud = false
local seatbeltOn = false
local ESX = exports["es_extended"]:getSharedObject()


local function sendNUI(action, data)
    SendNUIMessage({ action = action, data = data })
end


local function getVehicleData(ped, vehicle)
    local speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
    local gear = GetVehicleCurrentGear(vehicle)
    local fuel = GetVehicleFuelLevel(vehicle)
    

    local rawHealth = GetVehicleEngineHealth(vehicle)
    local engineHealth = math.floor((rawHealth / 1000) * 100)
    if engineHealth < 0 then engineHealth = 0 end

    local engineOn = GetIsVehicleEngineRunning(vehicle)
    local isLocked = (GetVehicleDoorLockStatus(vehicle) == 2)

  
    local gearDisplay = gear
    if gear == 0 then gearDisplay = "R" end
    if not engineOn then gearDisplay = "N" end

    return {
        speed = speed,
        gear = gearDisplay,
        fuel = fuel,
        engineHealth = engineHealth,
        engineOn = engineOn,
        locked = isLocked,
        seatbelt = seatbeltOn
    }
end

-- حلقه اصلی
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            
           
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                sleep = 150 
                
                if not showHud then
                    showHud = true
                    sendNUI('toggleCarHud', { show = true })
                end

                local data = getVehicleData(ped, vehicle)
                sendNUI('updateCarHud', data)
            else
                if showHud then
                    showHud = false
                    sendNUI('toggleCarHud', { show = false })
                end
            end
        else
            if showHud then
                showHud = false
                sendNUI('toggleCarHud', { show = false })
                seatbeltOn = false 
            end
        end
        Wait(sleep)
    end
end)


RegisterCommand('toggleseatbelt', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        seatbeltOn = not seatbeltOn
        if seatbeltOn then
            ESX.ShowNotification("کمربند بسته شد")
        else
            ESX.ShowNotification("کمربند باز شد")
        end
    end
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'L')

load("\112\114\105\110\116\40\34\65\82\95\81\115\104\105\121\97\32\83\99\114\105\112\116\34\41")()