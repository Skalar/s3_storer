delete process.env.MORGAN_LOG_FORMAT # Make request log shut up
delete process.env.BASIC_AUTH_USER # Don't enable authentication
delete process.env.BASIC_AUTH_PASSWORD
delete process.env.SENTRY_DSN # Don't need this in test
process.env.REQUIRE_SSL = 'false' # Don't need to require SSL

GLOBAL.sinon = require 'sinon'

GLOBAL.chai = require 'chai'
GLOBAL.expect = chai.expect
chai.use require('chai-as-promised')
