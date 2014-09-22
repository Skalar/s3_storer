morgan = require 'morgan'
TaggedLogStream = require '../tagged_log_stream'
uuid = require 'node-uuid'

morgan.token 'tags', (req, res) -> req.logger.tagsAsString()
morganFormat = process.env.MORGAN_LOG_FORMAT
if morganFormat
  morganFormat = morgan[morganFormat]

  if typeof morganFormat is 'function'
    console.log "Can't set up Morgan with tagged as it's format is defined as a function."
  else
    morganFormat = ":tags - #{morganFormat}"


module.exports = (app) ->
  attachLoggerToRequest = (req, res, next) ->
    tags = (req.headers['tag-logs-with'] || "").split ' '
    tags.unshift uuid.v4()

    req.logger = new TaggedLogStream tags
    next()

  if morganFormat
    app.use attachLoggerToRequest
    app.use morgan morganFormat
