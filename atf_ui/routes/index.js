var express = require('express');
var router = express.Router();
var controller = require('../controllers/controller.js');

/* GET home page. */
router.get('/', function(req, res, next) {
    res.render('index', { title: 'Express' });
});

/* GET main configuration page. */
router.get('/config', function(req, res, next) {
    res.render('config', { title: 'ATF Configuration', config: req.app.locals.mainConfig });
});

/* GET test suite configuration page. */
router.get('/test_suite', function(req, res, next) {
    controller.testSuiteRun(req, res);
});

/* GET test suite configuration page. for post ajax requests from UI*/
router.post('/test_suite_config', function(req, res, next) {
    controller.test_suite_config(req, res);
});

/* POST main configuration page form submit handler. */
router.post('/save', function(req, res, next) {

    console.log("Save Configuration enter1...................");
    controller.saveConfiguration(req, res);
});

/* POST main configuration page form submit handler. */
router.post('/upload', function(req, res, next) {
    console.log('TRYING TO UPLOAD................');
    console.log(req.body);
    console.log(req.files);
    res.redirect("back");
});

module.exports = router;