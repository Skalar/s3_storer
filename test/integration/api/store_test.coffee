app = require '../../../app'
request = require 'supertest'
_ = require 'lodash'



validRequestJson = null


describe "POST /store", ->
  beforeEach ->
    validRequestJson =
      urls:
        thumb: 'https://www.filepicker.io/api/file/JhJKMtnRDW9uLYcnkRKW/convert?crop=41,84,220,220'
      options:
        awsAccessKeyId: process.env.TEST_AWS_ACCESS_KEY_ID
        awsSecretAccessKey: process.env.TEST_AWS_SECRET_ACCESS_KEY
        s3Bucket: process.env.TEST_S3_BUCKET
        cloudfrontHost: process.env.TEST_CLOUDFRONT_HOST



  describe "valid requests", ->
    @timeout 60000

    afterEach ->
      console.log "REMEMBER TO REMOVE FILES FROM S3!!"

    it "responds with 200 ok and a URL to cloud front host given", (done) ->
      request(app).
        post('/store').
        send(validRequestJson).
        expect(200).
        end (err, res) ->
          done()

  describe "invalid requests", ->
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
