var express  = require('express');
var app= express();
var server = require('http').createServer(app);
cors = require('cors');

app.use(cors());
app.options('*', cors())
var bodyParser = require('body-parser');
app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded

var helperCreateADUsers=require('./public/create-AD-user');

app.put('/create',function(req,res){ 
console.log(req.body)
var users=(req.body);
	 helperCreateADUsers.createADUser(users,function(err,data){
		if(err){
		    res.status(400).json({success:false,message:err});
		}
		else{
			console.log(data)
		    //var response=JSON.parse(data) 
		    res.status(200).json({success:true,message:data});
		}
	})
})

// delete single ADuser
app.put('/delete',function(req,res){ 
console.log(req.body)
var users=(req.body);
	 helperCreateADUsers.deleteADUser(users,function(err,data){
		if(err){
		    res.status(400).json({success:false,message:err});
		}
		else{
			console.log(data)
		    //var response=JSON.parse(data) 
		    res.status(200).json({success:true,message:data});
		}
	})
})

// delete multiple AD Users
app.put('/deleteUsers',function(req,res){ 
	console.log(req.body)
	var users=(req.body);
		 helperCreateADUsers.deleteMultipleADUser(users,function(err,data){
			if(err){
				res.status(400).json({success:false,message:err});
			}
			else{
				console.log(data)
				//var response=JSON.parse(data) 
				res.status(200).json({success:true,message:data});
			}
		})
})

app.put('/updateAppName',function(req,res){ 
	console.log(req.body)
	var users=(req.body);
		 helperCreateADUsers.updateADUserApplication(users,function(err,data){
		if(err){
			res.status(400).json({success:false,message:err});
		}
		else{
			console.log(data)
			//var response=JSON.parse(data) 
			res.status(200).json({success:true,message:data});
		}
	})
})

app.put('/updatePassword',function(req,res){ 
	console.log(req.body)
	var users=(req.body);
		 helperCreateADUsers.updateADUserPassword(users,function(err,data){
		if(err){
			res.status(400).json({success:false,message:err});
		}
		else{
			console.log(data)
			//var response=JSON.parse(data) 
			res.status(200).json({success:true,message:data});
		}
	})
})


app.get('/',function(req,res){ 
console.log("hello")
res.status(200).json({success:true,message:"Hello World"});
})

server.listen(8003,function(){
	console.log("SERVER LISTENING AT PORT:8003");
})

