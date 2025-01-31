RegisterServerEvent('eden_garage:debug')
RegisterServerEvent('eden_garage:modifystate')
RegisterServerEvent('eden_garage:modifystatestored')
RegisterServerEvent('eden_garage:pay')
RegisterServerEvent('eden_garage:payhealth')
RegisterServerEvent('eden_garage:logging')

ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Vehicle fetch

ESX.RegisterServerCallback('eden_garage:getVehicles', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicules, {vehicle = vehicle, state = v.state, plate = v.plate, stored = v.stored, fuel = v.fuel, type = v.type, damage = v.damage})
		end
		cb(vehicules)
	end)
end)


-- End vehicle fetch
-- Store & update vehicle properties

ESX.RegisterServerCallback('eden_garage:stockv',function(source,cb, vehicleProps)
	local isFound = false
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate
		for _,v in pairs(vehicules) do
			if(plate == plate)then
				local vehprop = json.encode(vehicleProps)
				MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle=@vehprop WHERE plate=@plate",{['@vehprop'] = vehprop, ['@plate'] = plate})
				isFound = true
				break
			end		
		end
	cb(isFound)
end)

-- End vehicle store
-- Change state of vehicle

															--false, false vehiculo fuera de garaje y fuera de impounded
															--true, false Vehiculo en el impounded
AddEventHandler('eden_garage:modifystate', function(plate, state, stored)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local state = state
	local stored = stored
	local fuel = fuel
	for _,v in pairs(vehicules) do
		MySQL.Sync.execute("UPDATE owned_vehicles SET state=@state, stored=@stored WHERE plate=@plate",{['@state'] = state , ['@plate'] = plate, ['@stored'] = stored, ['@damage'] = damage})
		break		
	end
end)

AddEventHandler('eden_garage:modifystatestored', function(plate, state, stored, fuel, damage)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local state = state
	local stored = stored
	local fuel = fuel
	for _,v in pairs(vehicules) do
		MySQL.Sync.execute("UPDATE owned_vehicles SET state=@state, stored=@stored, fuel=@fuel WHERE plate=@plate",{['@state'] = state , ['@plate'] = plate, ['@stored'] = stored, ['@fuel'] = fuel, ['@damage'] = damage})
		break		
	end
end)

-- End state update
-- Get user properties

ESX.RegisterServerCallback('eden_garage:getOwnedProperties',function(source, cb)	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local properties = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_properties WHERE owner=@identifier",{['@identifier'] = xPlayer.getIdentifier()}, function(data)
		for _,v in pairs(data) do
			table.insert(properties, v.name)
		end
		cb(properties)
	end)
end)

-- End user properties
-- Function to recover plates deprecated and removed.
-- Get list of vehicles already out

ESX.RegisterServerCallback('eden_garage:getOutVehicles',function(source, cb)	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = {}

	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier AND state=false",{['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(vehicules, vehicle)
		end
		cb(vehicules)
	end)
end)

-- End out list
-- Check player has funds

ESX.RegisterServerCallback('eden_garage:checkMoney', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.Price then
		cb(true)
	else
		cb(false)
	end
end)

-- End funds check
-- Withdraw money

AddEventHandler('eden_garage:pay', function()

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeMoney(Config.Price)

	TriggerClientEvent('esx:showNotification', source, _U('you_paid')..' ' .. Config.Price)

end)

-- End money withdraw
-- Find player vehicles

function getPlayerVehicles(identifier)
	
	local vehicles = {}
	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = identifier})	
	for _,v in pairs(data) do
		local vehicle = json.decode(v.vehicle)
		table.insert(vehicles, {id = v.id, plate = v.plate})
	end
	return vehicles
end

-- End fetch vehicles
-- Debug [not sure how to use this tbh]

AddEventHandler('eden_garage:debug', function(var)
	print(to_string(var))
end)

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

-- End debug
-- Return all vehicles to garage (state update) on server restart

AddEventHandler('onMySQLReady', function()
	local garage = "A"

	MySQL.Sync.execute("UPDATE owned_vehicles SET state= 0 WHERE state=1 AND stored = 0 AND aparcado = 0 AND garage = @garage", {['@garage'] = garage})

end)

-- End vehicle return
-- Pay vehicle repair cost

AddEventHandler('eden_garage:payhealth', function(price)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeMoney(price)

	TriggerClientEvent('esx:showNotification', source, _U('you_paid')..' ' .. price)

end)

-- End repair cost
-- Log to the console

AddEventHandler('eden_garage:logging', function(logging)
	RconPrint(logging)
end)

-- End console log
