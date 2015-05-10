# Description:
#   DOCOMOの雑談APIを利用した雑談
#
# Author:
#   FromAtom
#
# Url:
#   http://fromatom.hatenablog.com/entry/2014/12/07/010447

API_URL = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY='
KEY_DOCOMO_CONTEXT = 'docomo-talk-context'
KEY_DOCOMO_CONTEXT_TTL = 'docomo-talk-context-ttl'
TTL_MINUTES = 20

getTimeDiffAsMinutes = (oldSec) ->
    now = new Date()
    old = new Date(oldSec)
    diffSec = now.getTime() - old.getTime()
    diffMinutes = parseInt(diffSec / (60 * 1000), 10)
    return diffMinutes

module.exports = (robot) ->
    # 全てのコマンド一覧を取得
    cmds = []
    for help in robot.helpCommands()
      cmd = help.split(' ')[1]
      cmds.push cmd if cmds.indexOf(cmd) is -1

    robot.respond /(\S+)/i, (msg) ->
        # コマンドにマッチしていればそこまで
        cmd = msg.match[1].split(' ')[0]
        return unless cmds.indexOf(cmd) is -1

        # Newsを発言する
        if isNewsSend()
            sendNewsMessage(msg)
            return

        DOCOMO_API_KEY = process.env.DOCOMO_API_KEY
        message = msg.match[1]
        return unless DOCOMO_API_KEY && message

        # ContextIDを読み込む
        context = robot.brain.get KEY_DOCOMO_CONTEXT || ''

        # 前回会話してからの経過時間調べる
        oldSec = robot.brain.get KEY_DOCOMO_CONTEXT_TTL
        diffMinutes = getTimeDiffAsMinutes oldSec

        # 前回会話してから一定時間経っていたらコンテキストを破棄
        if diffMinutes > TTL_MINUTES
            context = ''

        url = API_URL + DOCOMO_API_KEY
        user_name = msg.message.user.name

        json =
            utt: message,
            nickname: user_name if user_name,
            context: context if context
        data = JSON.stringify(json)

        msg.http(url)
           .post(data) (err, res, body) ->
                json = JSON.parse(body)
                # ContextIDの保存
                robot.brain.set KEY_DOCOMO_CONTEXT, json.context

                # 会話発生時間の保存
                now_msec = new Date().getTime()
                robot.brain.set KEY_DOCOMO_CONTEXT_TTL, now_msec

                msg.send json.utt

# Yahooニュースから1つを選んで発言する
NEWS_URL = 'http://rss.dailynews.yahoo.co.jp/fc/rss.xml'
NEWS_PROB = 10
parseString = require('xml2js').parseString

sendNewsMessage = (msg) ->
    msg.http(NEWS_URL)
      .get() (err, res, body) ->
        xml   = body
        parseString(xml, (err, result) ->
            channel = result.rss.channel[0]
            items = channel.item
            item = msg.random items
            msg.send "このニュースを1つどうぞ\n#{item.link}"
        )

isNewsSend = () ->
    num = Math.floor(Math.random() * NEWS_PROB) + 1
    if NEWS_PROB == num
        return true
    return false
