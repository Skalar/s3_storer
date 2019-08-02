delete process.env.MORGAN_LOG_FORMAT # Make request log shut up
delete process.env.BASIC_AUTH_USER # Don't enable authentication
delete process.env.BASIC_AUTH_PASSWORD
delete process.env.SENTRY_DSN # Don't need this in test
process.env.REQUIRE_SSL = 'false' # Don't need to require SSL

global.sinon = require 'sinon'

global.chai = require 'chai'
global.expect = chai.expect

chai.use require('chai-as-promised')
chai.use require('chai-things')
