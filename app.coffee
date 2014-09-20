express = require 'express'
logger = require 'morgan'

app = express()

#
# Middlewares
#
app.use logger process.env.MORGAN_LOG_FORMAT if process.env.MORGAN_LOG_FORMAT
app.use require './lib/middleware/deny_non_ssl'


#
# Routes
#
app.get '/', (req, res) -> res.status(200).end "OK"
app.use '/store', require('./routes/store')

module.exports = app
