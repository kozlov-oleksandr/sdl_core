var express = require('express');
var router = express.Router();
var controller = require('../controllers/controller.js');

/* GET home page. */
router.get('/', function(req, res, next) {
    res.render('index', { title: 'Express' });
});

/* GET main configuration page. */
router.get('/config', function(req, res, next) {
    res.render('config', { title: 'ATF Configuration' });
});

/* GET test suite configuration page. */
router.get('/test_suite', function(req, res, next) {
    res.render('test_suite', { title: 'Test suite' });
});

/* GET test suite configuration page. */
router.post('/save', function(req, res, next) {
    console.log(req.body);
    controller.saveConfiguration(req.body, res);
    //res.render('test_suite', { title: 'Test suite'});
    //res.send('Received data: ' + JSON.stringify(req.body));
});

module.exports = router;