-- Pulling Essentials Here As Global Variables So No Need To Pull Them In Every File
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)
FeatherMenu =  exports['feather-menu'].initiate()
BccUtils = exports['bcc-utils'].initiate()
MiniGame = exports['bcc-minigames'].initiate()

BCCRanchMenu = FeatherMenu:RegisterMenu('bcc-ranch:Menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {},
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '500px',
            ['min-height'] = '500px'
        }
    },
    draggable = true
})

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

function PlayAnim(animDict, animName, time) --function to play an animation
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

function relationshipsetup(ped, relInt) --ped and player relationship setter, rail int is 1-5 1 being friend 5 being hate
  SetRelationshipBetweenGroups(relInt, GetPedRelationshipGroupHash(ped), joaat('PLAYER'))
end

function SetRelAndFollowPlayer(table) --will set the peds relation with player and then have ped follow player
  for k, v in pairs(table) do
    relationshipsetup(v, 1)
    TaskFollowToOffsetOfEntity(v, PlayerPedId(), Config.ranchSetup.animalFollowSettings.offsetX,
      Config.ranchSetup.animalFollowSettings.offsetY, Config.ranchSetup.animalFollowSettings.offsetZ, 1, -1, 5, true,
      true, Config.ranchSetup.animalsWalkOnly, true, true, true)
  end
end