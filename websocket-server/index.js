var express = require('express');
var app = express();
var expressWs = require('express-ws')(app);
const bodyParser = require("body-parser");
var mongoose = require('mongoose')
const rawLog = require("./services/rawLogParserService")
const appParser = require("./services/appIdParserService")
const empParser = require("./services/employeeParserService")
const updateUsage = require("./services/updateUsageService")

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.use(bodyParser.json());

app.ws('/clientData', async function(ws, req) {
    ws.on('message', async function(msg) {
        var parsed = await rawLog.parse(msg)
        if (parsed.header == "Usage"){
            parsed = await appParser.parse(parsed.data)
            parsed = await empParser.parse(parsed)            
            result = await updateUsage.updateAll(parsed)
            console.log(result)
        }
        ws.send("Data was received!")
    });
});

mongoose.connect('mongodb://'+'localhost'+':'+'27017'+'/'+'stratus-dunst',{
    useNewUrlParser: true
}, function(err){
    if(err){
        console.log(err)
    }
    mongoose.Promise = global.Promise
    console.log("Database Connection Established!")
})

app.listen(8001, function(){
    console.log("Stratus Websocket Server running on localhost:8001")
})