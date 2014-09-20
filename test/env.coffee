delete process.env.MORGAN_LOG_FORMAT # Make request log shut up
process.env.REQUIRE_SSL = 'false' # Don't need to require SSL

GLOBAL.sinon = require 'sinon'

GLOBAL.chai = require 'chai'
GLOBAL.expect = chai.expect
chai.use require('chai-as-promised')
