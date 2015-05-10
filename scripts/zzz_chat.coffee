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

getTimeDiffAsMinutes = (old_msec) ->
    now = new Date()
    old = new Date(old_msec)
    diff_msec = now.getTime() - old.getTime()
    diff_minutes = parseInt(diff_msec / (60*1000), 10 )
    return diff_minutes


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

        DOCOMO_API_KEY = process.env.DOCOMO_API_KEY
        message = msg.match[1]
        return unless DOCOMO_API_KEY && message

        # ContextIDを読み込む
        context = robot.brain.get KEY_DOCOMO_CONTEXT || ''

        # 前回会話してからの経過時間調べる
        TTL_MINUTES = 20
        old_msec = robot.brain.get KEY_DOCOMO_CONTEXT_TTL
        diff_minutes = getTimeDiffAsMinutes old_msec

        # 前回会話してから一定時間経っていたらコンテキストを破棄
        if diff_minutes > TTL_MINUTES
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
