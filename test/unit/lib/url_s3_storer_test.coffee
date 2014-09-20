require('../../spec_helper')()

nock = require 'nock'
UrlS3Storer = require '../../../lib/url_s3_storer'
serviceMocks = require '../../helpers/external_service_mocks'
awsOptions = require('../../helpers/aws_options')()


storer = null
filepickerServer = null
url = 'https://www.filepicker.io/api/file/foo'


describe "UrlS3Storer", ->
  beforeEach ->
    storer = new UrlS3Storer url, awsOptions

  describe "#store", ->
    describe "success", ->
      beforeEach ->
        serviceMocks.nockFilePickerServer '/api/file/foo'
        serviceMocks.nockS3Api url, awsOptions

      it "resolves with S3 url", ->
        expect(storer.store()).to.eventually
          .eq "http://#{awsOptions.s3Bucket}.s3-#{awsOptions.s3Region}.amazonaws.com/5ca5a84a607b14adeefef75617ba8d8585d12573"

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
