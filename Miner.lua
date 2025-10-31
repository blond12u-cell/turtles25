-- Miner.lua - Digs down in a staircase pattern
-- Creates a 2-high tunnel that descends forward without changing horizontal direction
-- Automatically manages fuel by refueling when needed

local FUEL_SLOT = 16  -- Reserve last slot for fuel
local MIN_FUEL = 20   -- Minimum fuel to keep in inventory (increased for more operations)

-- Refuel the turtle using fuel items from the fuel slot
local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
        return true
    end
    
    -- Check if we need more fuel
    if fuelLevel < MIN_FUEL then
        print("Low fuel: " .. fuelLevel .. ", refueling...")
        turtle.select(FUEL_SLOT)
        -- Try to refuel up to MIN_FUEL + 100
        while turtle.getFuelLevel() < MIN_FUEL + 100 do
            if not turtle.refuel(1) then
                -- Check if there are fuel items in other slots
                local foundFuel = false
                for i = 1, 16 do
                    if i ~= FUEL_SLOT then
                        turtle.select(i)
                        if turtle.refuel(0) then  -- Check if item is fuel
                            turtle.select(FUEL_SLOT)
                            turtle.transferTo(FUEL_SLOT)
                            turtle.select(FUEL_SLOT)
                            foundFuel = true
                            break
                        end
                    end
                end
                if not foundFuel then
                    print("Out of fuel. Please add fuel to any slot")
                    return false
                end
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

-- Dig and build a staircase pattern while descending
local function digStaircase()
    local depth = 0
    
    while true do
        -- Check fuel before each operation
        if not refuel() then
            return false
        end
        
        -- Dig forward and up to clear a 2-block high space
        turtle.dig()
        turtle.digUp()
        
        -- Move forward
        if not turtle.forward() then
            print("Can't move forward. Obstruction at depth " .. depth)
            return true
        end
        
        -- Dig down to create the next step
        turtle.digDown()
        
        -- Move down to the next level
        if not turtle.down() then
            print("Failed to move down at depth " .. depth)
            return false
        end
        
        -- Place a block behind to create the stair (above the turtle)
        -- First, turn around to place the block
        turtle.turnLeft()
        turtle.turnLeft()
        
        -- Select building material
        if not selectBuildingMaterial() then
            print("No building materials to place stair block")
            return false
        end
        
        -- Place the block above to form the stair
        if not turtle.placeUp() then
            print("Couldn't place block above at depth " .. depth)
        end
        
        -- Turn back to original direction
        turtle.turnLeft()
        turtle.turnLeft()
        
        depth = depth + 1
        
        -- Report progress every 5 blocks
        if depth % 5 == 0 then
            print("Depth: " .. depth .. ", Fuel: " .. turtle.getFuelLevel())
        end
    end
end

-- Main function
local function main()
    print("Mining Turtle - Staircase Descent")
    print("Place fuel (coal, lava buckets, etc.) in any slot")
    print("Place building materials in any slot (will be used for stairs)")
    print("The turtle will dig and build a staircase that descends forward")
    print("Press Enter to start...")
    read()
    
    -- Check initial fuel
    if not refuel() then
        print("Initial refueling failed")
        return false
    end
    
    print("Starting descent...")
    local success = digStaircase()
    if success then
        print("Descent completed successfully")
    else
        print("Descent failed")
    end
    return success
end

-- Run the program
main()
