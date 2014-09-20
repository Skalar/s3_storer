nock = require 'nock'
UrlsS3Storer = require '../../../lib/urls_s3_storer'
serviceMocks = require '../../helpers/external_service_mocks'
awsOptions = require('../../helpers/aws_options')()

storer = null

urls =
  thumb: 'https://www.filepicker.io/api/file/thumb'
  monitor: 'https://www.filepicker.io/api/file/monitor'


describe "UrlsS3Storer", ->
  beforeEach ->
    nock.disableNetConnect()
    storer = new UrlsS3Storer urls, awsOptions

  afterEach ->
    nock.enableNetConnect()


  describe "success", ->
    beforeEach ->
      serviceMocks.nockFilePickerServer '/api/file/thumb'
      serviceMocks.nockFilePickerServer '/api/file/monitor'
      serviceMocks.nockS3Api urls.thumb, awsOptions
      serviceMocks.nockS3Api urls.monitor, awsOptions

    it "returns expected set of urls pointing to S3", ->
      expect(storer.store()).to.eventually.have.deep.eq
        thumb: "http://#{awsOptions.s3Bucket}.s3-#{awsOptions.s3Region}.amazonaws.com/c0d0e5b6d2dc601831a6d51adfc034f87c351c4b"
        monitor: "http://#{awsOptions.s3Bucket}.s3-#{awsOptions.s3Region}.amazonaws.com/7b0e739fa4547913899bebc9d16abe11b538cbe2"


    it "returns the cached url with CloudFront when configured", ->
      storer.options.cloudfrontHost = 'd2ykkbppfz0lno.cloudfront.net'

      expect(storer.store()).to.eventually.have.deep.eq
        thumb: "http://#{storer.options.cloudfrontHost}/c0d0e5b6d2dc601831a6d51adfc034f87c351c4b"
        monitor: "http://#{storer.options.cloudfrontHost}/7b0e739fa4547913899bebc9d16abe11b538cbe2"


  # describe "failures"
