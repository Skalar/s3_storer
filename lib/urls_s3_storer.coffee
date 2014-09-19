RSVP = require 'rsvp'
_ = require 'lodash'
UrlS3Storer = require './url_s3_storer'

class UrlsS3Storer
  constructor: (@urls, @options) ->

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


module.exports = UrlsS3Storer
