# Description:
#   Please tell me robot name

MIN_MATCH_WORD_NUM = 2

module.exports = (robot) ->
    startMatch = robot.name.substr(0, MIN_MATCH_WORD_NUM)
    endMatch = robot.name.substr(-MIN_MATCH_WORD_NUM)
    robot.hear ///^(#{startMatch}.*|.*#{endMatch})$///i, (msg) ->
        console.log(startMatch)
        if robot.name == msg
            return

        msg.send "#{robot.name}やで!!!"
