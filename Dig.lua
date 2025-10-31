-- Dig.lua - Mining program to dig staircase to bedrock and back

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
    -- Dig forward, up, and down to create a 3-block tall staircase
    -- First, dig forward
    while turtle.dig() do end
    turtle.forward()
    
    -- Dig up
    while turtle.digUp() do end
    
    -- Dig down
    while turtle.digDown() do end
    
    -- Move down to next level
    turtle.down()
    
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

local function buildUpStaircase()
    -- Fill gaps below and place torches every few steps
    -- First, check if the block below is solid
    if not turtle.detectDown() then
        -- Try to place a block below
        if selectNonEssentialItem() then
            turtle.placeDown()
        end
    end
    
    -- Move up
    while turtle.digUp() do end
    turtle.up()
    
    -- Place torch every 6 blocks (adjust as needed)
    local currentY = ... -- We need to track Y coordinate
    -- Since we don't have GPS, we'll place torches based on steps
    -- For now, we'll track steps in a variable
end

local function main()
    print("Starting mining operation...")
    
    -- Track our depth
    local depth = 0
    
    -- Dig down to bedrock
    while true do
        -- Check if we're at bedrock (y=0)
        -- Since we can't directly check Y coordinate, we'll detect bedrock by mining until we can't go down
        if not digDownStaircase() then
            break
        end
        depth = depth + 1
        
        -- Check if we've hit bedrock (the block below is unbreakable)
        -- Try to dig down - if it's bedrock, it won't break
        if not turtle.digDown() then
            -- Check if we can move down
            if not turtle.down() then
                print("Reached bedrock at depth " .. depth)
                break
            else
                turtle.up() -- We moved down, so move back up
            end
        else
            turtle.down()
            depth = depth + 1
        end
    end
    
    -- Now we're at the bottom, build our way up
    print("Building staircase up...")
    local torchCounter = 0
    while depth > 0 do
        -- Place block below if needed
        if not turtle.detectDown() then
            if selectNonEssentialItem() then
                turtle.placeDown()
            end
        end
        
        -- Place torch every 6 blocks
        torchCounter = torchCounter + 1
        if torchCounter % 6 == 0 then
            placeTorch()
        end
        
        -- Move up
        while turtle.digUp() do end
        if turtle.up() then
            depth = depth - 1
        else
            print("Can't move up!")
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
