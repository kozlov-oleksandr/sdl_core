/**
 * Created by amelnik on 29.04.15.
 */

var dialog = document.getElementById('overlay');

/**
 * Method to send request to server
 * @param req - request method
 * @param callback
 */
request = function(req, callback, data) {

    $.ajax({
        type: 'POST',
        data: JSON.stringify({
            "objectData": req,
            "data": data
        }),
        contentType: 'application/json',
        url: 'http://localhost:3000/test_suite_config',
        success: callback
    });
};

updateTestSuiteDescription = function(value){
    console.log(value);
    request('test_suite_description', function(res){

            var result = res[0] + '\n';

            for(var i = 1; i < res.length; i++){
                result += " - " + res[i] + '\n'
            }
            $('#description').val(result);
        },
        value
    );
};

updateTestSuiteList = function(value){

    $('#test_suite_list').empty();
    $('#list_of_suits').empty();

    request('test_suite_list', function(res){

        for (var i = 0; i < res.length; i++) {
            $('#test_suite_list')
                .append($("<option></option>")
                    .attr("value", res[i])
                    .text(res[i]));
            $('#list_of_suits')
                .append($("<input/>")
                    .attr({
                        type: "checkbox",
                        value: res[i],
                        checked: true}))
                .append(res[i])
                .append($("<br/>"));
        }
    });
};

/**
 * Test suite list select changes handler
 * Requests test suite description data from server
 * and update description test suite textarea
 */
$('#test_suite_list').change(function() {
    updateTestSuiteDescription(this.value);
});

/**
 * Update test suite list button handler
 * Requests updated lists data and update view
 */
$('#update_list').click(function(){
    updateTestSuiteList();
    updateTestSuiteDescription();
});

$('#start_atf').click(function() {
    var test_suits = [];
    $("input[type=checkbox]").each(function() {
        if(this.checked) {
            test_suits.push(this.value);
            console.log(this.value);
        }
    });
    request('start_atf', function(res){
        $('#log').val(res);
        $('#stop_atf').removeAttr('disabled');
        $('#start_atf').attr('disabled', 'disabled');
    },
    {
        "test_suits": test_suits
    });
});

$('#stop_atf').click(function() {
    request('stop_atf', function(res){
        $('#stop_atf').attr('disabled', 'disabled');
        $('#start_atf').removeAttr('disabled');
        $('#clean_sdl').removeAttr('disabled');
    });
});

$('#clean_sdl').click(function() {
    request('stop_sdl', function(res) {
        $('#clean_sdl').attr('disabled', 'disabled');
    });
});

/**
 * Test suite list select changes handler
 * Requests test suite description data from server
 * and update description test suite textarea
 */
$('#test_suite_add').click(function() {
    dialog.showModal();

    request('test_cases_list', function(res){
        console.log(res);

        for (var i = 0; i < res.length; i++) {
            $('#list_of_tests')
                .append($("<input/>")
                    .attr({
                        type: "checkbox",
                        value: res[i],
                        checked: true}))
                .append(res[i])
                .append($("<br/>"));
        }
    });
});

function finishAddSuite() {
    $('#list_of_tests').empty();
    document.getElementById("test_suit_name").value = '';
    dialog.close();
}

$('#add_test_suit_btn').click(function() {

    var test_scripts = [];
    $("input[type=checkbox]").each(function() {
        if(this.checked) {
            test_scripts.push(this.value);
            console.log(this.value);
        }
    });

    var folder = document.getElementById("test_suit_name").value;

    console.log('Trying to send request add_test_suit');

    request(
        'add_test_suit',
        finishAddSuite(),
        {
            "folder_name": folder,
            "test_scripts": test_scripts
        }
    );

});

$('#cancel_test_suit').click(function() {
    finishAddSuite();
});
