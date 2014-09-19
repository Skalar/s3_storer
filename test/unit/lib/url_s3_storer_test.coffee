nock = require 'nock'
sha1 = require 'sha1'
fs = require 'fs'
UrlS3Storer = require '../../../lib/url_s3_storer'



storer = null
filepickerServer = null

url = 'https://www.filepicker.io/api/file/foo'
options =
  awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
  awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
  s3Bucket: process.env.TEST_S3_BUCKET
  s3Region: process.env.TEST_S3_REGION



nockFilePickerServer = ->
  testFilePath = './test/assets/photo.jpg'
  testFileSize = fs.statSync(testFilePath)['size']

  nock('https://www.filepicker.io')
    .defaultReplyHeaders(
      'Content-Type': 'images/jpeg'
      'Content-Length': testFileSize
    )
    .get('/api/file/foo')
    .reply 200, (uri, requestBody) ->
      fs.createReadStream testFilePath

nockS3Api = ->
  s3Path = sha1 url
  s3Endpoint = "https://#{options.s3Bucket}.s3-#{options.s3Region}.amazonaws.com"

  console.log s3Endpoint
  nock(s3Endpoint)
    .put("/#{s3Path}")
    .reply(200)

describe "UrlsS3Storer", ->
  beforeEach ->
    storer = new UrlS3Storer url, options

  describe "#store", ->
    describe "success", ->
      beforeEach ->
        nockFilePickerServer()
        nockS3Api()

      it "resolves with S3 url", ->
        expect(storer.store()).to.eventually
          .eq "https://thorbjorn-tester.s3-eu-west-1.amazonaws.com/5ca5a84a607b14adeefef75617ba8d8585d12573"


    describe "failure", ->
      it "fails with 404", ->
        nock('https://www.filepicker.io').get('/api/file/foo').reply 404, "Not found"
        expect(storer.store()).to.be.rejected.eventually.have.deep.eq
          response:
            status: 404
            body: "Not found"

      it "fails with 502", ->
        nock('https://www.filepicker.io').get('/api/file/foo').reply 502, "Bad Gateway"
        expect(storer.store()).to.be.rejected.eventually.have.deep.eq
          response:
            status: 502
            body: "Bad Gateway"
