local telegrams = {}
local index = 1
local actualDistrict = 0


-----------------
--- Change Me ---
-----------------

-- Add your own location(s) to view telegrams here.

local locations = {
    	{ x=-269.69, y=807.36, z=119.33, district = 1 }, --Valentine Sheriff Office
	{ x=-184.02, y=629.98, z=114.02, district = 1 }, --Valentine Train Station pinboard
	{ x=2983.38, y=572.70, z=44.60, district = 1 }, --Van Horn Pinboard
	{ x=2933.07, y=1286.45, z=44.65, district = 1 }, --Annesburg Train Station Pinboard
	{ x=2627.9, y=-1272.6, z=52.25, district = 2 }, --Saint Denis opposite Bank pinboard
	{ x=1233.90, y=-1293.62, z=76.90, district = 2 }, --Rhodes Train Station Pinboard
	{ x=-1773.03, y=-393.05, z=156.54, district = 3 }, --Strawberry Telgram office
	{ x=-872.54, y=-1324.85, z=43.71, district = 3 }, --Blackwater Depot
    	{ x=-3623.53, y=-2598.65, z=-13.83, district = 4 }, --Armadillo Sheriff Office
	{ x=-5525.10, y=-2927.82, z=-1.99, district = 4 }, --Tumbleweed Sheriff Office
    	{ x=-1959.44, y=-3262.62, z=-7.32, district = 5 }, --Mexico Wedding Venue
}
-----------------
--- Functions ---
-----------------
math.randomseed(GetGameTimer())
local PinBoardPrompt
local PinBoardPromptGroup = GetRandomIntInRange(0, 0xffffff)
print('PinBoardPromptGroup: ' .. PinBoardPromptGroup)

function CreatePrompt()
    Citizen.CreateThread(function()
        local str = 'Read Pinboard'
        local wait = 0
        PinBoardPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PinBoardPrompt, 0xC7B5340A)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PinBoardPrompt, str)
        PromptSetEnabled(PinBoardPrompt, true)
        PromptSetVisible(PinBoardPrompt, true)
        PromptSetHoldMode(PinBoardPrompt, true)
        PromptSetGroup(PinBoardPrompt, PinBoardPromptGroup)
        PromptRegisterEnd(PinBoardPrompt)
    end)
end

local active = false
Citizen.CreateThread(function()
Wait(1000)
CreatePrompt()
    while true do
        Citizen.Wait(1)

        for key, value in pairs(locations) do
            if IsPlayerNearCoords(value.x, value.y, value.z) then
			if active == false then
                     local PinBoardPromptName  = CreateVarString(10, 'LITERAL_STRING', "Notice Board")
                    PromptSetActiveGroupThisFrame(PinBoardPromptGroup, PinBoardPromptName)
                    if PromptHasHoldModeCompleted(PinBoardPrompt) then
						active = true
                        TriggerServerEvent("rw-pinboard:GetMessages", value.district)
                    end
			end
            end
        end
    end
end)

Citizen.CreateThread(function()

        for key, value in pairs(locations) do
         Wait(1)                 
        local blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, value.x, value.y, value.z)
        SetBlipSprite(blip, -272216216)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Notice Board")    
		end
          
end)

function IsPlayerNearCoords(x, y, z)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(PlayerPedId(), 0))
    local distance = Vdist(playerx, playery, playerz, x, y, z)

    if distance < 1 then
        return true
    end
end

function DrawText(text,x,y)
    SetTextScale(0.35,0.35)
    SetTextColor(255,255,255,255)--r,g,b,a
    SetTextCentre(true)--true,false
    SetTextDropshadow(1,0,0,0,200)--distance,r,g,b,a
    SetTextFontForCurrentCommand(0)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

function OpenTelegram()
    SetNuiFocus(true, true)
    SendNUIMessage({ display = true, message = telegrams[index].message })
end

function CloseTelegram()
	active = false
    index = 1
    SetNuiFocus(false, false)
    SendNUIMessage({ display = false })
end

RegisterNetEvent("rw-pinboard:ReturnMessages")
AddEventHandler("rw-pinboard:ReturnMessages", function(data, district)

    print(json.encode(data))
    telegrams = data
    actualDistrict = district

    if next(telegrams) == nil then
        SetNuiFocus(true, true)
        SendNUIMessage({ display = true, message = "There are no adverts to display." })
    else
        OpenTelegram()
    end
end)

-----------------
--- Callbacks ---
-----------------

RegisterNUICallback('back', function()
    if index > 1 then
        index = index - 1
        SendNUIMessage({ display = true, message = telegrams[index].message })
    end
end)

RegisterNUICallback('next', function()
    if index < #telegrams then
        index = index + 1
        SendNUIMessage({ display = true, message = telegrams[index].message })
    end
end)

RegisterNUICallback('close', function()
    CloseTelegram()
end)

RegisterNUICallback('new', function(data)
		CloseTelegram()
    if  data.tresc ~= nil then
        TriggerServerEvent("rw-pinboard:SendMessage", GetPlayerName(PlayerId()),  data.tresc, actualDistrict)
    end
end)
