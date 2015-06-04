var express = require('express');
var child_process = require('child_process');
var fs = require("fs");
var WebSocketServer = require('ws');
var psTree = require('ps-tree');
var config = require("./config.js");

var controller = {
    atf_process: null,
    sdl_process: null,
    atf_path: __dirname + "/../../atf_bin/",
    log_error: "ERROR: ",
    log_warn: "WARNING: ",
    log_debug: "DEBUG: "
};

var uploadPath = '/tmp/uploads/';
var testSuitePath = '/tmp/testsuits/';

controller.init = function(){

    try {
        fs.mkdirSync(testSuitePath);
    } catch(e) {
        if ( e.code != 'EEXIST' ) throw e;
    }
    try {
        fs.mkdirSync(uploadPath);
    } catch(e) {
        if ( e.code != 'EEXIST' ) throw e;
    }
    try {
        fs.mkdirSync(controller.atf_path + "files/");
    } catch(e) {
        if ( e.code != 'EEXIST' ) throw e;
    }


// connected clients
    controller.clients = {};
    controller.clients[0] = {};

// WebSocket-server on port 8081
    var SDLLogServer = new WebSocketServer.Server({
        port: 8081
    });
    var ATFLogServer = new WebSocketServer.Server({
        port: 8082
    });

    SDLLogServer.on('connection', function(ws) {

        console.log(controller.clients);
        controller.clients[0].sdl = ws;
        console.log("SDLLogServer New connection established.");

        ws.on('message', function(message) {
            console.log('SDLLogServer Got message:  ' + message);

            controller.clients[0].sdl.send(message);
        });

        ws.on('close', function() {
            console.log('SDLLogServer Connection closed.');
            delete controller.clients[0];
        });

    });

    ATFLogServer.on('connection', function(ws) {

        controller.clients[0].atf = ws;
        console.log("ATFLogServer New connection established.");

        ws.on('message', function(message) {
            console.log('ATFLogServer Got message:  ' + message);

            controller.clients[0].atf.send(message);
        });

        ws.on('close', function() {
            console.log('ATFLogServer Connection closed.');
            delete controller.clients[0];
        });

    });
};

controller.copyAdditionalFiles = function() {
    fs.readdir(uploadPath, function(err, files) {
        if(err) {
            console.log(controller.log_error +
            "failed to read uploaded files directory. " + err);
            return;
        }
        files = files.filter(function(file) {
            return !(file === '.' || file === '..'
            || require("path").extname(file) === '.lua');
        });
        files.forEach(function(file) {
            require('child_process').spawn('mv', [uploadPath + file, controller.atf_path + "files/"]);
        });
    });
};

controller.listOfTestSuits = function() {
    var results = [];
    var list = fs.readdirSync(testSuitePath);
    list.forEach(function(file) {
        filePath = testSuitePath + file;
        var stat = fs.statSync(filePath);
        if (stat && stat.isDirectory()) {
            results.push(file);
        }
    });
    return results;
}

controller.listOfTestCases = function(testCasesPath) {
    var results = [];

    var list = fs.readdirSync(testCasesPath);
    list.forEach(function(file) {
        filePath = testCasesPath + file;
        var stat = fs.statSync(filePath);
        if (!(stat && stat.isDirectory()) && require('path').extname(file) === '.lua') {
            results.push(file);
        }
    });
    return results;
}

controller.newUser = function(req, res) {
    switch (req.body.objectData) {
        case 'login' :
        {
            console.log('Received request login................');
            console.log('User Name is................' + req.body.data);
            console.log('MainConfig is................');
            console.log(req.app.locals.mainConfig);

            req.session.userName = req.body.data;

            if (req.app.locals.mainConfig === null) {
                req.app.locals.mainConfig = {};
            }
            if (!(req.body.data in req.app.locals.mainConfig)) {
                req.app.locals.mainConfig[req.body.data] = new config.Config();
            }

            console.log('MainConfig is................');
            console.log(req.app.locals.mainConfig);

            res.status(201).send('new user');
            break;
        }
        default:
        {
            console.log('Undefined route: ' + req.body.objectData);
            res.status(404).end();
        }
    }
};

