express = require 'express'
app = express()

#
# Configuration
#
app.set 'trust proxy', -> process.env.BEHIND_PROXY is 'true'


#
# Middlewares
#
require('./lib/middleware/sentry_raven')(app) # Needs to be on top of everything
require('./lib/middleware/logging')(app)
app.use require './lib/middleware/auth'
app.use require './lib/middleware/require_ssl'


#
# Routes
#
app.get '/', (req, res) -> res.status(200).end "OK"
app.use '/store', require('./routes/store')
app.use '/delete', require('./routes/delete')

app.use (err, req, res, next) ->
  if req.logger
    req.logger.error err.stack
  else
    console.log err.stack

  res.status(500).end JSON.stringify
    status: 'error'
    description: 'Internal server error'

module.exports = app
