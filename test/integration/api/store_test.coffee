require('../../spec_helper')()

nock = require 'nock'
awsOptions = require('../../helpers/aws_options')
verifyDataEqual = require('../../helpers/verify_data_equal')
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
        thumb: 'https://www.filepicker.io/api/file/JhJKMtnRDW9uLYcnkRKW/convert?crop=41,84,220,220'
        monitor: 'https://www.filepicker.io/api/file/JhJKMtnRDW9uLYcnkRKW/convert?crop=0,0,400,400'
      options: awsOptions()

    nock.enableNetConnect()


  describe "valid requests", ->

    afterEach ->
      s3Client.deleteUrls(
        [
          'http://inviso-integration-test.s3-eu-west-1.amazonaws.com/6bb610a613f6ea25e695f7df7d13640be642553c'
          'http://inviso-integration-test.s3-eu-west-1.amazonaws.com/b981b9d5369fc4dd5f71063fb8c0a378c65afd13'
        ]
        awsOptions().s3Bucket
      ).catch (err) -> console.log "FAILED to clean after integration tests! Error: #{err}"

    it "responds with 200 OK and a URL s3 for given files", (done) ->
      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        end (err, res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'ok'
          expect(response.urls).to.deep.eq
            thumb: 'http://inviso-integration-test.s3-eu-west-1.amazonaws.com/6bb610a613f6ea25e695f7df7d13640be642553c'
            monitor: 'http://inviso-integration-test.s3-eu-west-1.amazonaws.com/b981b9d5369fc4dd5f71063fb8c0a378c65afd13'

          done()

    it "returns URLs where the stored data is what we expect it to be", (done) ->
      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        end (err, res) ->
          response = JSON.parse res.text

          expect(verifyDataEqual(
            validRequestJson.urls.thumb
            response.urls.thumb
          )).to.eventually.eq(true).notify ->
            expect(verifyDataEqual(
              validRequestJson.urls.monitor
              response.urls.monitor
            )).to.eventually.eq(true).notify done

    it "responds with 200 OK and a URL cloud front host when given", (done) ->
      validRequestJson.options.cloudfrontHost = 'xxx.cloudfront.net'

      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        end (err, res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'ok'
          expect(response.urls).to.deep.eq
            thumb: 'http://xxx.cloudfront.net/6bb610a613f6ea25e695f7df7d13640be642553c'
            monitor: 'http://xxx.cloudfront.net/b981b9d5369fc4dd5f71063fb8c0a378c65afd13'

          done()

  describe "invalid requests", ->
    it "responds with useful error when AWS credentials are wrong", (done) ->
      validRequestJson.options.awsSecretAccessKey = 'foobar'

      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        end (err, res) ->
          response = JSON.parse res.text

          expect(response.status).to.eq 'error'
          expect(response.urlsWithError).to.have.deep.property 'thumb.s3.code', 'SignatureDoesNotMatch'
          expect(response.urlsWithError).to.have.deep.property 'thumb.s3.statusCode', 403
          expect(response.urlsWithError).to.have.deep.property 'monitor.s3.code', 'SignatureDoesNotMatch'
          expect(response.urlsWithError).to.have.deep.property 'monitor.s3.statusCode', 403

          done()


    it "responds with 422 when urls are missing", (done) ->
      json = validRequestJson
      delete json.urls

      request(app).
        post('/store').
        send(json).
        expect(422).
        end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'urls'

          expect(error.msg).to.eq('missing')
          done()

    it "responds with 422 when options are missing", (done) ->
      json = validRequestJson
      delete json.options

      request(app).
        post('/store').
        send(json).
        expect(422).
        end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'options'

          expect(error.msg).to.eq('missing')
          done()


    it "responds with 422 when awsAccessKeyId", (done) ->
      json = validRequestJson
      delete json.options.awsAccessKeyId

      request(app).
        post('/store').
        send(json).
        expect(422).
        end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'options.awsAccessKeyId'

          expect(error.msg).to.eq('Invalid value')
          done()


    it "responds with 422 when cloudfrontHost is invalid", (done) ->
      json = validRequestJson
      json.options.cloudfrontHost = "dummy"

      request(app).
        post('/store').
        send(json).
        expect(422).
        end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'options.cloudfrontHost'

          expect(error.msg).to.eq('Invalid value')
          done()


    it "responds with 422 when aws region is missing", (done) ->
      json = validRequestJson
      delete json.options.s3Region

      request(app).
        post('/store').
        send(json).
        expect(422).
        end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'options.s3Region'

          expect(error.msg).to.eq('Invalid value')
          done()
