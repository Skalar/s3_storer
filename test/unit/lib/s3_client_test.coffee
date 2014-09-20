require('../../spec_helper')()

nock = require 'nock'
serviceMocks = require '../../helpers/external_service_mocks'
awsOptions = require('../../helpers/aws_options')()
S3Client = require '../../../lib/s3_client'

params =
  Bucket: awsOptions.bucket
  Key: 'test.txt'
  Body: 'This is a unit test'

awsMock = ->
  putObjectSuccess: true
  putObjectParams: null

  deleteObjectsSuccess: true
  deleteObjectsParams: null

  putObject: (params, cb) ->
    @putObjectParams = params
    process.nextTick =>
      if @putObjectSuccess
        cb null, 'putObject success'
      else
        cb 'putObject error', null

  deleteObjects: (params, cb) ->
    @deleteObjectsParams = params
    process.nextTick =>
      if @deleteObjectsSuccess
        cb null, 'deleteObjects success'
      else
        cb 'deleteObjects error', null


client = null
params = dummy: 'params'

describe "S3Client", ->
  beforeEach ->
    client = new S3Client awsOptions, awsMock()


  describe "#putObject", ->
    it "forwards requests to aws client and resolves successfully", ->
      expect(client.putObject(params)).to.eventually.eq 'putObject success'
      expect(client.aws.putObjectParams).to.eq params

    it "forwards requests to aws client and rejects with error", ->
      expect(client.putObject(params)).to.be.rejected.eventually.eq 'putObject error'
      expect(client.aws.putObjectParams).to.eq params


  describe "#deleteObjects", ->
    it "forwards requests to aws client and resolves successfully", ->
      expect(client.deleteObjects(params)).to.eventually.eq 'deleteObjects success'
      expect(client.aws.deleteObjectsParams).to.eq params

    it "forwards requests to aws client and rejects with error", ->
      expect(client.deleteObjects(params)).to.be.rejected.eventually.eq 'deleteObjects error'
      expect(client.aws.deleteObjectsParams).to.eq params



  describe "#deleteUrls", ->
    it "forwards the set of urls and bucket to deleteObjects", ->
      urls = ['http://ex.com/foo', 'http://ex.com/bar']

      expect(client.deleteUrls(urls, 'test')).to.eventually.eq 'deleteObjects success'
      expect(client.aws.deleteObjectsParams).to.deep.eq
        Bucket: 'test'
        Delete:
          Objects: [
            {Key: 'foo'}
            {Key: 'bar'}
          ]

    it "works with long and nested urls with query params", ->
      urls = ['http://ex.com/foo/bar?hello=true']

      expect(client.deleteUrls(urls, 'test')).to.eventually.eq 'deleteObjects success'
      expect(client.aws.deleteObjectsParams).to.deep.eq
        Bucket: 'test'
        Delete:
          Objects: [ {Key: 'foo/bar'} ]

    it "only accepts an array of urls", ->
      expect(client.deleteUrls('no-good', 'bucket')).to.be.rejected

  describe "#deleteUrls", ->
    it "forwards the set of urls and bucket to deleteObjects", ->
      expect(client.deleteUrl('http://ex.com/foo', 'test')).to.eventually.eq 'deleteObjects success'
      expect(client.aws.deleteObjectsParams).to.deep.eq
        Bucket: 'test'
        Delete:
          Objects: [{Key: 'foo'}]
