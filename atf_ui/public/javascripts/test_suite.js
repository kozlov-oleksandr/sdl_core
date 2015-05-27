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

$( document ).ready(function() {
    updateTestSuiteList();
});

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
        $('#stop_atf').removeAttr('disabled');
        $('#start_atf').attr('disabled', 'disabled');

            var socketSDL = new WebSocket("ws://localhost:8081");

            var socketATF = new WebSocket("ws://localhost:8082");


            socketSDL.onopen = function() {
                $("#sdl_log").append("Connection established.");
                $('#sdl_log').scrollTop($('#sdl_log')[0].scrollHeight - $('#sdl_log').height());
            };

            socketSDL.onclose = function(event) {
                if (event.wasClean) {
                    $("#sdl_log").append('Connection closed clean.');
                } else {
                    $("#sdl_log").append('Connection abort.'); // например, "убит" процесс сервера
                }
                $("#sdl_log").append('Code: ' + event.code + ' reason: ' + event.reason);
                $('#sdl_log').scrollTop($('#sdl_log')[0].scrollHeight - $('#sdl_log').height());
            };

            socketSDL.onmessage = function(event) {
                $("#sdl_log").append(event.data);
                $('#sdl_log').scrollTop($('#sdl_log')[0].scrollHeight - $('#sdl_log').height());
            };

            socketSDL.onerror = function(error) {
                $("#sdl_log").append("Error " + error.message);
                $('#sdl_log').scrollTop($('#sdl_log')[0].scrollHeight - $('#sdl_log').height());
            };

            socketATF.onopen = function() {
                $("#atf_log").append("Connection established.");
                $('#atf_log').scrollTop($('#atf_log')[0].scrollHeight - $('#atf_log').height());
            };

            socketATF.onclose = function(event) {
                if (event.wasClean) {
                    $("#atf_log").append('Connection closed clean.');
                } else {
                    $("#atf_log").append('Connection abort.'); // например, "убит" процесс сервера
                }
                $("#atf_log").append('Code: ' + event.code + ' reason: ' + event.reason);
                $('#atf_log').scrollTop($('#atf_log')[0].scrollHeight - $('#atf_log').height());
            };

            socketATF.onmessage = function(event) {
                console.log(event.data);
                $("#atf_log").append(event.data);
                $('#atf_log').scrollTop($('#atf_log')[0].scrollHeight - $('#atf_log').height());
            };

            socketATF.onerror = function(error) {
                console.log(event.data);
                $("#atf_log").append("Error " + error.message);
                $('#atf_log').scrollTop($('#atf_log')[0].scrollHeight - $('#atf_log').height());
            };
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

function finishAddSuite(success) {
    $('#list_of_tests').empty();
    var new_test_suit = document.getElementById("test_suit_name").value;
    document.getElementById("test_suit_name").value = '';
    dialog.close();
    if (success) {
        $('#test_suite_list')
                .append($("<option></option>")
                    .attr("value", new_test_suit)
                    .text(new_test_suit));
            $('#list_of_suits')
                .append($("<input/>")
                    .attr({
                        type: "checkbox",
                        value: new_test_suit,
                        checked: true}))
                .append(new_test_suit)
                .append($("<br/>"));
    }
}

$('#add_test_suit_btn').click(function() {

    var test_scripts = [];
    $('#list_of_tests').children("input").each(function() {
        if(this.checked) {
            test_scripts.push(this.value);
        }
    });

    var folder = document.getElementById("test_suit_name").value;

    request(
        'add_test_suit',
        finishAddSuite(true),
        {
            "folder_name": folder,
            "test_scripts": test_scripts
        }
    );

});

$('#cancel_test_suit').click(function() {
    finishAddSuite(false);
});

$("#colorScheme").spectrum({
    showAlpha: true
});

$('.sp-choose').click(function(){
    var styles = {
        backgroundColor : $("#colorScheme").spectrum("get").toRgbString()
    };
    $( '#test_suite_configuration_container' ).css( styles );
});