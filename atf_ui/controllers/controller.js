var express = require('express');
var controller = {};

controller.saveConfiguration = function(data, res) {

    // Writing...
    var fs = require("fs");

    fs.writeFile(
        __dirname + "config.json",
        JSON.stringify( data ),
        "utf8",
        function(){ // callback function
            mainConfig = require(__dirname + "config.json");
            res.render('test_suite', { title: 'Test suite'});
        }
    );

    // And then, to read it...
    //mainConfig = require("./config.json");
};

module.exports = controller;