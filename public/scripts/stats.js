$(document).ready(function() {

  $.ajax({
    type: "GET",
    url: "/api/status",
    success: function(data) {
      var active_teams_count = data.active_teams_count;
      $('#active_teams_count').hide().text(
        active_teams_count + " registered active teams!"
      ).fadeIn('slow');
    },
  });

});
