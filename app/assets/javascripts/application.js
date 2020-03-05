//= require jquery
//= require jquery_ujs
//= require jquery.growl
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree ./common

$(function() {
  if($('#paypal-button-container').length > 0) {
    // paypal.Button.render({
    //   style: {
    //     color: 'silver',
    //     shape: 'pill',
    //     label: 'generic',
    //     tagline: false
    //   },
    //   env: 'sandbox', // sandbox | production
    //   // Show the buyer a 'Pay Now' button in the checkout flow
    //   commit: true,
    //   // payment() is called when the button is clicked
    //   payment: function() {
    //       return paypal.request.post('/orders')
    //           .then(function(res) {
    //             return res.id;
    //           });
    //   },
    //   // onAuthorize() is called when the buyer approves the payment
    //   onAuthorize: function(data, actions) {
    //       return paypal.request.post('/orders/' + data.orderID + '/capture', {})
    //           .then(function (res) {
    //               console.log('Payment Complete!');
    //           });
    //   }
    // }, '#paypal-button-container');

    paypal.Buttons({
      style: {
        layout: 'horizontal',
        color: 'silver',
        shape: 'pill',
        tagline: false
      },
      createOrder: function(data, actions) {
        return fetch('/orders', {
          method: 'POST'
        }).then(function(res) {
          return res.json();
        }).then(function(data) {
          return data.id;
        });
      },
      onApprove: function(data, actions) {
        return fetch('/orders/' + data.orderID + '/capture', {
          method: 'POST'
        }).then(function(res){
          if (!res.ok) {
            alert('Something went wrong');
          } else {
            alert('Payment Complete!');
          }
        });
      }
    }).render('#paypal-button-container');
  }
})
