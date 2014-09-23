express = require 'express'
router = express.Router()
expressValidator = require 'express-validator'
bodyParser = require 'body-parser'
_ = require 'lodash'
S3Client = require '../lib/s3_client'


router.use bodyParser.json()
router.use expressValidator
  customValidators:
    notMissing: (value) -> not _.isEmpty value
    isArray: (value) -> Array.isArray value





router.delete '/', (req, res) ->
  req.checkBody('urls', 'must be an array').isArray()
  req.checkBody('urls', 'must be at least one URL').isLength 1

  # TODO refactor #1 - validation of request
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
    options = req.body.options
    urls = req.body.urls

    client = new S3Client options
    client.deleteUrls(urls, options.s3Bucket)
      .then ->
        res.json status: 'ok'
      .catch (err) ->
        res.status(500).json
          status: 'error'
          description: err



module.exports = router
