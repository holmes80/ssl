var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'Node Server',
  description: 'server to handle slot booking.',
  script: 'C:\\RemoteSessionManagerV0.2\\server.js'
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
});

svc.install();