var fs = require('fs');
var child_process = require('child_process');

function RunATF(test_suits, test_suite_path) {
  var path = require('path');
  var atf_bin = path.resolve(__dirname + "/../../atf_bin/run");
  var test_suit_list = test_suits.split(',');
  for(var i = 0; i < test_suit_list.length; ++i) {
    var test_suit = test_suit_list[i];
    var test_cases = fs.readdirSync(test_suite_path + test_suit);
    test_cases.forEach(function(file) {
         var atf_process = child_process.spawnSync(atf_bin,
            [test_suite_path + test_suit + "/" + file]);

        process.send(atf_process.stdout + atf_process.stderr);
    });
  }
}

RunATF(process.argv[2], process.argv[3]);
