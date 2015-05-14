var express = require('express');
var controller = {};
var fs = require("fs");

var uploadPath = '/tmp/uploads/';
var testSuitePath = '/tmp/testsuits/';

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



/**
 * Method to save configuration data from config.jade view
 * to /tmp/config.json
 * @param req
 * @param res
 */
controller.saveConfiguration = function(req, res) {

    console.log("Save Configuration enter...................");

    // SYNC method to write configuration data to FS
    fs.writeFileSync(
        "/tmp/config.json",
        JSON.stringify( req.body ),
        "utf8"
    );
    console.log("File writed to FS...................");

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
    //response.status(500).end();
}

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
    console.log(req.body.data, "data received................");

    switch (req.body.objectData) {
        case 'test_cases_list' : {
            console.log('Received request test_cases_list................');

            results = [];
            list = fs.readdirSync(uploadPath);
            list.forEach(function(file) {
                filePath = uploadPath + file;
                var stat = fs.statSync(filePath);
                if (!(stat && stat.isDirectory())) {
                    results.push(file);
                }
            });

            res.status(201).send(results);
            break;
        }
        case 'test_suite_list' : {
            console.log('Received request test_suits_list................');

            results = [];
            list = fs.readdirSync(testSuitePath);
            list.forEach(function(file) {
                filePath = testSuitePath + file;
                var stat = fs.statSync(filePath);
                if (stat && stat.isDirectory()) {
                    results.push(file);
                }
            });

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

            path = testSuitePath + currentTestSuite;
            list = fs.readdirSync(path);
            results = [];

            results.push("Test suite " + req.body.data);

            list.forEach(function(file) {
                filePath = path + "/" + file;
                console.log(filePath);
                var stat = fs.statSync(filePath);
                if (!(stat && stat.isDirectory())) {
                    results.push(file);
                }
            });

            res.status(201).send(results);
            break;
        }
        case 'add_test_suit' : {

            console.log('Received request to add new test suit with scripts: ' + req.body.data.test_scripts);
            path = "/tmp/testsuits/" + req.body.data.folder_name + "/";
            console.log('path ' + path);
            fs.mkdirSync(path, function(err) {
                    if (err && err.code != 'EEXIST') {
                        logAndSendError(res, 'Failed to create/read test suit directory ' + req.body.data.folder_name, err);
                        res.status(201).send();
                        return;
                    }});

            for(var i = 0; i < req.body.data.test_scripts.length; i++){

                require('child_process').spawn('mv', [uploadPath + req.body.data.test_scripts[i], path]);

            }

            break;
        }
        default: {
            console.log('Undefined route: ' + req.body.objectData);
            res.status(404).end();
        }
    }
};

module.exports = controller;
