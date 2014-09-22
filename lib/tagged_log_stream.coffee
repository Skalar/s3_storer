stream = require 'stream'
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



module.exports = TaggedLogStream
