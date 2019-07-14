function htmlEntities(str) {
	return String(str)
		.replace(/\\/g,';' ).replace(/ /g,'')
		.replace(/{/g, '').replace(/}/g, '')
		.replace(/%/g,'' ).replace(/Id=/g,'')
		.replace(/@/g,'').replace(/!/g,'')
		.replace(/CPU=/g,'' ).replace(/\n/g,'')     
		.replace(/!/g,';').replace(/StartTime=/g,'')      
		.replace(/UserName=/g,'' ).replace(/ProcessName=/g,'')
		.replace(/sessionID=/g,'' ).replace(/STATE=/g,'')
		.replace(/IdleTime=/g,'' ).replace(/LogonTime=/g,'')
		.replace(/RunTime=/g,'' ).replace(/sessionName=/g,'');
}

function convertStringToJSON(str){
	str = str.split(';')
	var msg = str;
	var arrayofObj=[];
	var obj = {};
	var numofItem=0;
	var sizeofObj =0; // (msg.length-1)/numofItem;
	var j=1,i=1;    
    // Application Data Header Parsing
    if (str[0] == 'Usage'){  
        numofItem =9;
        sizeofObj = (msg.length-1)/numofItem;
        for ( j =0; j < sizeofObj ; j++){      
            for ( i = j*numofItem+1;  i <= j*numofItem+numofItem; i++) {             
                if (i%numofItem==0){          
                    obj['elapsedTime'] = msg[i];
                }else if (i%numofItem==1){
                    obj['totalCpu'] = msg[i]
                }else if (i%numofItem==2){            
                    obj['procId'] = msg[i]
                } else if (i%numofItem==3){            
                    obj['DomainName'] = msg[i]
                } else if (i%numofItem==4){            
                    obj['username'] = msg[i]
                } else if (i%numofItem==5){            
                    obj['appName'] = msg[i]+".exe"
                } else if (i%numofItem==6){            
                    obj['appCpu'] = msg[i]
                } else if (i%numofItem==7){            
                    obj['startTime'] = msg[i]
                } else if (i%numofItem==8){            
                    obj['runTime'] = msg[i]
                }     
            }  		  
            arrayofObj[j]= Object.assign({},obj);      
        }
    }
    // Logon Data Header Parsing
    else if (str[0] == 'Logon'){
        numofItem =8;
        sizeofObj = (msg.length-1)/numofItem;
        for ( j =0; j < sizeofObj ; j++){      
            for ( i = j*numofItem+1;  i <= j*numofItem+numofItem; i++) {            
                if (i%numofItem==0){          
                    obj['accumulatedRunTime'] = msg[i];
                }else if (i%numofItem==1){
                    obj['employeeName'] = msg[i]
                }else if (i%numofItem==2){            
                    obj['sessionName'] = msg[i]
                } else if (i%numofItem==3){            
                    obj['sessionId'] = msg[i]
                }else if (i%numofItem==4){            
                    obj['STATE'] = msg[i]
                } else if (i%numofItem==5){            
                    obj['idleTime'] = msg[i]
                } else if (i%numofItem==6){            
                    obj['logonTime'] = msg[i]
                } else if (i%numofItem==7){            
                    obj['RunTime'] = msg[i]
                }              
            }  
            arrayofObj[j]= Object.assign({},obj);   
        }
    }
    var data = {
        header: str[0],
        data: arrayofObj 
    }          
	return data;
}

function tidyUsageData(arr) {
    var bulkData = []
    var currTime = new Date()
    for (var i = 0; i < arr.length; i++){
        var str = arr[i].startTime
        if (str == undefined){
          continue
        }
        var add_str = str.slice(0, 10) + ' ' + str.slice(10, str.length)
        var year = add_str.slice(6, 10)
        var month = add_str.slice(0, 2)
        var day = add_str.slice(3, 5)
        var hour = add_str.slice(11, 13)
        var minute = add_str.slice(14, 16)
        var second = add_str.slice(17)
        arr[i].startTime = new Date(year, month-1, day, hour, minute, second)
        bulkData.push({
            currTime: currTime,
            domainName: arr[i].DomainName,
            username: arr[i].username,
            appName: arr[i].appName,
            procId: arr[i].procId,
            startTime: arr[i].startTime,
            elapsedTime: arr[i].elapsedTime,
            runTime: arr[i].runTime,
            appCpu: arr[i].appCpu,
            totalCpu: arr[i].totalCpu,
            year: currTime.getUTCFullYear(),
            month: currTime.getUTCMonth() + 1,
            day: currTime.getUTCDate()
        })
    }
    var data = {
        header: "Usage",
        data: bulkData
    }
    return data
}

module.exports.parse = function(msg){
    return new Promise(function(res, rej){
        var parsed = htmlEntities(msg)
        parsed = convertStringToJSON(parsed)
        if (parsed.header == "Usage"){
            parsed = tidyUsageData(parsed.data)
        }
        res(parsed)
    })
}