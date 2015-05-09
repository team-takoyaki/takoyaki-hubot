# Description:
#   GitHub Issue
#
# Commands:


module.exports = (robot) ->
  robot.respond /issue\s+add\s+\"(.+)\"\s+\"(.+)\"$/i, (msg) ->
    data = JSON.stringify({
      title: msg.match[1],
      body: msg.match[2]
    })
    robot.http("https://Takashi-kun:9c21ac35df1abf599d092258fe676a32db51f3c9@api.github.com/repos/team-takoyaki/takoyaki-hubot/issues")
      .headers("Accept": "application/json", "Content-type": "application/json")
      .post(data) (err, res, body) ->
        json = JSON.parse(body)
        issueUrl = json["html_url"]
        message = "Issue作ったで!!\n#{issueUrl}"
        robot.send message

  robot.respond /issue\s+(open|closed)\s+([0-9]+)$/i, (msg) ->
    issueState = msg.match[1]
    issueId = msg.match[2]

    if issueState != "open" && issueState != "closed"
      robot.send "openかclosedにするんやで"
      return

    data = JSON.stringify({
      state: "#{issueState}"
    })
    robot.http("https://Takashi-kun:9c21ac35df1abf599d092258fe676a32db51f3c9@api.github.com/repos/team-takoyaki/takoyaki-hubot/issues/#{issueId}")
      .headers("Accept": "application/json", "Content-type": "application/json")
      .post(data) (err, res, body) ->
        json = JSON.parse(body)
        issueUrl = json["html_url"]
        if issueState == "open"
          message = "Issue開いたで!!"
        else if issueState == "closed"
          message = "Issue閉じたで!!"
        message = "#{message}\n#{issueUrl}"
        robot.send message
