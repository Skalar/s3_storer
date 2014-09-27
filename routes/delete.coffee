express = require 'express'
router = express.Router()
bodyParser = require 'body-parser'
validation = require '../lib/validation'
S3Client = require '../lib/s3_client'


router.use bodyParser.json()

router.delete '/', (req, res) ->
  errors = validation.validate req.body, 'delete'

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
