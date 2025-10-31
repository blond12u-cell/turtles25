-- Miner.lua - Digs down in a staircase pattern
-- Creates a 2-high tunnel that descends forward without changing horizontal direction
-- Automatically manages fuel by refueling when needed

local FUEL_SLOT = 16  -- Reserve last slot for fuel
local MIN_FUEL = 20   -- Minimum fuel to keep in inventory (increased for more operations)

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

-- Dig a 2-high tunnel forward while descending
local function digStaircase()
    local depth = 0
    
    while true do
        -- Check fuel before each operation
        if not refuel() then
            return false
        end
        
        -- Dig forward (2 blocks high)
        turtle.dig()
        turtle.digUp()
        
        -- Move forward
        if not turtle.forward() then
            print("Can't move forward. Obstruction at depth " .. depth)
            return true
        end
        
        -- Dig down in front (stair step)
        turtle.digDown()
        
        -- Move down
        if not turtle.down() then
            print("Failed to move down at depth " .. depth)
            return false
        end
        
        depth = depth + 1
        
        -- Report progress every 5 blocks
        if depth % 5 == 0 then
            print("Depth: " .. depth .. ", Fuel: " .. turtle.getFuelLevel())
        end
    end
end

-- Main function
local function main()
    print("Mining Turtle - 2-High Descending Tunnel")
    print("Place coal in slot " .. FUEL_SLOT)
    print("Place building materials in slots 1-" .. (FUEL_SLOT-1))
    print("The turtle will dig a 2-high tunnel that descends forward")
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
