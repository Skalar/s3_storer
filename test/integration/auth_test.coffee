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

  it "it returns 200 OK if basic auth is disabled", () ->
    delete process.env.BASIC_AUTH_USER
    delete process.env.BASIC_AUTH_PASSWORD

    request(app)
      .get('/')
      .expect(200)


  it "it returns 401 Unauthorized user/pass is not given", () ->
    request(app)
      .get('/')
      .expect(401)

  it "it returns 401 Unauthorized when user/pass is incorrect", () ->
    request(app)
      .get('/')
      .set('Authorization', "basic #{new Buffer.from('hack:you!').toString('base64')}")
      .expect(401)

  it "it returns 200 ok when user/pass is correct", () ->
    request(app)
      .get('/')
      .set('Authorization', "basic #{new Buffer.from('top:secret').toString('base64')}")
      .expect(200)
