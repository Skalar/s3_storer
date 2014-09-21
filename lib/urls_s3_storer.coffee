RSVP = require 'rsvp'
_ = require 'lodash'
UrlS3Storer = require './url_s3_storer'
S3Client = require './s3_client'
Timers = require './timers'

class UrlsS3Storer
  constructor: (@urls, @options, @urlStorerClass = UrlS3Storer) ->
    @logger = @options.logger
    @timers = new Timers
    @abort = false

  log: (msg, level = 'info') -> @logger[level](msg) if @logger

  # Public: If called before we have finished we'll abort.
  #
  # Has no effect when called after we have finished store()
  abortUnlessFinished: ->
    @log "ABORT - asked to abort"
    @abort = true

  # Public: Download all urls and stores on S3.
  #
  # Resolves with an object of the URLs to S3,
  # or cloud front urls if cloud front given in options.
  # Keys are the same as keys was when @urls was set.
  #
  # Rejects with an object where keys are the same as in @urls.
  #   Example of an error:
  #
  #   "thumb": null # Didn't fail, but is cleaned now
  #   "monitor": {
  #     "downloadResponse": {
  #       "status": 502,
  #       "body": "Bad Gateway"
  #     }
  #   }
  #
  #   Another example:
  #
  #   "thumb": null, # Didn't fail, but is cleaned now
  #   "monitor": {
  #     "s3": "Some message from s3 when we tried to upload this file"
  #   }
  #
  # See UrlS3Storer for more information
  #
  store: ->
    new RSVP.Promise (resolve, reject) =>
      @timers.start 'complete-process'
      @log "STARTING download and upload of #{_.keys(@urls).length} urls."

      storePromises = {}

      for ident, url of @urls
        @log "#{ident} - #{url}"
        storePromises[ident] = new @urlStorerClass(ident, url, @options).store()

      RSVP.hashSettled(storePromises)
        .then (results) =>
          if @abort
            @cleanAndAbort results, reject
          else
            if @allResultsFulfilled results
              duration = @timers.stop 'complete-process'
              @log "COMPLETED in #{duration} ms."

              resolve @mapPromisResultsToUrls(results)
            else
              @cleanSuccessesAndMapToErrors results, reject
        .catch (error) =>
          @log "FAILED unexpectedly due to. #{error}"
          reject error: error



  allResultsFulfilled: (results) ->
    _.every results, state: 'fulfilled'

  mapPromisResultsToUrls: (results) ->
    urls = {}

    for key, result of results
      urls[key] = result.value

    urls

  cleanSuccessesAndMapToErrors: (results, done) ->
    out = {}
    urlsToDelete = []

    for key, result of results
      if result.state is 'fulfilled'
        urlsToDelete.push result.value
        out[key] = null
      else
        out[key] = result.reason


    @s3Client().deleteUrls(urlsToDelete, @options.s3Bucket)
      .then =>
        duration = @timers.stop 'complete-process'
        @log "FAILED - clean complete. Duration: #{duration} ms."
        done out
      .catch (err) =>
        @log "FAILED - clean failed too :( Duration: #{duration} ms."
        done err


  cleanAndAbort: (results, done) ->
    out = {}
    urlsToDelete = []

    for key, result of results
      urlsToDelete.push result.value if result.state is 'fulfilled'
      out[key] = aborted: true

    @s3Client().deleteUrls(urlsToDelete, @options.s3Bucket)
      .then =>
        duration = @timers.stop 'complete-process'
        @log "ABORTED - clean complete. Duration: #{duration} ms."
        done out
      .catch (err) =>
        @log "ABORTED - clean failed :( Duration: #{duration} ms."
        done out


  s3Client: -> new S3Client @options



module.exports = UrlsS3Storer
