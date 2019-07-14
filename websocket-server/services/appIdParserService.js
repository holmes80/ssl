var app = require("../models/application")

module.exports.parse = function(bulkData){
    return new Promise(function(res, rej){
        app
            .find({})
            .then(function(appsList){
                var appsMap = new Map();
                for(var i = 0; i < appsList.length; i++){
                    if(appsList[i].processName == undefined || appsList[i].processName == ' '){
                        continue
                    }
                    appsMap.set(appsList[i].processName, appsList[i]._id)
                }
                for(var i = 0; i < bulkData.length; i++){
                    if(appsMap.has(bulkData[i].appName) == false){
                      bulkData.splice(i, 1)
                      i--
                    }
                }
                for (var i = 0; i < bulkData.length; i++){
                    bulkData[i].appId = appsMap.get(bulkData[i].appName)
                }
                res(bulkData)
            })
    })
}