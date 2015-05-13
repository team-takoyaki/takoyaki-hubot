# Description:
#   Randomly recommend music (youtube) from iTunes Music
#
# Commands:
#   hubot music

parser = require('xml2js').parseString
request = require('request')

# iTunesからランキングを取得する
getTopSongs = (callback) ->
    url = "https://itunes.apple.com/jp/rss/topsongs/limit=100/xml"
    request url, (error, response, body) ->
        if error? || response.statusCode != 200
            callback []
        parser body, (error, result) ->
            entries = result.feed.entry
            callback (entry.title for entry in entries)

# 配列からランダムで1つ取り出す
getRandomChoice = (array) ->
    r = Math.floor(Math.random() * array.length)
    return array[r]

# クエリからYouTubeのVideoIdを取得する
getVideoId = (query, callback) ->
    baseurl = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video"
    key = process.env.GOOGLE_API_KEY
    url = "#{baseurl}&key=#{key}&q=#{query}"
    request url, (error, response, body) ->
        if error? || response.statusCode != 200
            callback('')
        else
            json = JSON.parse(body)
            items = json.items
            if 0 >= items.length
                callback('')
            else
                callback(items[0].id.videoId)

# ランキングからランダムでYouTubeのURLを取得する
getSongUrl = (array, callback) ->
    song = getRandomChoice array
    getVideoId song, (videoId) ->
        if videoId == ''
            # 再検索する
            getSongUrl array, callback
        else
            callback("http://youtu.be/#{videoId}")

getMessage = (url) ->
    return "この曲をどうぞ!!!\n#{url}"

module.exports = (robot) ->
    robot.respond /music$/i, (msg) ->
        getTopSongs (array) ->
            getSongUrl array, (url) ->
               msg.send getMessage(url)




