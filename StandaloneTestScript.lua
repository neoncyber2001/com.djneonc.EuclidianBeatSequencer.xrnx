local euclideanLib = require("euclideanLib")

local DataObj = euclideanLib.InitDataObj()

for dataCol,noteColumn in DataObj do
    print("Ins: ".. dataCol.insturment .."\n")
    print("Ins: ".. dataCol.drum_note .."\n")
    print("Ins: ".. dataCol.steps .."\n")
    print("Ins: ".. dataCol.hits .."\n")
    print("Ins: ".. dataCol.offset .."\n")
    
    print("----------------------------\n")
end