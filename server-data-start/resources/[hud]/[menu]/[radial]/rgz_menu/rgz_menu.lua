local menuOn = false

local keybindControls = {
	["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local keybindControl = keybindControls["F3"]
        if IsControlPressed(0, keybindControl) then
            menuOn = true
            SendNUIMessage({
                type = 'init',
                resourceName = GetCurrentResourceName()
            })
            SetCursorLocation(0.5, 0.5)
            SetNuiFocus(true, true)
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
            while menuOn == true do Citizen.Wait(100) end
            Citizen.Wait(100)
            while IsControlPressed(0, keybindControl) do Citizen.Wait(100) end
        end
    end
end)

RegisterNUICallback('closemenu', function(data, cb)
    menuOn = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'destroy'
    })
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    cb('ok')
end)


RegisterNUICallback('openmenu', function(data)
    menuOn = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'destroy'
    })
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
        if data.id == 'animenu' then
        TriggerEvent("dp:RecieveMenu")
    elseif data.id == 'billing' then
        TriggerEvent("esx_billing:radialbill")
    elseif data.id == 'dance' then
        TriggerEvent("")
    elseif data.id == 'id' then
        TriggerEvent("jsfour-idcard:openradial")
    elseif data.id == 'work' then
        TriggerEvent('esx_boss:openbossmenulite') 
    elseif data.id == 'handsup' then
        TriggerEvent("")
    end

--[[
    PATTERN FOR CLIENT
    RegisterNetEvent("esx_billing:openBillings")
    AddEventHandler("esx_billing:openBillings", function()
            ShowBillsMenu()
    end)
]]--

end)
-- Callback function for testing
RegisterNUICallback('testprint', function(data, cb)
    -- Print message
    TriggerEvent('chatMessage', "[test]", {255,0,0}, data.message)

    -- Send ACK to callback function
    cb('ok')
end)

