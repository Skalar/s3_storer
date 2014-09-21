morgan = require 'morgan'
stream = require 'stream'
uuid = require 'node-uuid'
_ = require 'lodash'

# Helper class used when you want to wirte something to the stdout
# Is available on req.logger.
class TaggedLogStream extends stream.Writable
  constructor: (@tags, @stream = process.stdout) ->
    super()

  info:  (msg) -> @write msg
  warn:  (msg) -> @write msg
  error: (msg) -> @write msg
  debug: (msg) -> @write msg

  _write: (data, enc, next) ->
    @stream.write "#{@tagsAsString()} - #{data}\n"
    next()

  tagsAsString: ->
    tags = _.filter @tags, (tag) -> tag.length > 0
    tags = _.map tags, (tag) -> "[#{tag}]"
    tags.join ' '



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
