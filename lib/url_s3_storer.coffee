debug = require('debug')('s3_storer:url_s3_storer')
sha1 = require 'sha1'
AWS = require 'aws-sdk'
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
  s3Url: -> "https://#{@options.s3Bucket}.s3-#{@options.s3Region}.amazonaws.com/#{@bucketKey()}"

  s3Client: ->
    new AWS.S3
      accessKeyId: @options.awsAccessKeyId
      secretAccessKey: @options.awsSecretAccessKey
      region: @options.s3Region

  isHttpStatusOk: (code) -> code >= 200 && code < 300
  httpClient: ->if @url.match(/^https/) then https else http




  uploadToS3: (streamToUpload, resolve, reject) ->
    params =
      Bucket: @options.s3Bucket
      Key: @bucketKey()
      Body: streamToUpload
      ACL: 'public-read'
      ContentLength: streamToUpload.headers['content-length']
      ContentType: streamToUpload.headers['content-type']

    debug "--> Uploading to S3 #{@options.s3Bucket} #{@bucketKey()}"

    @s3Client().putObject params, (err, data) =>
      if err
        debug "---> Failed bucket upload #{err}."
        reject s3: err
      else
        debug "---> Done #{@options.s3Bucket} #{@bucketKey()}"
        resolve @s3Url()

  bufferResponseAndFail: (failedStream, resolve, reject) ->
    body = ""

    failedStream.on 'data', (chunk) -> body += chunk
    failedStream.on 'end', ->
      debug "--> Failed #{failedStream.statusCode} #{body}"

      reject
        downloadResponse:
          status: failedStream.statusCode
          body: body





module.exports = UrlS3Storer
