require('../../spec_helper')()

awsOptions = require '../../helpers/aws_options'
request = require 'supertest'
nock = require 'nock'
app = require '../../../app'
S3Client = require '../../../lib/s3_client'
_ = require 'lodash'
http = require 'http'

s3Client = new S3Client awsOptions()

validDeleteRequestJson = null


testFileS3URL = 'http://inviso-integration-test.s3-eu-west-1.amazonaws.com/6bb610a613f6ea25e695f7df7d13640be642553c'
validStoreRequestJson =
  urls:
    thumb: 'https://www.filepicker.io/api/file/JhJKMtnRDW9uLYcnkRKW/convert?crop=41,84,220,220'
  options: awsOptions()

storeTestFileToS3 = (callback) ->
  request(app)
    .post('/store')
    .send(validStoreRequestJson)
    .expect(200, callback)

checkStatusOfTestFile = (expectedStatus, callback) ->
  http.get testFileS3URL, (res) ->
    expect(res.statusCode).to.eq expectedStatus
    callback()









describe "DELETE /delete", ->
  @timeout 10000

  beforeEach ->
    validDeleteRequestJson =
      urls: [testFileS3URL]
      options: awsOptions()

    nock.enableNetConnect()


  afterEach ->
    s3Client.deleteUrl(
      testFileS3URL
      awsOptions().s3Bucket
    ).catch (err) -> console.log "FAILED to clean after integration tests! Error: #{err}"


  describe "success", ->
    it "deletes given URLs as array", (done) ->
      storeTestFileToS3 ->
        checkStatusOfTestFile 200, ->
          request(app)
            .delete('/delete')
            .send(validDeleteRequestJson)
            .expect(200)
            .end (err, res) ->
              response = JSON.parse res.text
              expect(response.status).to.eq 'ok'

              checkStatusOfTestFile 403, done

  describe "invalid requests", ->
    it "responds with 422 when urls are not an array", (done) ->
      json = validDeleteRequestJson
      delete json.urls = ''

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'urls'

          expect(error.msg).to.eq('must be an array')
          done()


    it "responds with 422 when urls are not an array", (done) ->
      json = validDeleteRequestJson
      delete json.urls = []

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'urls'

          expect(error.msg).to.eq('must be at least one URL')
          done()


    it "responds with 422 when aws region is missing", (done) ->
      json = validDeleteRequestJson
      delete json.options.s3Region

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .end (err, res) ->
          error = _.find res.body.errors, (error) -> error.param is 'options.s3Region'

          expect(error.msg).to.eq('Invalid value')
          done()
