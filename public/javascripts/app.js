function render_error_if_true(obj, msg, func) {
  obj["obj"].removeClass("red_inline");
  if (func.call(obj["obj"])) {
    $("#error").append("<p>" + obj["name"] + msg + "</p>");
    obj["obj"].addClass("red_inline");
    return false;
  }
  return true;
}

function value_should_be_a_positive_integer(obj) {
  return render_error_if_true(obj, " must be a positive whole number", function() {
    return (parseInt(this.val()) <= 0 || !/^[0-9]+$/.test(this.val()));
  });
}

function value_should_be_a_positive_float(obj) {
  return render_error_if_true(obj, " must be a positive decimal number", function() {
    return (parseFloat(this.val()) <= 0  || !/^\d+(\.\d+)?$/.test(this.val()));
  });
}

function value_should_be_a_date(obj) {
  return render_error_if_true(obj, " must be a date formatted as MM/DD/YYYY", function() {
    return !/\d\d\/\d\d\/\d\d\d\d/.test(this.val());
  });
}

function value_should_not_be_empty(obj) {
  return render_error_if_true(obj, " must not be empty", function() {
    return !/[\w\d]+/.test(this.val());
  });
}

$(function() {
  $("#create_ipo").click(function() {
    $("#internal_stock_dialog").dialog({
        bgiframe: true,
        width: 600,
        show: 'slide',
        hide: 'slide'
    }).dialog('open');
  });
  var top = $("#top");
  top.children(".logo").click(function() {
    location.href = "/";
  }).addClass("hand_pointer");
  top.children("h2").click(function() {
    location.href = "/";
  }).addClass("hand_pointer");
  $(".pics").cycle({
    fx: 'fade',
    speed: 1000,
    timeout: 22500,
    random: 1,
    pause: 1
  });
});
