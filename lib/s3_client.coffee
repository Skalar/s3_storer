AWS = require 'aws-sdk'
RSVP = require 'rsvp'
_ = require 'lodash'
urlParser = require 'url'


# Exposes a S3 Client which is promise based
class S3Client
  constructor: (@options, @aws) ->
    @aws ?= new AWS.S3
      accessKeyId: @options.awsAccessKeyId
      secretAccessKey: @options.awsSecretAccessKey
      region: @options.s3Region

  # Public: Puts an object up on s3.
  #
  # params - An object of params as documented by the SDK
  #
  # Example:
  #
  #   params =
  #     Bucket: 'xxx'
  #     Key: 'xxx'
  #     Body: 'xxx'
  #     ACL: 'xxx'
  #     ContentLength: 3
  #     ContentType: 'text/plain'
  #
  #   client.putObject(params)
  #     .then (data) ->
  #     .catch (err) ->
  #
  # Returns a promise
  putObject: (params) ->
    new RSVP.Promise (resolve, reject) =>
      @aws.putObject params, (err, data) ->
        if err
          reject err
        else
          resolve data

  # Public: Deletes objects from S3
  #
  # params - An object of params as documented by the SDK
  #
  # Returns a promise
  deleteObjects: (params) ->
    new RSVP.Promise (resolve, reject) =>
      @aws.deleteObjects params, (err, data) ->
        if err
          reject err
        else
          resolve data




  # Internal: Deletes a given URL from a bucket
  #
  # A bit of a hackish way of doing it, but it works
  # in our current use case, see #deleteUrls()
  #
  # Returns a promise
  deleteUrl: (url, bucket) ->
    @deleteUrls [url], bucket

  # Internal: Deletes an array of URLs from a bucket
  #
  # Deletes given urls. Really simple, as
  # this lib only stores all files on s3 with
  # key equal to sha1 of the url we are storing.
  #
  # Returns a promise
  deleteUrls: (urls, bucket) ->
    unless Array.isArray urls
      return RSVP.reject new Error "URLs must be an array"

    objectsToDelete = _.map urls, (url) ->
      parsed = urlParser.parse url
      pathWithoutFirstForwardSlash =
        parsed.pathname.substring(1, parsed.pathname.length)
      Key: pathWithoutFirstForwardSlash

    params =
      Bucket: bucket
      Delete:
        Objects: objectsToDelete

    @deleteObjects params


module.exports = S3Client