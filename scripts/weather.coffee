# Description:
#   hubot tell us about weather
# Commands:
#   hubot wth XXX
#   hubot wth
#

errorMsg = {
  400: "そんな場所ないで"
  500: "いまちょっと動かへんから大人の人呼んでくれや"
}

parseXml2Json = require("xml2js").parseString

getCityCode = (robot, msg, cityName) ->

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
        )

  learingRobot(robot, cityCode)

  return cityCode

learingRobot = (robot, cityCode) ->
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

sendWrap = (robot, msg, isDefault) ->

  if isDefault == true
    cityName = "default"
  else
    if typeof msg.match[1] != "undefined"
      cityName = msg.match[1]
    else
      eCode = 500
      msg.send eCode + ": #{errorMsg[eCode]}"
      return

  cityCode = getCityCode robot, msg, cityName
  sendWeatherMsg msg, cityCode

module.exports = (robot) ->
  robot.respond /wth? (.*)/i, (msg) ->
    sendWrap robot, msg, false
  robot.respond /wth$/i, (msg) ->
    sendWrap robot, msg, true
