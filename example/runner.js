var cl = require('chalkline');
var chalk = require('chalk');
var elm = require('./main.js');

var main = elm.Main.worker();

main.ports.printLog.subscribe(function (summary) {
  var name = summary[0];
  var summary = summary[1];
  var fn = summary.failed > 0 ? cl.red : cl.green;


  fn();
  console.log(name);
  fn();

  console.log(summary.output);
});

main.ports.exit.subscribe(function (summary) {
  var bg = summary.failed == 0 ? chalk.bgGreen : chalk.bgRed;

  console.log(bg(chalk.white(summary.output)))

  if (summary.failed > 0) {
    process.exit(1);
  }

  process.exit(0);
});
