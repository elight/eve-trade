function sell_order_is_valid() {
  $("#error").html("");
  var valid = true;
  valid = value_should_be_a_positive_integer({name: "Number of units", obj: $("#sell_order_total_shares")}) && valid;
  valid = value_should_be_a_positive_integer({name: "Price per unit", obj: $("#sell_order_price_per_share")}) && valid;
  valid = value_should_be_a_date({name: "Expiring at", obj: $("#sell_order_expires_at")}) && valid;
  return valid;
}

function buy_order_is_valid() {
  $("#error").html("");
  var valid = true;
  valid = value_should_be_a_positive_integer({name: "Number of units", obj: $("#buy_order_total_shares")}) && valid;
  valid = value_should_be_a_positive_integer({name: "Price per unit", obj: $("#buy_order_price_per_share")}) && valid;
  valid = value_should_be_a_date({name: "Expiring at", obj: $("#buy_order_expires_at")}) && valid;
  return valid;
}

var func_map = {
  "buy_order_is_valid": buy_order_is_valid,
  "sell_order_is_valid": sell_order_is_valid
}

function attempt_to_complete_order(order_type) {
  if (func_map[order_type + "_order_is_valid"].call()) {
    $("#" + order_type + "_dialog form").submit();
  }
}

function setupOrderDialog(name) {
  $("#" + name).click(function() {
    $("#" + name + "_dialog").dialog({
      bgiframe: true,
      width: 600,
      show: 'slide',
      hide: 'slide'
    }).dialog('open')
  });
  var dialog = $("#" + name + "_dialog");
  dialog.find("#" + name + "_order_expires_at").datepicker();
  dialog.find("#complete_" + name + "_order").click(function () {
    attempt_to_complete_order(name);
  });
}

$(function() {
  setupOrderDialog("buy");
  setupOrderDialog("sell");

  // helper for returning the weekends in a period
  function weekendAreas(axes) {
      var markings = [];
      var d = new Date(axes.xaxis.min);
      // go to the first Saturday
      d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7))
      d.setUTCSeconds(0);
      d.setUTCMinutes(0);
      d.setUTCHours(0);
      var i = d.getTime();
      do {
          // when we don't set yaxis the rectangle automatically
          // extends to infinity upwards and downwards
          markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000 } });
          i += 7 * 24 * 60 * 60 * 1000;
      } while (i < axes.xaxis.max);

      return markings;
  }
  
  if (d) {
    var options = {
        xaxis: { mode: "time" },
        selection: { mode: "x", color: "#DA3B3B"},
        grid: { markings: weekendAreas },
        colors: ["#DA3B3B"]
    };
    
    var plot = $.plot($("#placeholder"), [d], options);
    
    var overview = $.plot($("#overview"), [d["data"]], {
        lines: { show: true, lineWidth: 1 },
        shadowSize: 0,
        xaxis: { ticks: [], mode: "time" },
        yaxis: { ticks: [] },
        selection: { mode: "x", color: "#DA3B3B"},
        colors: ["#DA3B3B"]
    });

    // now connect the two
    
    $("#placeholder").bind("plotselected", function (event, ranges) {
        // do the zooming
        plot = $.plot($("#placeholder"), [d],
                      $.extend(true, {}, options, {
                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
                      }));

        // don't fire event on the overview to prevent eternal loop
        overview.setSelection(ranges, true);
    });
    
    $("#overview").bind("plotselected", function (event, ranges) {
        plot.setSelection(ranges);
    });
  }
});
