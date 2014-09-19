debug = require('debug')('s3_storer:url_s3_storer')
sha1 = require 'sha1'
S3Client = require './s3_client'
http = require 'http'
https = require 'https'
RSVP = require 'rsvp'

class UrlS3Storer
  constructor: (@url, @options) ->

  # Public: Download url and stores on S3.
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
  s3Url: -> "http://#{@options.s3Bucket}.s3-#{@options.s3Region}.amazonaws.com/#{@bucketKey()}"
  cloudfrontUrl: -> "http://#{@options.cloudfrontHost}/#{@bucketKey()}"
  uploadedUrl: -> if @options.cloudfrontHost then @cloudfrontUrl() else @s3Url()

  s3Client: -> new S3Client @options
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

    @s3Client().putObject(params)
      .then (data) =>
        debug "---> Done #{@options.s3Bucket} #{@bucketKey()}"
        resolve @uploadedUrl()
      .catch (err) ->
        debug "---> Failed bucket upload #{err}."
        reject s3: err


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
