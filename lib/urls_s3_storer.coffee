RSVP = require 'rsvp'
UrlS3Storer = require './url_s3_storer'

class UrlsS3Storer
  constructor: (@urls, @options) ->

  store: ->
    new RSVP.Promise (resolve, reject) ->
      resolve
        urls:
          thumb: 'foo'



module.exports = UrlsS3Storer
