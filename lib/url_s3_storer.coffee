debug = require('debug')('s3_storer:url_s3_storer')
sha1 = require 'sha1'
knox = require 'knox'
http = require 'http'
https = require 'https'
RSVP = require 'rsvp'

class UrlS3Storer
  constructor: (@url, @options) ->

  store: ->
    new RSVP.Promise (resolve, reject) =>
      debug "GET #{@url}"

      @httpClient().get @url, (getUrlStream) =>
        if @isHttpStatusOk getUrlStream.statusCode
          headersToS3 =
            'Content-Length': getUrlStream.headers['content-length']
            'Content-Type': getUrlStream.headers['content-type']
            'x-amz-acl': 'public-read'


          debug "--> Streaming to S3 #{@options.s3Bucket} #{@bucketPath()}"
          @s3().putStream getUrlStream, @bucketPath(), headersToS3, (err, s3StoreRes) ->
            debug "---> Done #{s3StoreRes.req.url}"

            if err
              reject err
            else  
              resolve s3StoreRes.req.url

        else
          body = ""

          getUrlStream.on 'data', (chunk) -> body += chunk
          getUrlStream.on 'end', ->
            debug "--> Failed #{getUrlStream.statusCode} #{body}"

            reject
              response:
                status: getUrlStream.statusCode
                body: body


  bucketKey: -> sha1 @url
  bucketPath: -> "/#{@bucketKey()}"

  s3Url: ->


  s3: ->
    knox.createClient
      key: @options.awsAccessKeyId
      secret: @options.awsSecretAccessKey
      bucket: @options.s3Bucket
      region: @options.s3Region

  httpClient: -> if @url.match(/^https/) then https else http
  isHttpStatusOk: (code) -> code >= 200 && code < 300

module.exports = UrlS3Storer
