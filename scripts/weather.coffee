# Description:
#   hubot tell us about weather
# Commands:
#   hubot wth XXX - Search and show the weather news of city name XXX.
#   hubot wth - Search and show the weather news of the most retrieved city.
#

errorMsg = {
  400: "そんな場所ないで"
  500: "いまちょっと動かへんから大人の人呼んでくれや"
}

parseXml2Json = require("xml2js").parseString

sendWrap = (robot, msg, cityName) ->
  # cityName is "default"
  #   when typed [hubot wth]
  if cityName == "default"
    cityCode = robot.brain.get("default_city_code")
    if cityCode == null
      # if no default_city_code at robot.brain, return Tokyo
      cityCode = "130010"

    return cityCode

  cityCode = robot.brain.get(cityName)

  if cityCode == null
    msg.http("http://weather.livedoor.com/forecast/rss/primary_area.xml")
      .get() (err, res, body) ->

        # start parse
        parseXml2Json(body, (err, result) ->

          # get pref list
          prefArray = result.rss.channel[0]["ldWeather:source"][0].pref

          # get all pref object such as saitama-ken, tokyo-to
          for key, prefObj of prefArray

            # get cityCode, cityName
            for val in prefObj.city
              id    = val["$"].id
              title = val["$"].title

              # set brain
              robot.brain.set(title, id)

              # set return value
              if title == cityName
                cityCode = id

          learningRobot(robot, cityCode)
          sendWeatherMsg(msg, cityCode)
        )
  else
    learningRobot(robot, cityCode)
    sendWeatherMsg(msg, cityCode)
  return

learningRobot = (robot, cityCode) ->
  cnt = robot.brain.get("#{cityCode}_count")
  if cnt == null
    cnt = 0

  cnt = cnt + 1
  robot.brain.set("#{cityCode}_count", cnt)
  maxCount = robot.brain.get("max_count")
  if maxCount == null
    maxCount = 0

  if cnt >= maxCount
    robot.brain.set("default_city_code", cityCode)
    robot.brain.set("max_count", cnt)

  return

sendWeatherMsg = (msg, cityCode) ->
  sendMsg = ""
  q = city : cityCode

  msg.http("http://weather.livedoor.com/forecast/webservice/json/v1")
    .query(q)
    .get() (err, res, body) ->
       try
         weatherJson = JSON.parse(body)
         sendMsg = "【" + weatherJson.location.area + " - " + weatherJson.location.city + "の天気やで】" + weatherJson.description.text
       catch error
         eCode = 400
         sendMsg = eCode + ": #{errorMsg[eCode]}"
       msg.send sendMsg
       return

module.exports = (robot) ->

  robot.respond /wth? (.*)/i, (msg) ->
    if typeof(msg.match[1]) == "undefined"
      eCode = 500
      msg.send eCode + ": #{errorMsg[eCode]}"
      return

    sendWrap robot, msg, msg.match[1]

  robot.respond /wth$/i, (msg) ->
    sendWrap robot, msg, "default"
