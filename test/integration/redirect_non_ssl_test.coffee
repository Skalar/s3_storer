require('../spec_helper')()

nock = require 'nock'
app = require '../../app'
request = require 'supertest'

requireSslWas = process.env.REQUIRE_SSL
behindProxyWas = process.env.BEHIND_PROXY

describe "GET /", ->
  beforeEach ->
    nock.enableNetConnect()
    process.env.BEHIND_PROXY = 'true'

  afterEach ->
    process.env.REQUIRE_SSL = requireSslWas
    process.env.BEHIND_PROXY = behindProxyWas

  describe "not require SSL", ->
    beforeEach ->
      process.env.REQUIRE_SSL = 'false'

    it "returns 200 OK for HTTP", (done) ->
      request(app)
        .get('/')
        .set('X-Forwarded-Proto', 'http')
        .expect(200, "OK", done)

    it "returns 200 OK for HTTPs", (done) ->
      request(app)
        .get('/')
        .set('X-Forwarded-Proto', 'https')
        .expect(200, "OK", done)


    describe "require SSL", ->
      beforeEach ->
        process.env.REQUIRE_SSL = 'true'

      it "returns 426 for HTTP", (done) ->
        request(app)
          .get('/')
          .set('X-Forwarded-Proto', 'http')
          .expect(
            426,
            "WARNING! Your S3 credentials has been compromised as you sent them over http.",
            done
          )


      it "returns 200 OK for HTTPs", (done) ->
        request(app)
          .get('/')
          .set('X-Forwarded-Proto', 'https')
          .expect(200, "OK", done)
