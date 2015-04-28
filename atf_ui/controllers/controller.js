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

module.exports = controller;