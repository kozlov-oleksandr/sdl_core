var express = require('express');
var controller = {};

/**
 * Method to save configuration data from config.jade view
 * to /tmp/config.json
 * @param req
 * @param res
 */
controller.saveConfiguration = function(req, res) {

    var fs = require("fs");

    // SYNC method to write configuration data to FS
    fs.writeFileSync(
        "/tmp/config.json",
        JSON.stringify( req.body ),
        "utf8"
    );

    // SYNC method
    var data = fs.readFileSync('/tmp/config.json', 'utf8');

    // Added verification for saved configuration on file system with data from filled form of config.jade view
    // Verification is comparison of read data from FS and converted data object to string
    if (JSON.stringify( req.body ) === data) {

        req.app.locals.mainConfig = JSON.parse(data);
        console.log(req.app.locals.mainConfig);
        console.log("Data saved successfully...................");
        // Go to next configuration view 'test_suite'
        console.log("Test suite rendered...................");
    } else {
        console.log("Data wasn't saved successfully...................");
        // Go to start page
        console.log("Index rendered...................");
    }

    res.redirect("back");
};

controller.saveConfiguration = function(req) {
    var fs = require("fs");

    // SYNC method to write configuration data to FS
    fs.writeFileSync(
        "/tmp/config.json",
        JSON.stringify( req.app.locals.mainConfig ),
        "utf8"
    );
}

/**
 * Method to load configuration view test_suite.jade
 *
 * @param req
 * @param res
 */
controller.testSuiteRun = function(req, res) {

    res.render('test_suite', {
        title: 'Test suite',
        config: req.app.locals.mainConfig
    });
};

function logAndSendError(response, log_string, error) {
    console.log(log_string + error);
    response.status(500).end();
}

/**
 * UI AJAX post requests handler
 * @param req
 * @param res
 */
controller.test_suite_config = function(req, res) {
    var fs = require("fs");
    switch (req.body.objectData) {
        case 'test_suite_list' : {
            console.log('Received request test_suite_list................');
            res.status(201).send(['test suite1', 'test suite2', 'test suite3']);
            break;
        }
        case 'test_suite_description' : {
            console.log('Received request test_suite_description................');
            res.status(201).send('as\ndasd \nas\nd \nas\nd a\nsd\n a\nsd \nasd \n as\nda\nsd\nas\ndas\ndsd\nasdds');
            break;
        }
        case 'add_test_suit' : {
            console.log('Received request to add new test suit with scripts: ' + req.body.test_scripts);
            var path = __dirname + "/../testsuits/" + req.body.folder_name + "/";
            console.log('path ' + path);
            fs.mkdir(path, function(err) {
                    if (err && err.code != 'EEXIST') {
                        logAndSendError(res, 'Failed to create/read test suit directory ' + req.body.folder_name, err);
                        return;
                    } else {
                        if (!req.app.locals.mainConfig.testsuits) {
                            req.app.locals.mainConfig.testsuits = [];
                        }
                        var test_suit = {};
                        test_suit[req.body.folder_name] = [];
                        var files = req.body.test_scripts;
                        for (var i = 0; i < files.length; ++i) {
                            var input_stream = fs.createReadStream('/tmp/uploads/' + files[i]);
                            var error = null;
                            input_stream.on('error', function (err) {
                                logAndSendError(res, "Failed to open script file " + files[i] + " with error: " , err);
                                error = err;
                                return;
                            });
                            var output_stream = fs.createWriteStream(path + files[i]);
                            output_stream.on('error', function(err) {
                                logAndSendError(res, "Failed to open destination script file " + files[i] + " with error: ",
                                                err);
                                error = err;
                                return;
                            });
                            if (error === null) {
                                input_stream.pipe(output_stream);
                                test_suit[req.body.folder_name].push(files[i]);
                            }
                        }
                        req.app.locals.mainConfig.testsuits.push(test_suit);
                        controller.saveConfiguration(req);
                        res.status(201).send();
                    }
            });
            break;
        }
        default: {
            res.status(404).end();
        }
    }
};

module.exports = controller;
