require 'hdf5'

local myFile = hdf5.open('./e.h5', 'w')
myFile:write('act1', torch.rand(5, 5))
myFile:write('act2', torch.zeros(5, 5))
myFile:close()

local myFile2 = hdf5.open('./e.h5', 'r')
print('................')
local data = myFile2:read('act1'):all()
print(data)
 data = myFile2:read('act2'):all()
print(data)
myFile2:close()

-- local file = io.open("names/val_act1.txt", "r")
-- for line in file:lines() do
--    print(line)
-- end

--local path = require 'pl.path'
--local stringx = require 'pl.stringx'
--local totem = require 'totem'
--local tester = totem.Tester()
--local myTests = {}
--local testUtils = hdf5._testUtils


local readFile = hdf5.open('val80k_2d3dName.h5' , 'r')
--dataset = readFile:read('pose2D_act1'):all()
--print(dataset:size())
