nock = require 'nock'
ran = false

# Spec helpers which for instance globally disables net connect
# spec_helper should be required in every test and ran to ensure
# we have same setup in all tests.
#
module.exports = ->
  # As we will be required and ran from multiple files
  # we only want to run once
  return if ran


  beforeEach ->
    # If you need to enable net connect in some
    # tests you make a call to nock.enableNetConnect(). This can be
    # done within a beforeEach in your describe block.
    nock.disableNetConnect()



  ran = true
