express = require 'express'
router = express.Router()
keepAlive = require '../lib/middleware/keep_alive'
bodyParser = require 'body-parser'
_ = require 'lodash'




router.use keepAlive(
  process.env.KEEP_ALIVE_WAIT_SECONDS || 15,
  process.env.KEEP_ALIVE_MAX_ITERATIONS || 10
)
router.use bodyParser.json()


router.post '/', (req, res) ->
  if _.isEmpty req.body.urls
    res.status(422).end JSON.stringify status: 'error'
  else
    res.set('Content-Type', 'application/json')


module.exports = router
