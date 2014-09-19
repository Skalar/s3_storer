express = require 'express'
router = express.Router()
keepAlive = require '../lib/middleware/keep_alive'
UrlS3Storer = require '../lib/urls_s3_storer'
expressValidator = require 'express-validator'
bodyParser = require 'body-parser'
_ = require 'lodash'




router.use keepAlive(
  process.env.KEEP_ALIVE_WAIT_SECONDS || 15,
  process.env.KEEP_ALIVE_MAX_ITERATIONS || 10
)

router.use bodyParser.json()
router.use expressValidator
  customValidators:
    notMissing: (value) -> not _.isEmpty value



router.post '/', (req, res) ->
  req.checkBody('urls', 'missing').notMissing()

  req.checkBody('options', 'missing').notMissing()
  req.checkBody(['options', 'awsAccessKeyId']).notEmpty()
  req.checkBody(['options', 'awsSecretAccessKey']).notEmpty()
  req.checkBody(['options', 's3Bucket']).notEmpty()
  req.checkBody(['options', 's3Region']).notEmpty()
  req.checkBody(['options', 'cloudfrontHost']).optional().isURL()

  errors = req.validationErrors()

  if errors
    res.status(422).json
      status: 'error'
      errors: errors
  else
    storer = new UrlS3Storer req.body.urls, req.body.options
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
