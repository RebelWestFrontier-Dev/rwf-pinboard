RegisterServerEvent("rw-pinboard:GetMessages")
AddEventHandler("rw-pinboard:GetMessages", function(district)
        local src = source
        MySQL.Async.fetchAll("SELECT * FROM pinboard ORDER BY id DESC", {}, function(data)
        	TriggerClientEvent("rw-pinboard:ReturnMessages", src, data, district)
        end)
end)

RegisterServerEvent("rw-pinboard:SendMessage")
AddEventHandler("rw-pinboard:SendMessage", function(sender, message, district)
	MySQL.Async.execute("INSERT INTO pinboard (sender, message) VALUES (@sender, @message)",  { ['@sender'] = sender, ['@message'] = message })
	if (string.len(message) > 20) then
        local identifier
	for k,v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, 'steam:') then
			identifier = v
			break
		end
	end
	sendToDiscord(sender, message,identifier, district)
	end
end)

local colors = {
16724516,
51455,
65335,
16514816,
16711931,
16742144,
8527103,
190600
}

local webhook = {
        '', -- Insert Webhook for district = 1
        '', -- Insert Webhook for district = 2
	'', -- Insert Webhook for district = 3
        '', -- Insert Webhook for district = 4
        ''  -- Insert Webhook for district = 5
		
}
local version = "1.0"
local name = "Advertisement"

function sendToDiscord(sender, message , id, district)
	--print(sender)
  local embed = {
        {
            ["color"] = colors[math.random(1, #colors)],
            ["title"] = "**" .. name.. "**",
            ["description"] = message,
            ["footer"] = {
            ["text"] = "RebelWest_Pinboards " .. version.."| "..id,
            },
        }
    }
  local Name = "Notice Board"
  local Image = "https://custompaperswritinghelp.com/uploads/d/Danny/05abee095f.png"
  local TTS = false
  
  PerformHttpRequest(webhook[district], function(Error, Content, Head) end, 'POST', json.encode({username = Name, avatar_url = Image, tts = TTS, embeds = embed}), {['Content-Type'] = 'application/json'})


end
