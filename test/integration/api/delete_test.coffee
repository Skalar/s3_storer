require('../../spec_helper')()

awsOptions = require '../../helpers/aws_options'
request = require 'supertest'
nock = require 'nock'
app = require '../../../app'
S3Client = require '../../../lib/s3_client'
_ = require 'lodash'
https = require 'https'

s3Client = new S3Client awsOptions()

validDeleteRequestJson = null


testFileS3URL = "https://#{awsOptions().s3Bucket}.s3-#{awsOptions().s3Region}.amazonaws.com/93daf232ad1a85e88be7aa622c83de9e261254ad"
validStoreRequestJson =
  urls:
    thumb: 'https://raw.githubusercontent.com/Skalar/s3_storer/master/test/assets/photo.jpg'
  options: awsOptions()

storeTestFileToS3 = (callback) ->
  request(app)
    .post('/store')
    .send(validStoreRequestJson)
    .expect(200, callback)
  return null

checkStatusOfTestFile = (expectedStatus, callback) ->
  https.get testFileS3URL, (res) ->
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
            .then (res) ->
              response = JSON.parse res.text
              expect(response.status).to.eq 'ok'

              checkStatusOfTestFile 403, done

  describe "invalid requests", ->
    it "responds with 422 when urls are not present", () ->
      json = validDeleteRequestJson
      delete json.urls

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .then (res) ->
          expect(res.body.errors['/']).to.contain 'Missing required property: urls'


    it "responds with 422 when urls are an empty array", () ->
      json = validDeleteRequestJson
      json.urls = []

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .then (res) ->
          expect(res.body.errors['/urls']).to.contain 'Array is too short (0), minimum 1'

    it "responds with 422 when urls contains invalid urls", () ->
      json = validDeleteRequestJson
      json.urls = ['http://www.example.com', 'foo', '']

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .then (res) ->
          expect(res.body.errors['/urls/1']).to.contain 'Format validation failed (URL expected)'
          expect(res.body.errors['/urls/2']).to.contain 'Format validation failed (URL expected)'


    it "responds with 422 when aws region is missing", () ->
      json = validDeleteRequestJson
      delete json.options.s3Region

      request(app)
        .delete('/delete')
        .send(json)
        .expect(422)
        .then (res) ->
          expect(res.body.errors['/options']).to.contain 'Missing required property: s3Region'
