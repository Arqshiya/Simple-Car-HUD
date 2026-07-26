local showHud = false
local seatbeltOn = false

-- کمکی برای ارسال NUI
local function sendNUI(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

-- تابع برای گرفتن اطلاعات خودرو
local function getVehicleData(ped, vehicle)
    local speed = GetEntitySpeed(vehicle) * 3.6 -- m/s -> km/h
    local gear = GetVehicleCurrentGear(vehicle)

    -- سوخت (بسته به اسکریپت سوختت باید این رو اصلاح کنی)
    -- اگر از LegacyFuel/ox_fuel استفاده می‌کنی، همین pattern رو adapt کن
    local fuel = GetVehicleFuelLevel(vehicle)
    if fuel == nil then fuel = 0.0 end

    -- سلامت موتور 0-100
    local engineHealthRaw = GetVehicleEngineHealth(vehicle) -- 0-1000
    local engineHealth = math.floor(math.max(0, math.min(1000, engineHealthRaw)) / 10.0)

    local engineOn = GetIsVehicleEngineRunning(vehicle)

    local locked = GetVehicleDoorLockStatus(vehicle)
    local isLocked = (locked == 2 or locked == 4) -- بسته

    return {
        speed = speed,
        gear = gear,
        fuel = fuel,
        engineHealth = engineHealth,
        engineOn = engineOn,
        locked = isLocked,
        seatbelt = seatbeltOn
    }
end

-- حلقه اصلی HUD
CreateThread(function()
    while true do
        local sleep = 500

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle ~= 0 and vehicle ~= nil then
                if not showHud then
                    showHud = true
                    sendNUI('toggleCarHud', { show = true })
                end

                local data = getVehicleData(ped, vehicle)

                -- آپدیت کلی
                sendNUI('updateCarHud', {
                    speed = data.speed,
                    gear = data.gear,
                    fuel = data.fuel,
                    engineHealth = data.engineHealth,
                    engineOn = data.engineOn,
                    locked = data.locked,
                    seatbelt = data.seatbelt
                })

                -- جداگانه سوخت (برای سازگاری با JS)
                sendNUI('updateHudFuel', {
                    fuel = data.fuel
                })

                -- موتور
                sendNUI('handleEngine', {
                    state = data.engineOn,
                    health = data.engineHealth
                })

                -- قفل
                sendNUI('handleLock', {
                    state = data.locked
                })

                -- کمربند
                sendNUI('handleBelt', {
                    state = data.seatbelt
                })

                sleep = 100
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
            end
        end

        Wait(sleep)
    end
end)

-- اگر برای کمربند کلیدی داری، اینجا مثال ساده:
RegisterCommand('toggleseatbelt', function()
    seatbeltOn = not seatbeltOn
    sendNUI('handleBelt', { state = seatbeltOn })
end, false)
