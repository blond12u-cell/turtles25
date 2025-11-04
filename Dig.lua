-- Dig.lua - Mining program to dig a 3 block tall staircase to bedrock and back

local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel > 1000 then
        return true
    end
    
    -- Try to refuel with coal
    for i=1,16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and (item.name == "minecraft:coal" or item.name == "minecraft:coal_block") then
            turtle.refuel(1)
            if turtle.getFuelLevel() > 1000 then
                return true
            end
        end
    end
    return turtle.getFuelLevel() > 100
end

local function selectNonEssentialItem()
    -- Select an item that's not coal, torches, or chests
    for i=1,16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and item.name ~= "minecraft:coal" and item.name ~= "minecraft:coal_block" 
           and item.name ~= "minecraft:torch" and item.name ~= "minecraft:chest" then
            return true
        end
    end
    return false
end

local function isInventoryFull()
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

local function dumpInventory()
    -- Check if we have a chest in inventory
    local hasChest = false
    for i=1,16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and item.name == "minecraft:chest" then
            hasChest = true
            break
        end
    end
    
    if not hasChest then
        print("No chest available to dump inventory")
        return false
    end
    
    -- Dig right to place chest
    turtle.turnRight()
    if turtle.dig() then
        -- Place chest
        for i=1,16 do
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item and item.name == "minecraft:chest" then
                turtle.place()
                break
            end
        end
        
        -- Dump all items except coal, torches, and chests
        for i=1,16 do
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item and item.name ~= "minecraft:coal" and item.name ~= "minecraft:coal_block" 
               and item.name ~= "minecraft:torch" and item.name ~= "minecraft:chest" then
                turtle.drop()
            end
        end
        
        turtle.turnLeft()
        return true
    else
        turtle.turnLeft()
        return false
    end
end

local function placeTorch()
    -- Check if we have a torch
    for i=1,16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item and item.name == "minecraft:torch" then
            -- Place torch on the wall to the left
            turtle.turnLeft()
            if not turtle.dig() then
                -- Try to place torch
                if turtle.place() then
                    turtle.turnRight()
                    return true
                end
            else
                if turtle.place() then
                    turtle.turnRight()
                    return true
                end
            end
            turtle.turnRight()
        end
    end
    return false
end

local function digDownStaircase()
    -- Dig forward to create the next step
    while turtle.dig() do end
    if not turtle.forward() then
        return false
    end
    
    -- Dig the area above to make it 3 blocks tall
    -- First, dig up (second block height)
    while turtle.digUp() do end
    -- Move up to dig the third block height
    if turtle.up() then
        while turtle.digUp() do end
        -- Move back down
        turtle.down()
    end
    
    -- Dig down to clear the next level
    while turtle.digDown() do end
    -- Move down to the next level
    if not turtle.down() then
        return false
    end
    
    -- Check fuel
    if not refuel() then
        print("Out of fuel!")
        return false
    end
    
    -- Check inventory
    if isInventoryFull() then
        if not dumpInventory() then
            print("Inventory full and couldn't dump")
            return false
        end
    end
    
    return true
end

local function isBedrock()
    -- Try to dig down, if it returns false and we can't move down, it's likely bedrock
    local success, data = turtle.inspectDown()
    if success then
        -- In ComputerCraft, bedrock has name "minecraft:bedrock"
        if data.name == "minecraft:bedrock" then
            return true
        end
        -- Try to dig to see if it's breakable
        if turtle.digDown() then
            return false
        else
            -- If we can't dig it, and it's not air, it might be bedrock
            return true
        end
    end
    -- If there's no block below, it's not bedrock
    return false
end

local function main()
    print("Starting mining operation...")
    
    -- Track our depth (number of staircase segments)
    local depth = 0
    
    -- Dig down to bedrock
    while true do
        -- Check if we're at bedrock
        if isBedrock() then
            print("Reached bedrock at depth " .. depth)
            break
        end
        
        -- Dig the next staircase segment
        if not digDownStaircase() then
            print("Failed to dig down further")
            break
        end
        depth = depth + 1
        
        -- Check fuel
        if not refuel() then
            print("Out of fuel!")
            break
        end
    end
    
    -- Turn around to face the way we came
    turtle.turnLeft()
    turtle.turnLeft()
    
    -- Now we're at the bottom, go back up the staircase we dug
    print("Building staircase up...")
    local torchCounter = 0
    for i = 1, depth do
        -- Place torch every 5 segments
        torchCounter = torchCounter + 1
        if torchCounter % 5 == 0 then
            placeTorch()
        end
        
        -- Ensure the block below us is solid
        if not turtle.detectDown() then
            if selectNonEssentialItem() then
                turtle.placeDown()
            end
        end
        
        -- Move up to the next level
        while turtle.digUp() do end
        if not turtle.up() then
            print("Can't move up at step " .. i)
            break
        end
        
        -- Check if we've reached a 2-block tall wall (can't move forward)
        -- Try to dig forward first
        while turtle.dig() do end
        if not turtle.forward() then
            print("Reached a wall, stopping ascent")
            break
        end
        
        -- Check fuel
        if not refuel() then
            print("Out of fuel while building up!")
            break
        end
    end
    
    print("Mining operation complete!")
end

main()
