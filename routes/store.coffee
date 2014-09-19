express = require 'express'
router = express.Router()
keepAlive = require '../lib/middleware/keep_alive'

router.use keepAlive(
  process.env.KEEP_ALIVE_WAIT_SECONDS || 15,
  process.env.KEEP_ALIVE_MAX_ITERATIONS || 10
)


router.post '/', (req, res) ->
  res.set('Content-Type', 'application/json')

  setTimeout(
    ->
      res.end JSON.stringify {urls: {thumb: 'http://www.example.com'}}
    75000
  )


module.exports = router
