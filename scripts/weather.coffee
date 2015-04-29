# Description:
#   hubot tell us about weather
# Commands:
#   hubot wth 
#

parseXml2Json = require('xml2js').parseString

getCityCode = (robot, msg, cityName) ->

  cityCode = robot.brain.get(cityName)

  if cityCode == null
    msg.http("http://weather.livedoor.com/forecast/rss/primary_area.xml")
      .get() (err, res, body) ->
        # start parse
        parseXml2Json(body, (err, result) ->
          # get pref list
          prefArray = result.rss.channel[0]['ldWeather:source'][0].pref
          # get all pref object such as saitama-ken, tokyo-to
          for key, prefObj of prefArray
            # get cityCode, cityName
            for val in prefObj.city
              id    = val['$'].id
              title = val['$'].title

              # set brain
              robot.brain.set(title, id)

              # set return value
              if title == cityName
                cityCode = id
        )

  return cityCode

getWeather = (msg, cityCode) ->
  q = city : cityCode

  msg.http("http://weather.livedoor.com/forecast/webservice/json/v1")
    .query(q)
    .get() (err, res, body) ->
      console.log(JSON.parse(body))

module.exports = (robot) ->
  robot.respond /wth? (.*)/i, (msg) ->
    cityCode = getCityCode robot, msg, '札幌'
    getWeather msg, cityCode

