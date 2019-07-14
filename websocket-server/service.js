var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'ws-server-new',
  description: 'server to handle slot booking.',
  script: 'C:\\websocket-server\\index.js'
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
});

svc.install();