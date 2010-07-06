function complete_transaction(transaction_id) {
  $.getJSON("admin/complete_transaction?id=" + transaction_id, function(data) {
      if (data["error"]) {
        $("#error").html(data["error"]);
      } else {
        $("#transaction" + transaction_id).fadeOut();
      }
  });
}

function delete_transaction(transaction_id) {
  $.getJSON("admin/delete_transaction?id=" + transaction_id, function(data) {
    $("#transaction" + transaction_id).fadeOut();
  });
}

function handle_article(button) {
  var article_id = $(this).attr("article_id");
  var action = $(this).attr("action");
  $.getJSON("admin/handle_article?id=" + article_id + "&state=" + action, function(data) {
    $("#article" + article_id).fadeOut();
  });
}

$(function() {
  $(".vader_table tbody tr:odd").addClass("odd");
  $(".vader_table tbody tr:even").addClass("even");
  $(".vader_table").tablesorter();
  $("#tabs").tabs();

  $(".handle_transaction").click(function(event) {
    complete_transaction($(this).attr("value"))
  });
  $(".delete_transaction").click(function(event) {
    delete_transaction($(this).attr("value"))
  });
  $(".handle_article").click(handle_article);
});
