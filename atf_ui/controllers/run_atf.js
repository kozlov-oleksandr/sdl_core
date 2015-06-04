var fs = require('fs');
var child_process = require('child_process');

function RunATF(test_suits, test_suite_path) {
    var path = require('path');
    var atf_bin_folder = path.resolve(__dirname + "/../../atf_bin");
    var atf_bin = atf_bin_folder + "/run";
    var test_suit_list = test_suits.split(',');

    for(var i = 0; i < test_suit_list.length; ++i) {
        var test_suit = test_suit_list[i];
        var test_cases = fs.readdirSync(test_suite_path + test_suit);

        test_cases.forEach(function(file) {

            console.log('Executed ' + atf_bin + ' with script: ' + test_suite_path + test_suit + "/" + file);

            //var atf_process = child_process.spawnSync(atf_bin,
            //    [test_suite_path + test_suit + "/" + file],
            //    {
            //        cwd: '/home/amelnik/rep/sdl-core/atf_bin/'
            //    }
            //);



            try {
                var history = child_process.execSync(atf_bin + " " + test_suite_path + test_suit + "/" + file,
                    {'cwd': atf_bin_folder});
                console.log('HISTORY! ' + history);
                process.send('' + history);
            } catch (err) {
                console.log('Error --------- ' + err);
            }

            //console.log("ATF LOG FROM run_atf.js - " + atf_process.stdout.toString());

            // All console.log output will be redirected to parent process
            // that will handle logs via process.stdout and process.stderr
            //atf_process.stdout.on('data', function (data) {
            //    console.log('stdout: ' + data);
            //});
            //
            //atf_process.stderr.on('data', function (data) {
            //    console.error('stderr: ' + data);
            //});
            //
            //atf_process.on('exit', function (code) {
            //    console.log('child process exited with code: ' + code);
            //});

        });
    }
}

RunATF(process.argv[2], process.argv[3]);
