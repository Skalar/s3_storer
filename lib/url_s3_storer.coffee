sha1 = require 'sha1'
concat = require 'concat-stream'
S3Client = require './s3_client'
http = require 'http'
https = require 'https'
RSVP = require 'rsvp'
Timers = require './timers'

class UrlS3Storer
  constructor: (@url, @options) ->
    @logger = @options.logger
    @timers = new Timers

  log: (msg, level = 'info') -> @logger[level](msg) if @logger

  # Public: Download url and stores on S3.
  #
  # Resolves with the URL to S3, or cloud front url if cloud front given in options
  #
  # Rejects with either:
  #   downloadResponse: {status: xxx, body: 'xxx'}
  #   s3: 'Upload to S3 failed' | errorObject
  store: ->
    new RSVP.Promise (resolve, reject) =>
      @timers.start 'download'

      @httpClient().get @url, (getUrlStream) =>
        if @isHttpStatusOk getUrlStream.statusCode
          @log "-> GET #{@url} (#{@timers.stop 'download'} ms)"
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

    @timers.start 'upload'
    @log "--> UPLOAD #{@url} to S3"

    @s3Client().putObject(params)
      .then (data) =>
        @log "---> DONE UPLOADING #{@url} to #{@options.s3Bucket}/#{@bucketKey()} (#{@timers.stop 'upload'} ms)"
        resolve @uploadedUrl()
      .catch (err) =>
        @log "---> FAILED UPLOADING #{@url} to #{@options.s3Bucket}/#{@bucketKey()} due to #{err} (#{@timers.stop 'upload'} ms)"
        reject s3: err


  bufferResponseAndFail: (failedStream, resolve, reject) ->
    failedStream.pipe concat (buffer) =>
      body = buffer.toString()
      @log "--> Failed #{failedStream.statusCode} #{body} (#{@timers.stop 'download'} ms)"

      reject
        downloadResponse:
          status: failedStream.statusCode
          body: body




module.exports = UrlS3Storer
