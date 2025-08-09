BccUtils.RPC:Register("bcc-ranch:SetNpcConfig", function(params, cb, src)
    local ranchId = tonumber(params.ranchId)
    if not ranchId then
        if cb then cb(false) end
        return
    end

    -- Fetch ranch coords and radius to validate position
    local result = MySQL.single.await("SELECT ranchcoords, ranch_radius_limit FROM bcc_ranch WHERE ranchid = ?", { ranchId })
    if not result then
        devPrint("[SetNpcConfig] Ranch not found for ID: " .. ranchId)
        if cb then cb(false) end
        return
    end

    local decodedCoords = json.decode(result.ranchcoords or "{}")
    local radius = tonumber(result.ranch_radius_limit or 0)
    if not decodedCoords.x or not radius then
        devPrint("[SetNpcConfig] Invalid ranchcoords or radius for ranchId: " .. ranchId)
        if cb then cb(false) end
        return
    end

    -- If coords are provided, validate they're within ranch radius
    if params.coords then
        local dx = decodedCoords.x - params.coords.x
        local dy = decodedCoords.y - params.coords.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > radius then
            devPrint("[SetNpcConfig] Rejected NPC coords outside ranch radius (distance: " .. dist .. ", limit: " .. radius .. ")")
            if cb then cb(false) end
            return
        end
    end

    -- Compose SQL update
    local updates = {}
    local vals = {}

    if params.enabled ~= nil then
        table.insert(updates, "ranch_npc_enabled = ?")
        table.insert(vals, params.enabled and 1 or 0)
    end
    if params.coords then
        table.insert(updates, "ranchcoords = ?")
        table.insert(vals, json.encode(params.coords))
    end
    if params.heading then
        table.insert(updates, "ranch_npc_heading = ?")
        table.insert(vals, tonumber(params.heading))
    end

    if #updates == 0 then
        if cb then cb(false) end
        return
    end

    local sql = "UPDATE bcc_ranch SET " .. table.concat(updates, ", ") .. " WHERE ranchid = ?"
    table.insert(vals, ranchId)
    local success = MySQL.update.await(sql, vals)

    if success then
        devPrint("[Ranch NPC] Updated NPC config for ranchId " .. ranchId)
        if cb then cb(true) end
    else
        devPrint("[Ranch NPC] Failed to update NPC config for ranchId " .. ranchId)
        if cb then cb(false) end
    end
end)