/**
 * Method to save configuration data from config.jade view
 * to /tmp/config.json
 * @param req
 * @param res
 */
controller.saveConfiguration = function(req, res) {

    console.log("Save Configuration enter...................");

    console.log("User Name " + req.session.userName);

    req.app.locals.mainConfig[req.session.userName] = req.body;
    config.updateATFConfig(req.app.locals.mainConfig[req.session.userName]);

    console.log("MainConfig is...........");
    console.log(req.app.locals.mainConfig);

    // SYNC method to write configuration data to FS
    var result = fs.writeFileSync(
        "/tmp/config.json",
        JSON.stringify( req.app.locals.mainConfig ),
        "utf8"
    );

    if (result) {
        console.log("ERROR: File was not writed to FS...................");
    } else {
        console.log("File writed to FS...................");
    }

    // SYNC method
    var data = fs.readFileSync('/tmp/config.json', 'utf8');

    // Added verification for saved configuration on file system with data from filled form of config.jade view
    // Verification is comparison of read data from FS and converted data object to string
    if (JSON.stringify( req.app.locals.mainConfig ) === data) {

        console.log(req.app.locals.mainConfig);
        console.log("Data saved successfully...................");
        // Go to next configuration view 'test_suite'
        console.log("Test suite rendered...................");
    } else {

        console.log(data);
        console.log(JSON.stringify( req.app.locals.mainConfig ));

        console.log("Data wasn't saved successfully...................");
        // Go to start page
        console.log("Index rendered...................");
    }


    res.redirect("back");
};

/**
 * Method to load configuration view test_suite.jade
 *
 * @param req
 * @param res
 */
controller.testSuiteRun = function(req, res) {

    res.render('test_suite', {
        title: 'Test suite',
        config: req.app.locals.mainConfig[req.session.userName]
    });
};

function logAndSendError(response, log_string, error) {
    console.log(log_string + error);
    //response.status(500).end();
}

function killTreeProcesses (pid, signal, callback) {
    signal   = signal || 'SIGHUP';
    callback = callback || function () {};
    psTree(pid, function (err, children) {
        [pid].concat(
            children.map(function (p) {
                return p.PID;
            })
        ).forEach(function (tpid) {
            try { process.kill(tpid, signal) }
            catch (ex) { }
        });
        callback();
    });
};


/**
 * UI AJAX post requests handler
 * @param req
 * @param res
 */
