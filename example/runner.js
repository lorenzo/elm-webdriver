var elm = require('./main.js');

var main = elm.Main.worker();

setTimeout(function(){ main.ports.begin.send("Hola") }, 0);
