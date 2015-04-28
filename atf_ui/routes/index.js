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
    res.render('test_suite', { title: 'Test suite', config: req.app.locals.mainConfig });
});

/* POST main configuration page form submit handler. */
router.post('/save', function(req, res, next) {
    controller.saveConfiguration(req, res);
});

module.exports = router;