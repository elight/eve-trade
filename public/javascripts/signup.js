// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function update_characters_select_using(hash) {
  $("#user_eve_character_id").html("");
  if (hash["ERROR"] != null) {
    $("#error").text(hash["ERROR"]);
    return;
  }

  for (character in hash) {
    $("#error").text("");
    var option = $("<option/>")
      .attr("value", character + ":" + hash[character])
      .text(character);
    $("#user_eve_character_id").append(option);
  }
  $("#user_eve_character_id").effect("bounce", {}, 250);
}

function update_characters_select_from_server(api_key, user_id) {
  if (user_id != undefined && api_key != undefined && api_key.length == 64) {
    $.ajax({
      dataType: "json",
      data: "api_key=" + api_key + "&user_id=" + user_id,
      url: "/get_characters",
      success: update_characters_select_using
    });
  }
}

$(document).ready(function() {
  var user_id = undefined;
  var api_key = undefined;

  $("#user_eve_user_id").blur(function(event) {
    user_id = this.value;
    update_characters_select_from_server(api_key, user_id);
  });

  $("#user_eve_api_key").blur(function(event) {
    api_key = this.value;
    update_characters_select_from_server(api_key, user_id);
  });
});

