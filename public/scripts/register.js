$(document).ready(function() {
  // Slack OAuth
  var code = $.url('?code')
  var state = $.url('?state')
  if (code) {
    SlackRubyBotServer.message('Working, please wait ...');
    $('#register').hide();
    $.ajax({
      type: "POST",
      url: "/api/teams",
      data: {
        code: code,
        state: state
      },
      success: function(data) {
        SlackRubyBotServer.message('Team successfully registered!<br><br>DM <b>@bot</b> or create a <b>#channel</b> and invite <b>@bot</b> to it.');
      },
      error: SlackRubyBotServer.error
    });
  }
});
