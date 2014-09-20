delete process.env.MORGAN_LOG_FORMAT # Make request log shut up

GLOBAL.sinon = require 'sinon'

GLOBAL.chai = require 'chai'
GLOBAL.expect = chai.expect
chai.use require('chai-as-promised')
