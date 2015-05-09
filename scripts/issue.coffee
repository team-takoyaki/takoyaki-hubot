# Description:
#   create, open, close GitHub Issue
#
# Commands:
#   hubot issue add "ISSUE_TITLE" "ISSUE_BODY" - Create the issue
#   hubot issue open ISSUE_ID - (Re)open the issue
#   hubot issue close ISSUE_ID - Close the issue

github = require('githubot')
ISSUES_URL = "https://api.github.com/repos/team-takoyaki/takoyaki-hubot/issues"

module.exports = (robot) ->
  robot.respond /issue\s+add\s+\"(.+)\"\s+\"(.+)\"$/i, (msg) ->
    github.post ISSUES_URL, {title: msg.match[1], body: msg.match[2]}, (response) ->
      issueUrl = response["html_url"]
      message = "Issue作ったで!!\n#{issueUrl}"
      msg.send message

  robot.respond /issue\s+(open|closed)\s+([0-9]+)$/i, (msg) ->
    issueState = msg.match[1]
    issueId = msg.match[2]

    github.patch "#{ISSUES_URL}/#{issueId}", {state: "#{issueState}"}, (response) ->
      if typeof(response["html_url"]) == "undefined"
        msg.send "そんなIssue番号ないで!!"
        return

      issueUrl = response["html_url"]
      if issueState == "open"
        message = "Issue開いたで!!"
      else if issueState == "closed"
        message = "Issue閉じたで!!"

      message = "#{message}\n#{issueUrl}"
      msg.send message
