express = require 'express'
router = express.Router()
keepAlive = require '../lib/middleware/keep_alive'
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
  req.checkBody(['options', 'cloudfrontHost']).optional().isURL()

  errors = req.validationErrors()

  if errors
    res.status(422).json
      status: 'error'
      errors: errors
  else
    # TODO magic in stead of this
    out =
      urls:
        thumb: 'url'

    res.end JSON.stringify out


module.exports = router
