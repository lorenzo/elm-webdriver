var elm = require('./main.js');

var main = elm.Main.worker();

main.ports.printLog.subscribe(function (summary) {
  console.log(summary.output);

  if (summary.failed > 0) {
    process.exit(1);
  }

  process.exit(0);
});

setTimeout(function(){ main.ports.begin.send("Hola") }, 0);
