$(function(_) {
  $('#payment-form').submit(function(e) {
    var $form = $('#payment-form');

    Stripe.createToken($form, stripeResponseHandler);
    return false;
  });

  var stripeResponseHandler = function(status, response) {
    var $form = $('#payment-form');

    if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
      $form.find('button').prop('disabled', false);
    } else {
      var token = response.id;
      $form.append($('<input type="hidden" name="stripeToken" />').val(token));
      $form.get(0).submit();
    }
  };
});
