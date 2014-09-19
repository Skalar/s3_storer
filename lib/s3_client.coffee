AWS = require 'aws-sdk'
RSVP = require 'rsvp'
_ = require 'lodash'


# Exposes a S3 Client which is promise based
class S3Client
  constructor: (@options) ->
    @client = new AWS.S3
      accessKeyId: @options.awsAccessKeyId
      secretAccessKey: @options.awsSecretAccessKey
      region: @options.s3Region

  putObject: (params) ->
    new RSVP.Promise (resolve, reject) =>
      @client.putObject params, (err, data) ->
        if err
          reject err
        else
          resolve data

  deleteUrl: (url, bucket) ->
    @deleteUrls [url], bucket

  # Deletes given urls. Really simple, as
  # this lib only stores all files on s3 with
  # key equal to sha1 of the url we are storing.
  deleteUrls: (urls, bucket) ->
    new RSVP.Promise (resolve, reject) =>
      objectsToDelete = _.map urls, (url) -> {Key: _.last url.split('/')}

      params =
        Bucket: bucket
        Delete:
          Objects: objectsToDelete

      @client.deleteObjects params, (err, data) ->
        if err
          reject err
        else
          resolve data


module.exports = S3Client
