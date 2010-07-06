function clear_messages() {
  $("#error").html("");
  $("#notice").html("");
}

function display_dividend_dialog(event) {
  clear_messages();
  var stock_id = $(this).attr("stock_id");
  $("#set_dividend").attr("stock_id", stock_id);
  $("#specify_dividend_dialog")
    .dialog({
      bgiframe: true,
      width: 600,
      modal: true,
      show: 'slide',
      hide: 'slide',
    }).dialog('open');
}

function update_dividend() {
  var stock_id = $(this).attr("stock_id");
  var dividend = $("#dividend").val();
  $.getJSON("/stocks/set_dividend?stock_id=" + stock_id + "&dividend=" + dividend, function(data) {
    if (data["ok"]) {
      $("#notice")
        .append(data["ok"])
        .effect("highlight", {}, 3000);
      $("#current_dividend" + stock_id)
        .html(dividend)
        .effect("highlight", {}, 3000);
      $("#specify_dividend_dialog").dialog('close');
    } else if (data["error"]) {
      $("#error")
        .append(data["error"])
        .effect("highlight", {}, 3000);
    }
  }).ajaxStart(function() {
    $("#set_dividend_wait").show();
  }).ajaxStop(function() {
    $("#set_dividend_wait").hide();
  });
}

function disburse_dividend() {
  clear_messages();
  var stock_id = $(this).attr("stock_id");
  $.getJSON("/stocks/disburse_dividend?stock_id=" + stock_id, function(data) {
    if (data["ok"]) {
      $("#notice")
        .append(data["ok"])
        .effect("highlight", {}, 3000);
    } else if (data["error"]) {
      $("#error")
        .append(data["error"])
        .effect("highlight", {}, 3000);
    }
  }).ajaxStart(function() {
    $("#disburse_wait" + stock_id).show();
  }).ajaxStop(function() {
    $("#disburse_wait" + stock_id).hide();
  });
}

function display_featured_article_checkbox() {
  $.getJSON("/articles/can_afford_featured_article", function(data) {
    var frontpage = $(".frontpage");
    (data == true) ? frontpage.show() : frontpage.hide();
  });
}

function display_article_drafting_dialog(event) {
  clear_messages();
  var stock_id = $(this).attr("stock_id");
  $("#article_stock_id").attr("value", stock_id);
  $("#article_drafting_dialog")
    .dialog({
      bgiframe: true,
      width: 600,
      modal: true,
      show: 'slide',
      hide: 'slide',
      open: display_featured_article_checkbox
    }).dialog('open');
}

function preview_article(event) {
  payload = {
    authenticity_token: $("input[name=authenticity_token]").val(),
    markdown: $("#article_body").val()
  };
  $.post("/articles/render_to_html", payload, function(data) {
      $("#article_preview_dialog #preview").html(data);
      $("#article_preview_dialog")
        .dialog({
          bgiframe: true,
          width: 600,
          modal: true,
          show: 'slide',
          hide: 'slide',
        }).dialog('open');
  });
}

function number_of_properties_in(obj) {
  var i = 0;
  for(p in obj) { i++ };
  return i;
}

function create_ipo_form_is_valid() {
  $("#error").html("");
  var valid = true;
  valid = value_should_not_be_empty({name: "Stock name", obj: $("#stock_name")}) && valid;
  valid = value_should_not_be_empty({name: "Stock ticker", obj: $("#stock_symbol")}) && valid;
  valid = value_should_be_a_positive_integer({name: "Number of shares", obj: $("#stock_number_of_shares")}) && valid; 
  valid = value_should_be_a_positive_integer({name: "Price per share", obj: $("#stock_initial_price")}) && valid; 
  return valid;
}

