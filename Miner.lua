-- Miner.lua - Digs down to bedrock in a staircase pattern
-- Automatically manages fuel by refueling when needed

local FUEL_SLOT = 16  -- Reserve last slot for fuel
local MIN_FUEL = 10   -- Minimum fuel to keep in inventory

-- Refuel the turtle using coal from the fuel slot
local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
        return true
    end
    
    -- Check if we need more fuel
    if fuelLevel < MIN_FUEL then
        turtle.select(FUEL_SLOT)
        -- Keep trying to refuel until we have enough or run out of coal
        while turtle.getFuelLevel() < MIN_FUEL + 10 do
            if not turtle.refuel(1) then
                print("Out of fuel. Please add coal to slot " .. FUEL_SLOT)
                return false
            end
        end
        print("Refueled. Current fuel: " .. turtle.getFuelLevel())
    end
    return true
end

-- Select the first available building material
local function selectBuildingMaterial()
    for i = 1, FUEL_SLOT - 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            return true
        end
    end
    print("No building materials found!")
    return false
end

-- Dig down in a staircase pattern until bedrock is reached
local function digStaircase()
    local depth = 0
    
    while true do
        -- Check fuel before each operation
        if not refuel() then
            return false
        end
        
        -- Try to dig down
        if not turtle.digDown() then
            -- If we can't dig down, we've hit bedrock or obstruction
            if turtle.inspectDown() then
                print("Reached bedrock or obstruction at depth " .. depth)
                return true
            end
        end
        
        -- Move down
        if not turtle.down() then
            print("Failed to move down at depth " .. depth)
            return false
        end
        depth = depth + 1
        
        -- Try to dig forward (for staircase)
        if not turtle.dig() then
            -- If we can't dig forward, that's okay - just continue down
        end
        
        -- Move forward to create staircase
        if turtle.forward() then
            -- Successfully moved forward, continue pattern
        else
            -- Can't move forward, try to dig and move again
            turtle.dig()
            turtle.forward()
        end
        
        -- Turn right to create spiral pattern
        turtle.turnRight()
        
        -- Report progress every 10 blocks
        if depth % 10 == 0 then
            print("Depth: " .. depth .. ", Fuel: " .. turtle.getFuelLevel())
        end
    end
end

-- Main function
local function main()
    print("Mining Turtle - Staircase to Bedrock")
    print("Place coal in slot " .. FUEL_SLOT)
    print("Place building materials in slots 1-" .. (FUEL_SLOT-1))
    print("Press Enter to start...")
    read()
    
    -- Check initial fuel
    if not refuel() then
        return false
    end
    
    -- Select building material for placing blocks
    if not selectBuildingMaterial() then
        return false
    end
    
    print("Starting descent...")
    return digStaircase()
end

-- Run the program
main()
