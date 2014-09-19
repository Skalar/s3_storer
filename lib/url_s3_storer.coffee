debug = require('debug')('s3_storer:url_s3_storer')
sha1 = require 'sha1'
knox = require 'knox'
http = require 'http'
https = require 'https'
RSVP = require 'rsvp'

class UrlS3Storer
  constructor: (@url, @options) ->

  # Public: Runs store function, returns a promise.
  #
  # Resolves with the URL to S3, or cloud front url if cloud front given in options
  #
  # Rejects with either:
  #   downloadResponse: {status: xxx, body: 'xxx'}
  #   s3: 'Upload to S3 failed'
  store: ->
    new RSVP.Promise (resolve, reject) =>
      debug "GET #{@url}"

      @httpClient().get @url, (getUrlStream) =>
        if @isHttpStatusOk getUrlStream.statusCode
          @uploadToS3 getUrlStream, resolve, reject
        else
          @bufferResponseAndFail(getUrlStream, resolve, reject)


  bucketKey: -> sha1 @url
  bucketPath: -> "/#{@bucketKey()}"

  s3: ->
    knox.createClient
      key: @options.awsAccessKeyId
      secret: @options.awsSecretAccessKey
      bucket: @options.s3Bucket
      region: @options.s3Region

  httpClient: -> if @url.match(/^https/) then https else http
  isHttpStatusOk: (code) -> code >= 200 && code < 300




  uploadToS3: (getUrlStream, resolve, reject) ->
    headersToS3 =
      'Content-Length': getUrlStream.headers['content-length']
      'Content-Type': getUrlStream.headers['content-type']
      'x-amz-acl': 'public-read'


    debug "--> Streaming to S3 #{@options.s3Bucket} #{@bucketPath()}"
    @s3().putStream getUrlStream, @bucketPath(), headersToS3, (err, s3StoreRes) ->
      debug "---> Done #{s3StoreRes.req.url}"

      if err
        reject s3: err
      else
        resolve s3StoreRes.req.url

  bufferResponseAndFail: (getUrlStream, resolve, reject) ->
    body = ""

    getUrlStream.on 'data', (chunk) -> body += chunk
    getUrlStream.on 'end', ->
      debug "--> Failed #{getUrlStream.statusCode} #{body}"

      reject
        downloadResponse:
          status: getUrlStream.statusCode
          body: body





module.exports = UrlS3Storer
