express = require 'express'
logger = require 'morgan'
keepAlive = require './lib/middleware/keep_alive'

app = express()

app.use logger(process.env.MORGAN_LOG_FORMAT)
app.use keepAlive(
  process.env.KEEP_ALIVE_WAIT_SECONDS || 15,
  process.env.KEEP_ALIVE_MAX_ITERATIONS || 10
)


app.post '/store', (req, res) ->
  res.set('Content-Type', 'application/json')

  setTimeout(
    ->
      res.end JSON.stringify {urls: {thumb: 'http://www.example.com'}}
    75000
  )


module.exports = app
