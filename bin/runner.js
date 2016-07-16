var cl = require('chalkline');
var chalk = require('chalk');

if (process.argv.length < 3) {
  throw 'A path to an Elm-compiled file is required';
}

var elm = require(process.argv[2]);

if (typeof elm === 'undefined') {
  throw 'Invalid Elm file. Make sure you provide a file compiled by Elm!'
}

if (typeof elm.Main === 'undefined' ) {
  throw 'Main is not defined. Make sure your module is named Main.'
}

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
