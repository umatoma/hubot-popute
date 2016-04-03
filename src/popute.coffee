# Description
#   A hubot script that show popite pipick comic images
#
# Commands:
#   hubot popute|ppt me - show popute pipick comick image

cheerio = require 'cheerio'
async = require 'async'

COMIC_BASE_URLS = [
  'http://mangalifewin.takeshobo.co.jp/rensai/popute/'
  'http://mangalifewin.takeshobo.co.jp/rensai/popute2/'
]

module.exports = (robot) ->
  robot.respond /(?:popute|ppt) me/, (msg) ->
    async.map COMIC_BASE_URLS, (url, cb) ->
      robot.http(url)
        .get() (err, res, body) ->
          if err
            return cb err
          if res.statusCode isnt 200
            return cb new Error "HTTP status code is #{res.statusCode}"

          robot.logger.debug body
          $ = cheerio.load body
          urls = $('.bookR a').map((i) -> $(this).attr 'href').get()
          cb null, urls
    , (err, results) ->
      if err
        robot.logger.error err
        return robot.emit 'error', err, msg

      robot.logger.debug results
      page_urls = results[0].concat(results[1])
      image_urls = page_urls.map (url) ->
        match = /^.+\/rensai\/(popute|popute2)\/((?:popute|popute2)-\d+)\/(\d+)\/*$/i.exec url
        if match
          "http://mangalifewin.takeshobo.co.jp/global-image/manga/okawabukubu/#{match[1]}/#{match[2]}/#{match[3]}.jpg"
        else
          null
      msg.send msg.random image_urls