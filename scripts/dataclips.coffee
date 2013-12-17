# Description:
#   Access DataClip result
#
# Commands:
#   hubot add_clip clip_name url - Save a dataclip url to redis
#   hubot clip clip_name - Display dataclip value
#
# Author:
#   Yannick @yann_ck

module.exports = (robot) ->
  robot.respond /add clip ?([\w .\-_]+) (.*)/i, (msg) ->
    clip_name = msg.match[1].trim()
    clip_url = msg.match[2].trim()

    robot.brain.dataclips ?= {}
    robot.brain.dataclips[clip_name] = clip_url
    msg.send "Added clip #{clip_name}"

  robot.respond /clip ?([\w .\-_]+)/i, (msg) ->
    clip_name = msg.match[1].trim()
    robot.brain.dataclips ?= {}
    clip_url = robot.brain.dataclips[clip_name]
    if !clip_url
      return msg.send "No data for #{clip_name}"
    process_clip(msg, clip_name, clip_url)


process_clip = (msg, clip_name, clip_url) ->
    msg.http(clip_url).get() (err, res, body) ->
      if res.statusCode == 302
        process_clip(msg, clip_name, res.headers.location)
      else
        try
          json = JSON.parse(body)
          msg.send "The clip #{clip_name} is #{json.values}"
        catch error
          msg.send "Problem with dataclip #{clip_name}"
