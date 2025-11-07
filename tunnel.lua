blockstoDig = 10
blockstoForward = 5
blockstoSpin = 1

for i = 1, blockstoDig do
	turtle.digDown()
	turtle.down()

end 

for i = 1, blockstoForward do
	turtle.dig()
	turtle.forward()

end

for i = 1, blockstoSpin do
	turtle.turnRight()
	turtle.turnRight()

end 

for i = 1, blockstoForward do
	turtle.dig()
	turtle.forward()
end

for i = 1, blockstoDig do
	turtle.digUp()
	turtle.up()
	
end
