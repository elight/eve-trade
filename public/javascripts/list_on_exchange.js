$(function() {
  $("#dialog_internal_whatisthis").click(function() {
    $("#internal_stock_explanation").dialog({
      bgiframe: true,
      width: 600,
      show: 'slide',
      hide: 'slide'
    }).dialog('open');
  });
  $("#internal_stock").click(function() {
    $("#internal_stock_dialog").dialog({
      bgiframe: true,
      width: 600,
      show: 'slide',
      hide: 'slide'
    }).dialog('open');
  });
  $("#dialog_external_whatisthis").click(function() {
    $("#external_stock_explanation").dialog({
      bgiframe: true,
      width: 600,
      show: 'slide',
      hide: 'slide'
    }).dialog('open');
  });
  $("#external_stock").click(function() {
    $("#external_stock_dialog").dialog({
      bgiframe: true,
      width: 600,
      show: 'slide',
      hide: 'slide'
    }).dialog('open');
  });
});
