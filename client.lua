local spawnedVeh = nil

local function setMenu(bool)
  SetNuiFocus(bool, bool)
  SendNUIMessage({ type = 'toggle', show = bool })
  if bool then
    SendNUIMessage({ type = 'list', vehicles = Config.Vehicles })
  end
end

RegisterKeyMapping(Config.KeyName, 'Open Vehicle Spawn Menu', 'keyboard', Config.DefaultKey)
RegisterCommand(Config.KeyName, function()
  setMenu(true)
end)

CreateThread(function()
  while true do
    Wait(0)
    if IsControlJustReleased(0, 177) and IsNuiFocused() then
      setMenu(false)
    end
  end
end)

RegisterNUICallback('close', function(_, cb)
  setMenu(false)
  cb('ok')
end)

RegisterNUICallback('spawn', function(data, cb)
  local model = (data and data.model) or nil
  if not model then cb('bad'); return end

  local modelHash = joaat(model)
  if not IsModelInCdimage(modelHash) then
    TriggerEvent('chat:addMessage', { args = { '^1Model not found:^7 '..model } })
    cb('bad'); return
  end

  RequestModel(modelHash)
  local timeout = GetGameTimer() + 8000
  while not HasModelLoaded(modelHash) do
    if GetGameTimer() > timeout then break end
    Wait(0)
  end
  if not HasModelLoaded(modelHash) then
    TriggerEvent('chat:addMessage', { args = { '^1Failed to load model:^7 '..model } })
    cb('bad'); return
  end

  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)

  if Config.DespawnPrevious and spawnedVeh and DoesEntityExist(spawnedVeh) then
    SetEntityAsMissionEntity(spawnedVeh, true, true)
    DeleteVehicle(spawnedVeh)
    spawnedVeh = nil
  end

  local forward = GetEntityForwardVector(ped)
  local spawnPos = vec3(coords.x + forward.x * 3.0, coords.y + forward.y * 3.0, coords.z + 0.5)
  local veh = CreateVehicle(modelHash, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, false)
  if not DoesEntityExist(veh) then
    TriggerEvent('chat:addMessage', { args = { '^1Failed to create vehicle:^7 '..model } })
    SetModelAsNoLongerNeeded(modelHash)
    cb('bad'); return
  end

  SetVehicleOnGroundProperly(veh)
  SetPedIntoVehicle(ped, veh, -1)
  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleHasBeenOwnedByPlayer(veh, true)

  SetVehicleFixed(veh)
  SetVehicleDirtLevel(veh, 0.0)
  SetVehicleFuelLevel(veh, 100.0)

  SetModelAsNoLongerNeeded(modelHash)
  spawnedVeh = veh
  setMenu(false)
  cb('ok')
end)
