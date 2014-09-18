express = require 'express'
logger = require 'morgan'

app = express()

app.use logger(process.env.MORGAN_LOG_FORMAT)

app.post '/store', (req, res) ->
  res.status(201).end()

module.exports = app
