$(function() {
  $("#withdraw_funds").click(function(event) {
    $("#withdraw_funds_div").dialog({
      bgiframe: true,
      width: 600,
      modal: true,
      show: 'slide',
      hide: 'slide',
    }).dialog('open');
  });
  $("#tabs").tabs();
  $(".vader_table tbody tr:odd").addClass("odd");
  $(".vader_table tbody tr:even").addClass("even");
  $(".vader_table").tablesorter({
    textExtraction: function(node) {
      var content = $(node).html();
      if (/\d,\d/.test(content)) {
        content = content.replace(/,/g, "");
      }
      return content;
    }
  });

  $("#buy_order_expires_at").datepicker();
  $("#sell_order_expires_at").datepicker();

  $("#request_withdrawal").click(function() {
    $("#error").html("");
    if (value_should_be_a_positive_integer({name: "Withdrawal amount", obj:$("#withdrawal_amount")})) {
      $("#withdraw_funds_div form").submit();
    }
  });

  $.each(["buy", "sell"], function() {
    var order_type = this;
    $(".cancel_" + order_type + "_order").click(function(event) {
      var stock_id = $(this).attr("order_id");
      $.getJSON("/stocks/cancel_" + order_type + "_order?id=" + stock_id, function() {
        $("#row" + stock_id).fadeOut();
      });
    });
  });

  var newsoption1 = {
    firstname: "mynews",
    secondname: "show_here",
    thirdname:"news_title",
    fourthname:"news_button",
    newsspeed:'16000',
    effectis:'0',
    imagedir:'/images/',
    mouseover:true,
    newscountname:"news_display",
    disablenewscount:false
  };
  $.init_news(newsoption1);
});


