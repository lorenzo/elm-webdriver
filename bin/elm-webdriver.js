#!/usr/bin/env node

process.title = 'elm-webdriver'

var path = require('path')
var fs = require('fs')
var compile = require('node-elm-compiler').compile
var spawn = require('cross-spawn')
var cl = require('chalkline');
var chalk = require('chalk');
var sanitize = require('sanitize-filename');
var mkdirp = require('mkdirp');
var cnst = require('constants');
var uuid = require('uuid');
var copydir = require('copy-dir')

var moduleRoot = path.resolve(__dirname, '..')

// Handling args like a boss
var args = require('minimist')(process.argv.slice(2), {
	alias: {
		help: 'h',
		version: 'V',
		compiler: 'c',
		port: 'p'
	},
	string: [ 'compiler', 'port' ],
	boolean: [ 'dot' ]
})

if (args.version) {
	console.log(require(path.join(moduleRoot, 'package.json')).version)
	process.exit(0)
}

if (args.help) {
	console.log('Usage:')
	console.log('')
	console.log('  elm-webdriver your/TestFile.elm [--compiler /path/to/elm-make]')
	console.log('')
	console.log('or')
	console.log('')
	console.log('  elm-webdriver init [folder]')
	console.log('')
	console.log('Options:')
	console.log('')
	console.log('  -h, --help', '    output usage information')
	console.log('  -V, --version', ' output the version number')
	console.log('  -c, --compiler', 'specify which elm-make to use')
	console.log('  -p, --port', '    specify the name of the Elm port function to subscribe to')
	console.log('  --dot', '         dot reporter')
	process.exit(0)
}


// Seriously, you need to specify which file to test
var testFile = args._[0]

if (testFile == 'init') {
	var targetDir = 'tests';
	if (1 in args._) {
		targetDir = args._[1];
	}
	var templates = path.join(moduleRoot, '/templates');
	fs.mkdirSync(targetDir)
	copydir.sync(templates, targetDir);
	process.exit(0)
}

if (!testFile) {
  testFile = 'Main.elm'
}

testFile = path.resolve(testFile)
var testDir = path.dirname(testFile)

while (!fileExists(path.join(testDir, 'elm-package.json'))) {
	testDir = path.join(testDir, '..')
}

function fileExists(filename) {
	try {
		fs.accessSync(filename)
		return true
	} catch (e) {
		return false
	}
}

var generatedFileFullPath = path.resolve(__dirname, 'elm_webdriver-' + uuid.v4() + '.test.js');

createTestFile(generatedFileFullPath)
	.then(compileTests)
	.then(run)
	.then(function () {
		process.exit(0)
	})
	.catch(function (e) {
		if (e && e !== "Failed onExit") {
			console.error(e)
		}
		process.exit(1)
	})

process.on('exit', function () { return fs.unlinkSync(generatedFileFullPath) })

// Where the magic happen
function createTestFile(outputPath) {
	return new Promise(function (resolve, reject) {
		var RDWR_EXCL = cnst.O_CREAT | cnst.O_TRUNC | cnst.O_RDWR | cnst.O_EXCL;

		fs.open(outputPath, RDWR_EXCL, function (err, fd) {
			if (err) reject(err)
			else resolve(outputPath)
		})
	})
}

function compileTests(outputPath) {
	return new Promise(function (resolve, reject) {
		compile([ testFile ], {
			output: outputPath,
			verbose: false,
			yes: true,
			spawn: function (cmd, arg, options) {
				options = options || {}
				options.cwd = testDir
				return spawn(cmd, arg, options)
			},
			pathToMake: args.compiler,
			warn: false
		}).on('close', function (exitCode) {
			if (exitCode !== 0) reject('Failed to compile tests')
			else resolve(outputPath)
		})
	})
}

function run(outputPath) {
	return new Promise(function (resolve, reject) {
		var runner = worker(require(outputPath))
		var port = getPort(runner)
		var dot = args.dot

		var context = {
			dot: dot,
			statuses: [],
			statusBars: {},
			summaries: {},
			defaultSchema: "\n:name.magenta\n :bar.green :current/:total (:percent)\n:executing",
		};

		port.subscribe(function (event) {
			switch (event.name) {
				case 'status':
					onStatus(context, event.value);
					break;
				case 'statusUpdate':
					onStatusUpdate(context, event.value);
					break;
				case 'log':
					onLog(context, event.value);
					break;
				case 'screenshots':
					onScreenshots(context, event.value);
					break;
				case 'exit':
					var success = onExit(context, event.value);
					if (success) {
						resolve(outputPath)
					} else {
						reject('Failed onExit')
					}
					break;
				default:

			}
		})
	})
}


