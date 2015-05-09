# Description:
#   GitHub Issue
#
# Commands:

ISSUES_URL = "api.github.com/repos/team-takoyaki/takoyaki-hubot/issues"
USER_NAME = "Takashi-kun"
ACCESS_TOKEN = "9c21ac35df1abf599d092258fe676a32db51f3c9"


module.exports = (robot) ->
  robot.respond /issue\s+add\s+\"(.+)\"\s+\"(.+)\"$/i, (msg) ->
    data = JSON.stringify({
      title: msg.match[1],
      body: msg.match[2]
    })
    robot.http("https://#{USER_NAME}:#{ACCESS_TOKEN}@#{ISSUES_URL}")
      .headers("Accept": "application/json", "Content-type": "application/json")
      .post(data) (err, res, body) ->
        json = JSON.parse(body)
        issueUrl = json["html_url"]
        message = "Issue作ったで!!\n#{issueUrl}"
        robot.send message

  robot.respond /issue\s+(open|closed)\s+([0-9]+)$/i, (msg) ->
    issueState = msg.match[1]
    issueId = msg.match[2]

    data = JSON.stringify({
      state: "#{issueState}"
    })
    robot.http("https://#{USER_NAME}:#{ACCESS_TOKEN}@#{ISSUES_URL}/#{issueId}")
      .headers("Accept": "application/json", "Content-type": "application/json")
      .post(data) (err, res, body) ->
        json = JSON.parse(body)
        if typeof(json["html_url"]) == "undefined"
          robot.send "そんなIssue番号ないで!!"
          return

        issueUrl = json["html_url"]
        if issueState == "open"
          message = "Issue開いたで!!"
        else if issueState == "closed"
          message = "Issue閉じたで!!"
        message = "#{message}\n#{issueUrl}"

        robot.send message
