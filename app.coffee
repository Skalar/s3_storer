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
app.use require './lib/middleware/redirect_non_ssl'


#
# Routes
#
app.get '/', (req, res) -> res.status(200).end "OK"
app.use '/store', require('./routes/store')
app.use '/delete', require('./routes/delete')

app.use (err, req, res, next) ->
  req.logger.error err.stack if req.logger

  res.status(500).end JSON.stringify
    status: 'error'
    description: 'Internal server error'

module.exports = app
