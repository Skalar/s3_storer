#!/usr/bin/env coffee

#
# Example of usage: ``./bin/load_test_api.coffee tmp/load_tester_1.json tmp/lt`
#
# * First arg is path to request source file (see load_tester in utils)
# * Second arg is optional, to an existing directory where we'll
#   download files from S3 which the app have just copied.
#   This can be done for inspection.
#

LoadTester = require '../utils/load_tester'

pathToRequestSources = process.argv[2]
pathToWhereToDownloadFilesTo = process.argv[3]

unless pathToRequestSources
  throw new Error "Need a path to source file for requests"

lt = new LoadTester pathToRequestSources
lt.run()
  .then(->
    if pathToWhereToDownloadFilesTo
      lt.downloadUploadedFilesTo pathToWhereToDownloadFilesTo
  )
  .then(-> lt.deleteUploadedFilesFromS3())
  .then(-> console.log "ALL DONE!")
  .catch (err) -> console.log "\nERR --> ", err
