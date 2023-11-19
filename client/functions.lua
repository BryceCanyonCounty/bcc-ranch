------- Pulling Essentials ------
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)

MenuData = {}
TriggerEvent("menuapi:getData", function(cb)
  MenuData = cb
end)

BccUtils = exports['bcc-utils'].initiate()
MiniGame = exports['bcc-minigames'].initiate()

----- Setting RelationShip ----
function relationshipsetup(ped, relInt) --ped and player relationship setter, rail int is 1-5 1 being friend 5 being hate
  SetRelationshipBetweenGroups(relInt, GetPedRelationshipGroupHash(ped), joaat('PLAYER'))
end

-------- Get Players Function --------
function GetPlayers()
  TriggerServerEvent("bcc-ranch:GetPlayers")
  local playersData = {}
  RegisterNetEvent("bcc-ranch:SendPlayers", function(result)
    playersData = result
  end)
  while next(playersData) == nil do
    Wait(10)
  end
  return playersData
end

function DelPedsForTable(table) --will delete all peds in the table
  for k, v in pairs(table) do
    DeletePed(v)
  end
end

function SetRelAndFollowPlayer(table) --will set the peds relation with player and then have ped follow player
  for k, v in pairs(table) do
    relationshipsetup(v, 1)
    TaskFollowToOffsetOfEntity(v, PlayerPedId(), Config.RanchSetup.animalFollowSettings.offsetX,
      Config.RanchSetup.animalFollowSettings.offsetY, Config.RanchSetup.animalFollowSettings.offsetZ, 1, -1, 5, true,
      true, Config.RanchSetup.AnimalsWalkOnly, true, true, true)
  end
end

function playAnim(animDict, animName, time) --function to play an animation
  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Wait(100)
  end
  
  local flag = 16
  -- if time is -1 then play the animation in an infinite loop which is not possible with flag 16 but with 1
  -- if time is -1 the caller has to deal with ending the animation by themselve
  if time == -1 then
    flag = 1
  end
  TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)
end
