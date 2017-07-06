//= require jquery
//= require jquery_ujs
//= require jquery.growl
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree ./common

$(function() {
  if($('#paypal-button-container').length > 0) {
    paypal.Button.render({
      env: 'sandbox', // sandbox | production
      // Show the buyer a 'Pay Now' button in the checkout flow
      commit: true,
      // payment() is called when the button is clicked
      payment: function() {
          // Set up a url on your server to create the payment
          var CREATE_URL = '/orders/';

          // Make a call to your server to set up the payment
          return paypal.request.post(CREATE_URL)
              .then(function(res) {
                return res.paymentID;
              });
      },

      // onAuthorize() is called when the buyer approves the payment
      onAuthorize: function(data, actions) {
          // Set up a url on your server to execute the payment
          var EXECUTE_URL = '/orders/pay';
          // // Set up the data you need to pass to your server
          // var data = {
          //     paymentID: data.paymentID,
          //     payerID: data.payerID
          // };

          // // Make a call to your server to execute the payment
          return paypal.request.post(EXECUTE_URL, data)
              .then(function (res) {
                  window.alert('Payment Complete!');
              });
          // return actions.redirect();

      }
    }, '#paypal-button-container');
  }
})