// Create the Elm worker, testing if it has a main function
function worker(elmInstance, flags) {
	if (!elmInstance) { throw new Error('Could not find the Elm instance') }

	var keys = Object.keys(elmInstance)
	if (keys.length !== 1) {
		throw new Error('elm-ordeal can only run tests on a program with exactly one main function but your Elm instance have ' + keys.length + ' of them: ' + keys)
	}

	// FIXME support filter back
	return elmInstance[keys[0]].worker({ filter: null })
}


// Retrieve the Elm port from the worker
// Will get the one from CLI arg or, if missing, default on the only port exposed
function getPort(elmInstance) {
	var ports = Object.keys(elmInstance.ports || {})
	var portName = args.port

	if (portName === undefined) {
		if (ports.length === 0) {
			throw new Error('You main test must expose a port for elm-webdriver to send events')
		} else if (ports.length === 1) {
			portName = ports[0]
		} else {
			throw new Error('You must specify a [port] among the CLI argument to specify which one is the correct port to use')
		}
	}

	if (ports.indexOf(portName) < 0) {
		throw new Error('Your Elm port [' + portName + '] is not among the module ports: ' + ports)
	}

	return elmInstance.ports[portName]
}


// First display of a run
function onStatus(context, statuses) {
	statuses.forEach(function (status) {
		context.statuses.push(status.name)
		if (!context.dot) {
			var ProgressBar = require('ascii-progress');
			context.statusBars[status.name] = new ProgressBar({
				schema: context.defaultSchema,
				total : status.value.total
			});

			context.statusBars[status.name].tick(0, {
				name: status.name,
				executing: "→ " + status.value.nextStep
			});
		}
	});
}


// Update the display of a running run
function onStatusUpdate(context, statuses) {
	statuses
		.filter(function (status) {
			return context.statuses.includes(status.name);
		})
		.forEach(function (status) {
			if (context.dot) {
				printDot(status)
			} else {
				var bar = context.statusBars[status.name];
				var ticks =  (status.value.total - status.value.remaining) - bar.current;

				if (status.value.failed) {
					bar.setSchema(context.defaultSchema.replace(':bar.green', ':bar.red'), {
						name: status.name,
						executing: "→ " + status.value.nextStep
					});
				}

				bar.tick(ticks, {
					name: status.name,
					executing: "→ " + status.value.nextStep
				});
			}
		});
}


// Save summary
function onLog(context, summary) {
	context.summaries[summary.name] = summary;
}


// Save screenshots
function onScreenshots(context, data) {
	if (data.shots.length === 0) {
		return;
	}

	var name = sanitize(data.name);
	var dir = path.join("screenshots", name);
	mkdirp.sync(dir);

	data.shots.forEach(function (s, i) {
		fs.writeFileSync(path.join(dir, i + ".png"), new Buffer(s, 'base64'));
	});
}


// Terminate process
// Return true if all run succeeded, false otherwise
function onExit(context, summary) {
	for (name in context.summaries) {
		printSummary(context.summaries[name], context.dot);
	}

	var bg = summary.failed == 0 ? chalk.bgGreen : chalk.bgRed;
	console.log(bg(chalk.white(summary.output)))

	return summary.failed === 0
}


// Print with style a summary
function printSummary(summary, dot) {
	var name = summary.name;
	var summary = summary.value;

	console.log("\n\n");
	if (dot) {
		var fn = summary.failed > 0 ? chalk.bgRed : chalk.bgGreen;
		console.log(fn(name));
	} else {
		var fn = summary.failed > 0 ? cl.red : cl.green;
		fn();
		console.log(name);
		fn();
	}

	console.log(summary.output);
}

// Print a dot depending on status
function printDot(status) {
	var symbol = status.value.failed ? 'F':'.'
	process.stdout.write(color(status.value.failed, symbol));
}

function color(fail, symbol) {
	var col = fail ? 31 : 32;
	return `\u001b[${col}m${symbol}\u001b[0m`
}
