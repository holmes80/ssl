var usage = require("../models/customerUsage")
var mongo = require('mongodb')

function update (data){
    return new Promise(function(res, rej){
        var caId = data.caId;
        var cuId = data.cuId;
        var appName = data.appName;
        var appId = data.appId
        appId = new mongo.ObjectID(appId)
        var date = new Date(Date.UTC(data.year, data.month-1, data.day, 0, 0, 0, 0))

        usage.updateOne(
            {
                caId: caId,
                cuId: cuId,
                appId: appId,
                appName: appName,
                year: data.year,
                month: data.month,
                day: data.day,
                date: date            
            },
            {
                $inc: {"usage": data.elapsedTime}
            },
            {upsert: true}
        )
        .then(function(response) {
            res({ success: true, data: response})
        })
        .catch(function(err) {
            res({ success: false, err: err})
        });
    })
}

module.exports.updateAll = async function(parsedData){
    return new Promise(async function(res, rej){
        var count = 0;
        var empProcessMap = new Map();
        for (var i = 0; i < parsedData.length; i++) {
            // cuId and appid has not been seen before
            if (empProcessMap.has(parsedData[i].cuId) == false){
                result = await update(parsedData[i])
                if (result.success == true){
                    count++
                }
                empProcessMap.set(parsedData[i].cuId, new Set())
                empProcessMap.get(parsedData[i].cuId).add(parsedData[i].appId)
            } else { // already has cuId, then check if appid has been seen
                if (empProcessMap.get(parsedData[i].cuId).has(parsedData[i].appId) == false){
                    result = await update(parsedData[i])
                    if (result.success == true){
                        count++
                    }
                    empProcessMap.get(parsedData[i].cuId).add(parsedData[i].appId)
                }
            }
        }
        var message = "Rows updated: " + count;
        res({ success: true, data: message})
    })
}