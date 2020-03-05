//= require jquery
//= require jquery_ujs
//= require jquery.growl
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree ./common

$(function() {
  if($('#paypal-button-container').length > 0) {
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
