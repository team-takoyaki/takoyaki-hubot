# Description:
#   hubot tell us about weather
# Commands:
#   hubot wth 
#

getWeather = (msg) ->
  q = city : 400040

  msg.http("http://weather.livedoor.com/forecast/webservice/json/v1")
    .query(q)
    .get() (err, res, body) ->
      console.log(JSON.parse(body))

module.exports = (robot) ->
  robot.respond /wth? (.*)/i, (msg) ->
    getWeather msg

