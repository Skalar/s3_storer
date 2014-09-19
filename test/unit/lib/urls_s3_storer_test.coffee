nock = require 'nock'
serviceMocks = require '../../helpers/external_service_mocks'

UrlsS3Storer = require '../../../lib/urls_s3_storer'

storer = null

urls =
  thumb: 'https://www.filepicker.io/api/file/thumb'
  monitor: 'https://www.filepicker.io/api/file/monitor'

options =
  awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
  awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
  s3Bucket: process.env.TEST_S3_BUCKET
  s3Region: process.env.TEST_S3_REGION


describe "UrlsS3Storer", ->
  beforeEach ->
    nock.disableNetConnect()
    storer = new UrlsS3Storer urls, options

  afterEach ->
    nock.enableNetConnect()


  describe "success", ->
    beforeEach ->
      serviceMocks.nockFilePickerServer '/api/file/thumb'
      serviceMocks.nockFilePickerServer '/api/file/monitor'
      serviceMocks.nockS3Api urls.thumb, options
      serviceMocks.nockS3Api urls.monitor, options

    it "returns expected set of urls pointing to S3", ->
      expect(storer.store()).to.eventually.have.deep.eq
        thumb: "http://#{options.s3Bucket}.s3-#{options.s3Region}.amazonaws.com/c0d0e5b6d2dc601831a6d51adfc034f87c351c4b"
        monitor: "http://#{options.s3Bucket}.s3-#{options.s3Region}.amazonaws.com/7b0e739fa4547913899bebc9d16abe11b538cbe2"


    # it "returns the cached url with CloudFront when configured", ->
    #   storer.options.cloudfrontHost = process.env.TEST_CLOUDFRONT_HOST
    #
    #   expect(storer.store()).to.eventually.have.deep.eq
    #     urls:
    #       thumb: 'foo'


  # describe "failures"
