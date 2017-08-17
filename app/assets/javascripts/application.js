//= require jquery
//= require jquery_ujs
//= require jquery.growl
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree ./common

$(function() {
    // Set up a url on your server to create the payment
    var CREATE_URL = '/orders/';

    $("#pay").click(function() {
        // Make a call to your server to set up the payment
        paypal.request.post(CREATE_URL).then(function(res) {
            console.log(res);
            window.open(res["approval_url"], "myWindow", "width=800,height=600");
        });
    });

})
