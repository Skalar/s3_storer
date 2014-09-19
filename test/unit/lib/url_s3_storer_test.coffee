nock = require 'nock'
serviceMocks = require '../../helpers/external_service_mocks'

UrlS3Storer = require '../../../lib/url_s3_storer'


storer = null
filepickerServer = null

url = 'https://www.filepicker.io/api/file/foo'
options =
  awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
  awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
  s3Bucket: process.env.TEST_S3_BUCKET
  s3Region: process.env.TEST_S3_REGION




describe "UrlsS3Storer", ->
  beforeEach ->
    nock.disableNetConnect()
    storer = new UrlS3Storer url, options

  afterEach ->
    nock.enableNetConnect()


  describe "#store", ->
    describe "success", ->
      beforeEach ->
        serviceMocks.nockFilePickerServer '/api/file/foo'
        serviceMocks.nockS3Api url, options

      it "resolves with S3 url", ->
        expect(storer.store()).to.eventually
          .eq "http://#{options.s3Bucket}.s3-#{options.s3Region}.amazonaws.com/5ca5a84a607b14adeefef75617ba8d8585d12573"

      it "resolves with cloud front url when configured", ->
        storer.options.cloudfrontHost = 'd2ykkbppfz0lno.cloudfront.net'

        expect(storer.store()).to.eventually
          .eq "http://d2ykkbppfz0lno.cloudfront.net/5ca5a84a607b14adeefef75617ba8d8585d12573"


    describe "failure", ->
      it "fails with 404", ->
        nock('https://www.filepicker.io').get('/api/file/foo').reply 404, "Not found"
        expect(storer.store()).to.be.rejected.eventually.have.deep.eq
          downloadResponse:
            status: 404
            body: "Not found"

      it "fails with 502", ->
        nock('https://www.filepicker.io').get('/api/file/foo').reply 502, "Bad Gateway"
        expect(storer.store()).to.be.rejected.eventually.have.deep.eq
          downloadResponse:
            status: 502
            body: "Bad Gateway"
