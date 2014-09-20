express = require 'express'
logger = require 'morgan'

app = express()

#
# Configuration
#
app.set 'trust proxy', -> process.env.BEHIND_PROXY is 'true'


#
# Middlewares
#
app.use logger process.env.MORGAN_LOG_FORMAT if process.env.MORGAN_LOG_FORMAT
app.use require './lib/middleware/auth'
app.use require './lib/middleware/redirect_non_ssl'


#
# Routes
#
app.get '/', (req, res) -> res.status(200).end "OK"
app.use '/store', require('./routes/store')

module.exports = app
