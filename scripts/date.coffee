# Description:
#  hubot tell us vancouver date
#
# Commands:
#   hubot yvrdate
#   hubot jpndate

request = require('request')

# バンクーバーの時間を取得する
getVancouverDate = (callback) ->
    d = new Date();
    timestamp = Math.floor ((d.getTime() + (d.getTimezoneOffset() * 60 * 1000)) / 1000);
    apiKey = process.env.GOOGLE_API_KEY
    latitude = 49.2945536
    longtitude = -123.1189353
    url = "https://maps.googleapis.com/maps/api/timezone/json?location=#{latitude},#{longtitude}&key=#{apiKey}&timestamp=#{timestamp}"
    request url, (error, response, body) ->
        if error? || response.statusCode != 200
            return
        json = JSON.parse(body)
        date = new Date(timestamp * 1000 + json.rawOffset * 1000 + json.dstOffset * 1000);
        callback date

getJapanDate = (callback) ->
    d = new Date();
    timestamp = Math.floor ((d.getTime() + (d.getTimezoneOffset() * 60 * 1000)) / 1000);
    apiKey = process.env.GOOGLE_API_KEY
    latitude = 35.66919
    longtitude = 139.7413806
    url = "https://maps.googleapis.com/maps/api/timezone/json?location=#{latitude},#{longtitude}&key=#{apiKey}&timestamp=#{timestamp}"
    request url, (error, response, body) ->
        if error? || response.statusCode != 200
            return
        json = JSON.parse(body)
        date = new Date(timestamp * 1000 + json.rawOffset * 1000 + json.dstOffset * 1000);
        callback date

getVancouverMessage = (date) ->
    year = date.getFullYear();
    month = date.getMonth() + 1;
    day = date.getDate();
    dayOfWeekIndex = date.getDay();
    hours = date.getHours();
    minutes = date.getMinutes();
    seconds = date.getSeconds();
    dayOfWeek = new Array("日", "月", "火", "水", "木", "金", "土");

    message = "バンクーバーは#{year}年#{month}月#{day}日(#{dayOfWeek[dayOfWeekIndex]}) #{hours}時#{minutes}分やで！"

    return message

getJapanMessage = (date) ->
    year = date.getFullYear();
    month = date.getMonth() + 1;
    day = date.getDate();
    dayOfWeekIndex = date.getDay();
    hours = date.getHours();
    minutes = date.getMinutes();
    seconds = date.getSeconds();
    dayOfWeek = new Array("日", "月", "火", "水", "木", "金", "土");

    message = "日本は#{year}年#{month}月#{day}日(#{dayOfWeek[dayOfWeekIndex]}) #{hours}時#{minutes}分やで！"

    return message

module.exports = (robot) ->
    robot.respond /yvrdate/i, (msg) ->
        getVancouverDate (date) ->
               msg.send getVancouverMessage(date)

    robot.respond /jpndate/i, (msg) ->
        getJapanDate (date) ->
               msg.send getJapanMessage(date)




