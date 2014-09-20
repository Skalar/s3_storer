require('../spec_helper')()

nock = require 'nock'
app = require '../../app'
request = require 'supertest'

userWas = process.env.BASIC_AUTH_USER
passwordWas = process.env.BASIC_AUTH_PASSWORD

describe "GET /", ->
  beforeEach ->
    nock.enableNetConnect()

  beforeEach ->
    process.env.BASIC_AUTH_USER = 'top'
    process.env.BASIC_AUTH_PASSWORD = 'secret'

  afterEach ->
    # Setting ENV var to undefined sets it to 'undefined'
    # as only strings live in env vars.
    if userWas?
      process.env.BASIC_AUTH_USER = userWas
    else
      delete process.env.BASIC_AUTH_USER

    if passwordWas?
      process.env.BASIC_AUTH_PASSWORD = passwordWas
    else
      delete process.env.BASIC_AUTH_PASSWORD

  it "it returns 200 OK if basic auth is disabled", (done) ->
    delete process.env.BASIC_AUTH_USER
    delete process.env.BASIC_AUTH_PASSWORD

    request(app)
      .get('/')
      .expect(200, done)


  it "it returns 401 Unauthorized user/pass is not given", (done) ->
    request(app)
      .get('/')
      .expect(401, done)

  it "it returns 401 Unauthorized when user/pass is incorrect", (done) ->
    request(app)
      .get('/')
      .set('Authorization', "basic #{new Buffer('hack:you!').toString('base64')}")
      .expect(401, done)

  it "it returns 200 ok when user/pass is correct", (done) ->
    request(app)
      .get('/')
      .set('Authorization', "basic #{new Buffer('top:secret').toString('base64')}")
      .expect(200, done)
