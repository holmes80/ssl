var user = require("../models/customerUser")

module.exports.parse = function(bulkData){
    return new Promise(function(res, rej){
        user
            .find({})
            .then(async function(userList){
                var caIdMap = new Map();
                var cuIdMap = new Map();
                for(var i = 0; i < userList.length; i++){
                    caIdMap.set(userList[i].username, userList[i].caId)
                    cuIdMap.set(userList[i].username, userList[i]._id)
                }
                for (var i = 0; i < bulkData.length; i++){
                    if(caIdMap.has(bulkData[i].username) == true){
                        bulkData[i].caId = caIdMap.get(bulkData[i].username)
                        bulkData[i].cuId = cuIdMap.get(bulkData[i].username)
                    } else {
                        bulkData.splice(i, 1)
                        i--
                    }
                }
                res(bulkData)
            })
    })
}