http = require 'http'
https = require 'https'
concat = require 'concat-stream'
bufferEqual = require 'buffer-equal'
RSVP = require 'rsvp'

httpClient = (url) -> if url.match(/^https/) then https else http

get = (url) ->
  new RSVP.Promise (resolve, reject) ->
    httpClient(url).get url, (stream) ->
      if stream.statusCode is 200
        stream.pipe concat (buffer) -> resolve buffer
      else
        reject "Status code not 200 OK for #{url}, was: #{stream.statusCode}."




module.exports = (url1, url2) ->
  new RSVP.Promise (resolve, reject) ->
    promise1 = get url1
    promise2 = get url2

    RSVP.all([promise1, promise2])
      .then (getBuffers) ->
        if bufferEqual getBuffers[0], getBuffers[1]
          resolve true
        else
          reject "Downloaded content of #{url1} does not seem to equal #{url2}."
      .catch (error) ->
        reject error
