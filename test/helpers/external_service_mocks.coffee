fs = require 'fs'
nock = require 'nock'
sha1 = require 'sha1'

module.exports =
  nockFilePickerServer: (path) ->
    testFilePath = './test/assets/photo.jpg'
    testFileSize = fs.statSync(testFilePath)['size']

    nock('https://www.filepicker.io')
      .defaultReplyHeaders(
        'Content-Type': 'images/jpeg'
        'Content-Length': testFileSize
      )
      .get(path)
      .reply 200, (uri, requestBody) ->
        fs.createReadStream testFilePath

  nockS3Api: (url, options, status = 200) ->
    path = sha1 url
    s3Endpoint = "https://#{options.s3Bucket}.s3.#{options.s3Region}.amazonaws.com"

    nock(s3Endpoint)
      .put("/#{path}")
      .reply status
