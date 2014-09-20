require('../spec_helper')()
nock = require 'nock'
app = require '../../app'
request = require 'supertest'

requireSslWas = process.env.REQUIRE_SSL

describe "GET /", ->
  beforeEach ->
    nock.enableNetConnect()

  afterEach ->
    process.env.REQUIRE_SSL = requireSslWas

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

      it "returns 302 for HTTP", (done) ->
        request(app)
          .get('/')
          .set('X-Forwarded-Proto', 'http')
          .end (err, res) ->
            expect(res.statusCode).to.eq 302
            expect(res.header['location']).to.eq 'https://127.0.0.1/'
            done()

      it "returns 200 OK for HTTPs", (done) ->
        request(app)
          .get('/')
          .set('X-Forwarded-Proto', 'https')
          .expect(200, "OK", done)
