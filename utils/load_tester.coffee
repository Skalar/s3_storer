debug = require('debug')('s3_storer:load_tester')
RSVP = require 'rsvp'
fs = require 'fs'
http = require 'http'
https = require 'https'
urlParser = require 'url'
concat = require 'concat-stream'
_ = require 'lodash'

# Internal: LoadTester used to .. well, test load against the API
#
# We'll take a source file with requests and run them as fast as you want us to.
# The LoadTester will contain responses where you'll find your original requests
# and their urls have been swapped out for the responses we got from the API.
#
# You can download all files which were uploaded to S3 by calling
# downloadUploadedFilesTo('/a/path/you/like').
#
# Finally you can delete all files which were uploaded to S3 by calling
# deleteUploadedFilesFromS3()
#
# Example of usage
# ----------------
#
#   loadTester = new LoadTester 'path/to/sourceFile.json'
#   loadTester.run()
#     .then(loadTester.downloadUploadedFilesTo('path/you/want'))
#     .then(loadTester.deleteUploadedFilesFromS3())
#     .then -> console.log "ALL DONE!"
#     .catch (err) -> console.log "UPS :( .. GOT ERROR: #{err}"
#
#
#
# Source file
# -----------
#
# The source file is expected to be a json file with format like
# {
#   "api": {
#     "url": "https://your-endpoint.herokuapps.com/",
#     "auth": {
#       "user": "username",
#       "pass": "password"
#     }
#   },
#   "options": {
#     "awsAccessKeyId": "xxx",
#     "awsSecretAccessKey": "xxx",
#     "s3Bucket": "xxx",
#     "s3Region": "xxx",
#   },
#   requests: [
#     {
#       "urls": {
#         "thumb": "http://www.filepicker.com/api/XXX/convert/thumb",
#         "monitor": "http://www.filepicker.com/api/XXX/convert/monitor"
#       }
#     },
#     {
#       "urls": {}
#     }
#   ]
# }
#
#
class LoadTester
  constructor: (sourceFilePath) ->
    @responses = []

    if fs.existsSync sourceFilePath
      debug "source file loaded"
      @source = JSON.parse fs.readFileSync sourceFilePath, 'utf8'
    else
      throw new Error "File #{sourceFilePath} did not exists"

  run: ->
    new RSVP.Promise (resolve, reject) =>
      requestPromises = _.map @source.requests, (request) => @get request
      debug "Running #{requestPromises.length} request(s)."
      RSVP.all(requestPromises)
        .then (responses) =>
          @responses = responses
          resolve responses
        .catch reject


  downloadUploadedFilesTo: (path) ->
    debug "Download files to #{path}"
    debug @responses

    new RSVP.Promise (resolve, reject) ->
      setTimeout resolve, 500

  deleteUploadedFilesFromS3: ->
    debug "Delete files from S3"

    new RSVP.Promise (resolve, reject) ->
      setTimeout resolve, 100





  get: (request) ->
    new RSVP.Promise (resolve, reject) =>
      @apiRequest(request)
        .then (responseBody) -> resolve(responseBody)
        .catch reject



  apiRequest: (urls) ->
    new RSVP.Promise (resolve, reject) =>
      parts = urlParser.parse @source.api.url
      options = _.pick parts, ['hostname', 'path']
      options.method = 'POST'
      options.auth = "#{@source.api.auth.user}:#{@source.api.auth.pass}"
      options.rejectUnauthorized = false

      data = JSON.stringify
        options: @source.options
        urls: urls

      options.headers =
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength data, 'utf8'

      req = @httpClient().request options, (res) ->
        if res.statusCode is 200
          res.pipe concat (buffer) -> resolve buffer.toString()
        else
          res.pipe concat (buffer) ->
            code = res.statusCode
            body = buffer.toString()
            reject "API responded not 200 OK. Was #{code}. Body: '#{body}'"

      req.on 'error', (err) -> reject "CONNECTION ERROR " + err


      req.write data
      req.end()



  httpClient: ->
    return @client if @client?
    url = @source.api.url
    @client = if url.match(/^https/) then https else http




module.exports = LoadTester
