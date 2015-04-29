# Description:
#   Please tell me probability of precipitation
#
# Commands:
#   hubot rain - Search probability of precipitation.

# 天気情報のURL
WEATHER_URL = "http://pipes.yahoo.com/pipes/pipe.run?_id=11aaf6db1647c2155de5739ff587db1f&_render=json&code=4410"

# 降水確率がこの確率を越えたらお知らせする
RAIN_LEVEL = 30

module.exports = (robot) ->
  cronJob = require('cron').CronJob
  new cronJob '0 0 7 * * *', () =>
    sendMsgRainfall robot
  , null, true, "Asia/Tokyo"

  robot.respond /rain$/i, (msg) ->
    sendMsgRainfall robot

sendMsgRainfall = (robot) ->
    robot.http(WEATHER_URL)
      .get() (err, res, body) ->
        json = JSON.parse body
        items = json["value"]["items"]
        item = items[0]
        rains = item["wm:forecast"]["wm:content"]["wm:rainfall"]["wm:prob"]
        rains = rains.filter((rain) ->
          return (RAIN_LEVEL <= rain["content"])
        )

        if 0 < rains.length
            rain = rains.shift
            status = getTimeStatus rain["hour"]
            message = "今日は#{status}から雨が降るから傘を持っていくんやで!!!"
        else
            message = "今日は雨は降らんで!!!"

        robot.send {room: "#general"}, message

getTimeStatus = (hour) ->
  if "6-12" == hour
      return "午前"
  else if "12-18" == hour
      return "午後"
  else
      return "夜"
