express = require 'express'
router = express.Router()
keepAlive = require '../lib/middleware/keep_alive'
validation = require '../lib/validation'
bodyParser = require 'body-parser'
UrlS3Storer = require '../lib/urls_s3_storer'


router.use keepAlive(
  process.env.KEEP_ALIVE_WAIT_SECONDS || 15,
  process.env.KEEP_ALIVE_MAX_ITERATIONS || 10
)

router.use bodyParser.json()

router.post '/', (req, res) ->
  errors = validation.validate req.body, 'store'

  if errors
    res.status(422).json
      status: 'error'
      errors: errors
  else
    options = req.body.options
    options.logger = req.logger
    storer = new UrlS3Storer req.body.urls, options

    res.on 'keepAliveTimeout', -> storer.abortUnlessFinished()

    storer.store()
      .then (urls) ->
        res.end JSON.stringify
          status: 'ok'
          urls: urls
      .catch (urlsWithError) ->
        res.end JSON.stringify
          status: 'error'
          urlsWithError: urlsWithError


module.exports = router
