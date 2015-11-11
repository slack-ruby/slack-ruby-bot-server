$(document).ready(function() {

  var error = function(err) {
    $('#registerForm').prop('disabled', false);
    $('#messages').text(err.responseText || err);
  };

  var success = function(text) {
    $('#registerForm').prop('disabled', false);
    $('#messages').text(text);
  };

  var registerTeam = function() {
    $.ajax({
      type: "POST",
      url: "/api/teams",
      data: {
        team: {
          token: $('#token').val()
        }
      },
      success: function(data) {
        success('Team successfully registered, id=' + data.id);
      },
      error: error
    });
  };

  var findTeam = function(cb) {
    $.ajax({
      type: "GET",
      url: "/api/teams",
      beforeSend: function(request) {
        request.setRequestHeader("Token", $('#token').val());
      },
      success: function(teams) {
        if (teams._embedded.teams.length == 0) {
          error("Invalid token or team not registered.");
        } else {
          cb(teams._embedded.teams[0]);
        }
      },
      error: error
    });
  }

  var unregisterTeam = function() {
    findTeam(
      function(team) {
        $.ajax({
          type: "DELETE",
          url: "/api/teams/" + team.id,
          beforeSend: function(request) {
            $('#registerForm').prop('disabled', true);
            $('#messages').text('Unregistering team ...');
            request.setRequestHeader("Token", $('#token').val());
          },
          success: function(data) {
            success('Team successfully unregistered.');
          },
          error: error
        });
      }
    );
  };

  $('#register').click(registerTeam);
  $('#unregister').click(unregisterTeam);
});
