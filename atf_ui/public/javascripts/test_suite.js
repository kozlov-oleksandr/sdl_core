/**
 * Created by amelnik on 29.04.15.
 */

/**
 * Method to send request to server
 * @param req - request method
 * @param callback
 */
request = function(req, callback) {

    $.ajax({
        type: 'POST',
        data: JSON.stringify({ "objectData": req}),
        contentType: 'application/json',
        url: 'http://localhost:3000/test_suite_config',
        success: callback
    });
};

/**
 * Test suite list select changes handler
 * Requests test suite description data from server
 * and update description test suite textarea
 */
$('#test_suite_list').change(function() {
    request('test_suite_description', function(res){
        $('#description').val(res);
    });
});

/**
 * Update test suite list button handler
 * Requests updated lists data and update view
 */
$('#update_list').click(function(){
    request('test_suite_list', function(res){

        for (var i = 0; i < res.length; i++) {
            $('#test_suite_list')
                .append($("<option></option>")
                    .attr("value", res[i])
                    .text(res[i]));
        }
    });
});