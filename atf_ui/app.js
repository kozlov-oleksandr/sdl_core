var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var expressSession = require('express-session');
var bodyParser = require('body-parser');
var multer  = require('multer');

var routes = require('./routes/index');
var users = require('./routes/users');
var controller = require('./controllers/controller.js');
var fs = require('fs');

var app = express();

/**
 * ASYNC method of read configuration data from FS
 *
 * Used app.locals to share variables data access for routes namespace
 */
fs.readFile('/tmp/config.json', 'utf8', function (err, data) {
    if (err) {
        console.log("No predefined configuration found...................");
        app.locals.mainConfig = null;


        //data = {file_path: '',
        //        hb_timeout: '',
        //        testRecord_path: '',
        //        MOB_connection_str: '',
        //        HMI_connection_str: '',
        //        PerfLog_connection_str: '',
        //        launch_time: '',
        //        terminal_name: '',
        //        SDLStoragePath: ''
        //};

        if (fs.writeFileSync("/tmp/config.json", JSON.stringify(app.locals.mainConfig), "utf8")) {
            console.log("ERROR: The configuration file was not created!..................");
            console.log(app.locals.mainConfig);
        } else {
            console.log("The configuration file was created successfuly!..................");
            console.log(app.locals.mainConfig);
        }

        return;
    }
    app.locals.mainConfig = JSON.parse(data);
    console.log(app.locals.mainConfig);
    console.log("Configuration read successful...................");
});

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(expressSession({secret:'somesecrettokenhere'}));
app.use(express.static(path.join(__dirname, 'public')));
app.use(multer({
    dest: '/tmp/uploads/',
    //rename to original file name
    rename: function (fieldname, filename) {
        return filename; //return name
    }
}));

app.use('/', routes);
app.use('/users', users);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});

controller.init();

module.exports = app;