controller.test_suite_config = function(req, res) {
    var fs = require("fs");
    var results = [];
    var path = '';
    var list;
    var filePath;
    var currentTestSuite;

    console.log(req.body.objectData, "request received................");

    switch (req.body.objectData) {
        case 'test_cases_list' : {
            console.log('Received request test_cases_list................');
            var results = controller.listOfTestCases(uploadPath);
            res.status(201).send(results);
            break;
        }
        case 'test_cases_in_suit' : {
            var results = this.listOfTestCases(testSuitePath + req.body.data.test_suit + "/");
            res.status(201).send(results);
            break;
        }
        case 'test_suite_list' : {
            console.log('Received request test_suits_list................');

            var results = this.listOfTestSuits();
            res.status(201).send(results);
            break;
        }
        case 'test_suite_description' : {
            console.log('Received request test_suite_description................');

            if(req.body.data){
                currentTestSuite = req.body.data;
            } else {
                list = fs.readdirSync(testSuitePath);
                currentTestSuite = list[0];
            }

            var path = testSuitePath + currentTestSuite;
            var results = [];
            results.push("Test suite " + req.body.data);
            results += this.listOfTestCases(path);

            res.status(201).send(results);
            break;
        }
        case 'start_atf' : {
            console.log('Received request to run ATF for testsuits: ' + req.body.data.test_suits);
            this.copyAdditionalFiles();

            var test_suits = req.body.data.test_suits;

            console.log(req.app.locals.mainConfig[req.session.userName]);

            if (!req.app.locals.mainConfig[req.session.userName].file_path) {
                logAndSendError(res, "Path to SDL is not set");
            } else {
                if (!this.sdl_process) {
                    console.log("Start SDL.............");

                    var proc = child_process.exec;

                    this.sdl_process = proc(req.app.locals.mainConfig[req.session.userName].file_path,
                        {'cwd': require('path').dirname(req.app.locals.mainConfig[req.session.userName].file_path)});

                    this.sdl_process.stdout.on('data', function (data) {
                        controller.clients[0].sdl.send(data);
                    });

                    this.sdl_process.stderr.on('data', function (data) {
                        controller.clients[0].sdl.send(data);
                    });

                    this.sdl_process.on('exit', function (code) {
                        controller.clients[0].sdl.send(code);
                    });
                }
            }

            // Silent needed to handle logs from child process
            this.atf_process = child_process.fork(
                __dirname + '/run_atf.js',
                [test_suits, testSuitePath],
                {
                    silent:true
                }
            );

            this.atf_process.on('message', function(m) {
                controller.clients[0].atf.send('' + m);
            });

            this.atf_process.stdout.on('data', function (data) {
                controller.clients[0].atf.send('' + data);
            });

            this.atf_process.stderr.on('data', function (data) {
                controller.clients[0].atf.send('' + data);
            });

            this.atf_process.on('exit', function (code) {
                controller.clients[0].atf.send('child process exited with code ' + code);
            });

            this.atf_process.on('close', function (code) {
                controller.clients[0].atf.send('child process exited with code ' + code);
                controller.atf_process = null;
            });

            res.status(201).send("Done");

            break;
        }
        case 'stop_atf' : {
            if (this.atf_process) {
                killTreeProcesses(this.atf_process.pid, 'SIGHUP', function(){
                    controller.atf_process = null;
                    res.status(201).send();
                });
            }
            break;
        }
        case 'stop_sdl' : {
            if (this.sdl_process && !this.atf_process) {
                killTreeProcesses(this.sdl_process.pid, 'SIGHUP', function(){
                    controller.sdl_process = null;
                    res.status(201).send();
                });
            }
            break;
        }
        case 'add_test_suit' : {
            console.log('Received request to add new test suit with scripts: ' + req.body.data.test_scripts);
            var path = testSuitePath + req.body.data.folder_name + "/";
            console.log('path ' + path);
            fs.mkdirSync(path, function(err) {
                    if (err && err.code != 'EEXIST') {
                        logAndSendError(res, 'Failed to create/read test suit directory ' + req.body.data.folder_name, err);
                        res.status(201).send();
                        return;
                    }});

            for(var i = 0; i < req.body.data.test_scripts.length; i++){

                child_process.spawn('mv', [uploadPath + req.body.data.test_scripts[i], path]);

            }
            break;
        }
        case 'edit_test_suit': {
            var oldTestSuit = req.body.data.old_test_suit;
            var newTestSuit = req.body.data.test_suit;
            if (oldTestSuit !== newTestSuit) {
                fs.renameSync(testSuitePath + oldTestSuit, testSuitePath + newTestSuit);
            }
            var list = fs.readdirSync(testSuitePath + newTestSuit);
            var scripts = req.body.data.test_scripts;
            list.forEach(function(file) {
                if (-1 === scripts.indexOf(file)) {
                    fs.unlinkSync(testSuitePath + newTestSuit + "/" + file);
                }
            });
            for(testCase in scripts) {
                if (-1 === list.indexOf(scripts[testCase])) {
                    child_process.spawn('mv', [uploadPath + scripts[testCase], testSuitePath + newTestSuit + "/"]);
                }
            }
            res.status(201).send(this.listOfTestSuits());
            break;
        }
        case 'delete_test_suit': {
            var path = testSuitePath + req.body.data.test_suit + "/";
            child_process.exec( 'rm -r ' + path, function ( err, stdout, stderr ){
                if (!err) {
                    res.status(201).send(controller.listOfTestSuits());
                }
            });
            break;
        }
        default: {
            console.log('Undefined route: ' + req.body.objectData);
            res.status(404).end();
        }
    }
};

module.exports = controller;
