require('../../spec_helper')()

nock = require 'nock'
getPort = require('get-port')
awsOptions = require '../../helpers/aws_options'
verifyDataEqual = require '../../helpers/verify_data_equal'
app = require '../../../app'
S3Client = require '../../../lib/s3_client'
request = require 'supertest'
_ = require 'lodash'



validRequestJson = null
s3Client = new S3Client awsOptions()

describe "POST /store", ->
  @timeout 10000

  beforeEach ->
    validRequestJson =
      urls:
        thumb: 'https://raw.githubusercontent.com/Skalar/s3_storer/master/test/assets/photo-thumb.jpg'
        monitor: 'https://raw.githubusercontent.com/Skalar/s3_storer/master/test/assets/photo.jpg'
      options: awsOptions()

    nock.enableNetConnect()


  describe "valid requests", ->
    afterEach ->
      s3Client.deleteUrls(
        [
          "http://#{awsOptions().s3Bucket}.s3-#{awsOptions().s3Region}.amazonaws.com/963d49d5940f69183e56f9bcf4a344f500638d8e"
          "http://#{awsOptions().s3Bucket}.s3-#{awsOptions().s3Region}.amazonaws.com/93daf232ad1a85e88be7aa622c83de9e261254ad"
        ]
        awsOptions().s3Bucket
      ).catch (err) -> console.log "FAILED to clean after integration tests! Error: #{err}"

    it "responds with 200 OK and a URL s3 for given files", () ->
      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        then (res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'ok'
          expect(response.urls).to.deep.eq
            thumb: "http://#{awsOptions().s3Bucket}.s3-#{awsOptions().s3Region}.amazonaws.com/963d49d5940f69183e56f9bcf4a344f500638d8e"
            monitor: "http://#{awsOptions().s3Bucket}.s3-#{awsOptions().s3Region}.amazonaws.com/93daf232ad1a85e88be7aa622c83de9e261254ad"

    it "returns URLs where the stored data is what we expect it to be", () ->
      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        then (res) ->
          response = JSON.parse res.text

          expect(verifyDataEqual(
            validRequestJson.urls.thumb
            response.urls.thumb
          )).to.eventually.eq(true).notify ->
            expect(verifyDataEqual(
              validRequestJson.urls.monitor
              response.urls.monitor
            )).to.eventually.eq(true).notify done

    it "responds with 200 OK and a URL cloud front host when given", () ->
      validRequestJson.options.cloudfrontHost = 'xxx.cloudfront.net'

      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        then (res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'ok'
          expect(response.urls).to.deep.eq
            thumb: 'http://xxx.cloudfront.net/963d49d5940f69183e56f9bcf4a344f500638d8e'
            monitor: 'http://xxx.cloudfront.net/93daf232ad1a85e88be7aa622c83de9e261254ad'




  describe "invalid requests", ->
    it "responds with useful error when AWS credentials are wrong", () ->
      validRequestJson.options.awsSecretAccessKey = 'foobar'

      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        then (res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'error'
          expect(response.urlsWithError).to.have.deep.property 'thumb.s3.code', 'SignatureDoesNotMatch'
          expect(response.urlsWithError).to.have.deep.property 'thumb.s3.statusCode', 403
          expect(response.urlsWithError).to.have.deep.property 'monitor.s3.code', 'SignatureDoesNotMatch'
          expect(response.urlsWithError).to.have.deep.property 'monitor.s3.statusCode', 403


    it "responds with 422 when urls are missing", () ->
      json = validRequestJson
      delete json.urls

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/']).to.contain 'Missing required property: urls'


    it "responds with 422 when urls are invalid", () ->
      json = validRequestJson
      json.urls =
        foo: 'bar'

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/urls/foo']).to.contain 'Format validation failed (URL expected)'


    it "status error on connection refused", () ->
      getPort().
      then (port) ->
        json = validRequestJson
        json.urls.thumb = "http://localhost:#{port}/"

        request(app).
          post('/store').
          send(json).
          expect(200).
          then (res) ->
            response = JSON.parse res.text

            expect(response.status).to.eq 'error'
            expect(response.urlsWithError).to.have.deep
              .property 'thumb.downloadResponse.status', 'ECONNREFUSED'
            expect(response.urlsWithError).to.have.deep
              .property 'thumb.downloadResponse.body', "Error: connect ECONNREFUSED 127.0.0.1:#{port}"


    it "responds with 422 when options are missing", () ->
      json = validRequestJson
      delete json.options

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/']).to.contain 'Missing required property: options'


    it "responds with 422 when awsAccessKeyId", () ->
      json = validRequestJson
      delete json.options.awsAccessKeyId

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/options']).to.contain 'Missing required property: awsAccessKeyId'


    it "responds with 422 when cloudfrontHost is invalid", () ->
      json = validRequestJson
      json.options.cloudfrontHost = "dummy"

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/options/cloudfrontHost']).to.contain 'Format validation failed (URL expected)'


    it "responds with 422 when aws region is missing", () ->
      json = validRequestJson
      delete json.options.s3Region

      request(app).
        post('/store').
        send(json).
        expect(422).
        then (res) ->
          expect(res.body.errors['/options']).to.contain 'Missing required property: s3Region'
