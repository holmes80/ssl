var shell = require('node-powershell');

module.exports = {
    createADUser:createADUser,
	deleteADUser:deleteADUser,  // delete single user
	deleteMultipleADUser:deleteMultipleADUser, // delete multiple users
	updateADUserApplication:updateADUserApplication,
	updateADUserPassword:updateADUserPassword
}

function createADUser(object,callback){
	var usernameArray=[]
	var passwordArray=[]
	var appsArray=[]

	for(var i=0;i<object.length;i++)
	{
		usernameArray.push(object[i].name)
		passwordArray.push(object[i].password)
		appsArray.push(object[i].apps)
	}
		var ps = new shell({executionPolicy: 'Bypass', debugMsg: true, noProfile: true});
	ps.addCommand('./scripts/createAdUserWithUpn.ps1',
	[{name:'userprefix' ,value:usernameArray},{name:'password1' ,value:passwordArray},{name:'apps1' ,value:appsArray},{name:'upn',value:object[0].domainName}])
	.then(function(){
        return ps.invoke();
    })
  
	.then(function(output){
		
		callback(null,output);
		ps.dispose();
	})
    .catch(function(err){
	console.log(err)
		callback(err,null);
        ps.dispose();
    });
}

// function for delete multiple users
function deleteMultipleADUser(object,callback){
	var username=object.username
		var ps = new shell({executionPolicy: 'Bypass', debugMsg: true, noProfile: true});
	ps.addCommand('./scripts/multipleUserDelete.ps1',[{name:'username' ,value:username}])
	.then(function(){
        return ps.invoke();
    })
  
	.then(function(output){
		
		callback(null,output);
		ps.dispose();
	})
    .catch(function(err){
	console.log(err)
		callback(err,null);
        ps.dispose();
    });
}

function deleteADUser(object,callback){
	var username=object.username
		var ps = new shell({executionPolicy: 'Bypass', debugMsg: true, noProfile: true});
	ps.addCommand('./scripts/userDelete.ps1',[{name:'username' ,value:username}])
	.then(function(){
        return ps.invoke();
    })
  
	.then(function(output){
		
		callback(null,output);
		ps.dispose();
	})
    .catch(function(err){
	console.log(err)
		callback(err,null);
        ps.dispose();
    });
}

function updateADUserApplication(object,callback){
	var username=object.username
	var appsList =object.applist
	
	var ps = new shell({executionPolicy: 'Bypass', debugMsg: true, noProfile: true});
	ps.addCommand('./scripts/updateAdUserApplication.ps1',[{name:'username' ,value:username},{name:'appList' ,value:appsList}])
	.then(function(){
        return ps.invoke();
    })
  
	.then(function(output){		
		callback(null,output);
		ps.dispose();
	})
    .catch(function(err){
	console.log(err)
		callback(err,null);
        ps.dispose();
    });
}

function updateADUserPassword(object,callback){
	var username=object.username
	var newPassword = object.newpassword

	var ps = new shell({executionPolicy: 'Bypass', debugMsg: true, noProfile: true});
	ps.addCommand('./scripts/updateAdUserPassword.ps1',[{name:'username' ,value:username},{name:'newPassword' ,value:newPassword}])
	.then(function(){
        return ps.invoke();
    })
  
	.then(function(output){		
		callback(null,output);
		ps.dispose();
	})
    .catch(function(err){
	console.log(err)
		callback(err,null);
        ps.dispose();
    });
}