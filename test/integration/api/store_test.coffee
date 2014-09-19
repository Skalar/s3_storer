app = require '../../../app'
request = require 'supertest'

describe "POST /store", ->
  # describe "valid requests", ->
  #   @timeout 60000
  #
  #   afterEach ->
  #     console.log "REMEMBER TO REMOVE FILES FROM S3!!"
  #
  #   it "responds with 200 ok and a", (done) ->
  #     request(app).
  #       post('/store').
  #       send(
  #         urls:
  #           thumb: 'https://www.filepicker.io/api/file/JhJKMtnRDW9uLYcnkRKW/convert?crop=41,84,220,220'
  #       ).
  #       expect(200).
  #       end (err, res) ->
  #         expect(res.urls.thumb).to.eq 'some-s3-bucket-url'
  #         done()

  describe "invalid requests", ->
    it "responds with 422 when urls are missing", (done) ->
      request(app).
        post('/store').
        send({dummy: 'data'}).
        expect(422, done)
