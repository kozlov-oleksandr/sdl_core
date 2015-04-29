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

/**
 * UI AJAX post requests handler
 * @param req
 * @param res
 */
controller.test_suite_config = function(req, res) {

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
        default: {
            res.status(404).end();
        }
    }
};

module.exports = controller;