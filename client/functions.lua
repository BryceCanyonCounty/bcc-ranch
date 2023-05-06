------- Pulling Essentials ------
VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)
------ Pulling Essentials ------
TriggerEvent("menuapi:getData", function(call)
  MenuData = call
end)
BccUtils = {}
TriggerEvent('bcc:getUtils', function(bccutils)
  BccUtils = bccutils
end)

------- Load Model -------
function modelload(model)
  RequestModel(model)
  if not HasModelLoaded(model) then
    RequestModel(model)
  end
  while not HasModelLoaded(model) do
    Wait(100)
  end
end

----- Setting RelationShip ----
function relationshipsetup(ped, relint) --ped and player relationship setter, rail int is 1-5 1 being friend 5 being hate
  SetRelationshipBetweenGroups(relint, GetPedRelationshipGroupHash(ped), joaat('PLAYER'))
end