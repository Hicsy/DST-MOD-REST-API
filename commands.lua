-- Some testing functions. You can add lengthy functions here and the API will look here first.
-- Extinguish and Repair are some good examples from DST Discord users.

function mytext(text)
    print(text)
end

function api_extinguish(player_name)
    local player = UserToPlayer(player_name)
    local x,y,z = player.Transform:GetWorldPosition()
    -- TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags)
    for key,ent in ipairs(TheSim:FindEntities(x,y,z, 40, nil, {'FX','DECOR','INLIMBO','burnt'}, {'fire','smolder'})) do
        if ent.components.burnable then
            ent.components.burnable:Extinguish()
        end
    end
end

function api_repair(player_name)
    local player = UserToPlayer(player_name)
    local x,y,z = player.Transform:GetWorldPosition()
    -- TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags)
    for key,ent in ipairs(TheSim:FindEntities(x,y,z, 24, {'burnt','structure'}, {'INLIMBO'})) do
        local orig_pos = ent:GetPosition()
        ent:Remove()
        local inst = SpawnPrefab(tostring(ent.prefab), tostring(ent.skinname), nil, player.userid)
        if inst then
            inst.Transform:SetPosition(orig_pos:Get())
        end
    end
end

print("commands.lua loaded!")