function create_bond_form_is_valid() {
  $("#error").html("");
  var valid = true;
  valid = value_should_not_be_empty({name: "Bond name", obj: $("#bond_name")}) && valid;
  valid = value_should_not_be_empty({name: "Bond ticker", obj: $("#bond_symbol")}) && valid;
  valid = value_should_be_a_positive_integer({name: "Number of bonds", obj: $("#bond_number_of_shares")}) && valid; 
  valid = value_should_be_a_positive_integer({name: "Price per bond", obj: $("#bond_initial_price")}) && valid; 
  valid = value_should_be_a_positive_float({name: "Monthly interest rate", obj: $("#bond_initial_interest_rate")}) && valid;
  valid = value_should_be_a_positive_integer({name: "Months until maturity", obj: $("#bond_months_until_maturity")}) && valid;
  $("input").removeClass("red_inline");
  $("select").removeClass("red_inline");
  if (!$("#increment_rate_dev").hasClass("invisible")) {
    if (/^\d+$/.test($("#bond_period_length").val()) && !/^\d+(\.\d+)?$/.test($("#bond_interest_increment").val())) {
      $("#error").append("<p>Bond interest increment must be a positive decimal number</p>");
      $("#bond_interest_increment").addClass("red_inline");
      valid = false;
    } else if (!/^\d+$/.test($("#bond_period_length").val()) && /^\d+(\.\d+)?$/.test($("#bond_interest_increment").val())) {
      $("#error").append("<p>Bond period length must be a positive whole number</p>");
      $("#bond_period_length").addClass("red_inline");
      valid = false;
    }
  }
  if (!$("#bonus_rate_dev").hasClass("invisible")) {
    if (/^\d+$/.test($("#bond_bonus_rate_period").val()) && !/^\d+(\.\d+)?$/.test($("#bond_interest_bonus").val())) {
      $("#error").append("<p>Bond bonus interest must be a positive decimal number</p>");
      $("#bond_interest_bonus").addClass("red_inline");
      valid = false;
    } else if (!/^\d+$/.test($("#bond_bonus_rate_period").val()) && /^\d+(\.\d+)?$/.test($("#bond_interest_bonus").val())) {
      $("#error").append("<p>Bond bonus period must be a positive whole number</p>");
      $("#bond_bonus_rate_period").addClass("red_inline");
      valid = false;
    }
  }
  return valid;
}

var func_table = {
  "create_ipo_form_is_valid": create_ipo_form_is_valid,
  "create_bond_form_is_valid": create_bond_form_is_valid,
}

function display_dialog(dialog_type) {
  $("#create_" + dialog_type + "_dialog #create_" + dialog_type + "_button")
    .click(function(event) {
      var form_is_valid = func_table["create_" + dialog_type + "_form_is_valid"];
      var valid = form_is_valid.call();
      if (valid) {
        $("#create_" + dialog_type + "_dialog > form").submit();
        $("#create_" + dialog_type + "_dialog").dialog('close');
      }
    });
  $("#create_" + dialog_type + "_dialog")
    .dialog({
      bgiframe: true,
      width: 600,
      modal: true,
      show: 'slide',
      hide: 'slide',
      close: function() { $("#error").html("") }
    }).dialog('open');
}

function display_bond_dialog(event) {
  display_dialog("bond");
}

function setup_bond_dialog() {
  $("#increment_rate").click(function() {
    if ($("#increment_rate_div").hasClass("invisible")) {
      $("#increment_rate_div").fadeIn().removeClass("invisible");
    } else {
      $("#increment_rate_div").fadeOut().addClass("invisible");
      $("#bond_interest_increment").val("");
    }
  });
  $("#rate_bonus").click(function() {
    if ($("#bonus_rate_div").hasClass("invisible")) {
      $("#bonus_rate_div").fadeIn().removeClass("invisible");
    } else {
      $("#bonus_rate_div").fadeOut().addClass("invisible");
      $("#bond_bonus_rate").val("");
    }
  });
  $("#bond_months_until_maturity").blur(function() {
    var number_of_periods = $(this).val();
    $("#bond_bonus_rate_period").html("");
    $("#bond_period_length").html("");
    $("#bond_bonus_rate_period").append("<option selected='selected'>");
    $("#bond_period_length").append("<option selected='selected'>");
    for(var i = 1; i <= number_of_periods; i++) {
      $("#bond_bonus_rate_period").append("<option value=" + i + ">" + i + "</option>");
      $("#bond_period_length").append("<option value=" + i + ">" + i + "</option>");
    }
  });
}

function select_customer_to_refund() {
  var bond_id = $(this).attr("stock_id");
  $("#select_customer_to_refund_dialog")
    .dialog({
      bgiframe: true,
      width: 600,
      modal: true,
      show: 'slide',
      hide: 'slide',
      close: function(event, ui) { $("#error").html("") },
      open: function(event, ui) { get_bond_customers(bond_id) },
    }).dialog('open');
}

function get_bond_customers(bond_id) {
  $.get("/stocks/bond_customers?id=" + bond_id, function(data) {
    $("#select_customer_to_refund_dialog tbody")
      .html("")
      .append(data);
  });
}

$(function() {
  $("#accordion").accordion();
  $("#customers_to_refund").tablesorter();
  $(".specify_dividend").click(display_dividend_dialog);
  $("#set_dividend").click(update_dividend);
  $(".disburse_dividend").click(disburse_dividend);
  $(".select_customer_to_refund").click(select_customer_to_refund);
  $(".draft_article").click(display_article_drafting_dialog);
  $("#preview_article").click(preview_article);
  $("#submit_draft").click(function() { $("#article_drafting_dialog form").submit() });
  $("#close_preview").click(function() {
    $("#article_preview_dialog").dialog('close');
  });
  $("#create_ipo").click(function() { 
    display_dialog("ipo") 
  });
  $("#create_bond").click(function() {
    display_dialog("bond")
  });
  setup_bond_dialog();
})
