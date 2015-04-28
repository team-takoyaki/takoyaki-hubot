# Description:
#   Today's news
#
# Commands:

parseString = require('xml2js').parseString

module.exports = (robot) ->
  robot.respond /NEWS$/i, (msg) ->
    msg.http("http://rss.dailynews.yahoo.co.jp/fc/rss.xml")
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        xml   = body
        parseString(xml, (err, result) ->
            channel = result.rss.channel[0]
            items = channel.item
            index = Math.floor(Math.random() * items.length)
            item = items[index]
            msg.send "#{item.title} - #{item.link}"
        )