local args = { ... }
if #args < 1 then
	print("Usage: bridge 10")
	return
end

local nn = args[1]

print("Starting, nn = " .. nn)

local function refuel()
	turtle.select(1)
	turtle.refuel(10)
	print("Current fuel: " .. turtle.getFuelLevel())
end

local function selectBlock()
	turtle.select(2)
end

local function build()
	selectBlock()
	if not turtle.detectDown() then
		turtle.placeDown()
	end
	turtle.turnRight()
	if not turtle.detect() then
		turtle.place()
	end
	turtle.turnLeft()
end

local function move()
	if turtle.detect() then
		turtle.dig()
	end
	turtle.forward()
	if turtle.detectUp() then
		turtle.digUp()
	end
end

local function buildHalf(xx)
	for _ii = 1, xx do
		move()
		build()
	end
end

local function turnAround()
	move()
	turtle.turnLeft()
	move()
	turtle.turnLeft()
end

refuel()
buildHalf(nn)
turnAround()
buildHalf(nn)
turnAround()
