RSVP = require 'rsvp'

class UrlsS3Storer
  constructor: (@urls, @options) ->

  store: ->
    new RSVP.Promise (resolve, reject) ->
      resolve
        urls:
          thumb: 'url'



module.exports = UrlsS3Storer
