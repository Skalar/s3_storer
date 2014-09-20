RSVP = require 'rsvp'
_ = require 'lodash'
UrlS3Storer = require './url_s3_storer'

class UrlsS3Storer
  constructor: (@urls, @options) ->

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
      storePromises = {}

      for key, url of @urls
        storePromises[key] = new UrlS3Storer(url, @options).store()

      RSVP.hashSettled(storePromises)
        .then (results) =>
          if @allResultsFulfilled results
            resolve @mapPromisResultsToUrls(results)
          else
            reject @cleanSuccessesAndMapToErrors(results)

        .catch (error) ->
          reject error: error



  allResultsFulfilled: (results) ->
    _.every results, state: 'fulfilled'

  mapPromisResultsToUrls: (results) ->
    urls = {}

    for key, result of results
      urls[key] = result.value

    urls

  cleanSuccessesAndMapToErrors: (results) ->
    out = {}

    for key, result of results
      out[key] = result.reason

    out

module.exports = UrlsS3Storer
