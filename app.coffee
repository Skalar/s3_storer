express = require 'express'
logger = require 'morgan'

app = express()

#
# Middlewares
#
app.use logger(process.env.MORGAN_LOG_FORMAT) if process.env.MORGAN_LOG_FORMAT


#
# Routes
#
app.get '/', (req, res) -> res.send("HELLO")
app.use '/store', require('./routes/store')

module.exports = app
