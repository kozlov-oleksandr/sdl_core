/**
 * Created by amelnik on 21.05.15.
 */

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
        url: 'http://localhost:3000/login',
        success: callback
    });
};

$('#enter').click(function(){

    request(
        'login',
        function(data){
            if (data === 'new user') {
                $('#config').removeClass('disabled');
                $('#test_suite').removeClass('disabled');
            }
        },
        $('#sing_in').val()
    );
});