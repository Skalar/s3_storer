debug = require('debug')('s3_storer:keep_alive')

setupKeepAlive = (res, waitSeconds, maxIterations) ->
  debug "Setting up keep alive.."

  iteration = 0
  emitterTimer = null

  enqueEmit = ->
    emitterTimer = setTimeout(
      ->
        debug "Write new line - keep connection alive."
        res.write "\n"

        if iteration < maxIterations
          debug "Iteration #{iteration} of #{maxIterations}. Enque new emit after #{waitSeconds}s."

          iteration++
          enqueEmit waitSeconds
        else
          debug "No iterations left. End request."

          json = JSON.stringify status: "timeout"
          res.end(json)

      waitSeconds * 1000
    )

  enqueEmit()


  # FIXME
  #
  # Maybe this is a bit hackish?
  #
  originalEnd = res.end
  res.end = (data, encoding) ->
    debug "end() called. Clear emitter and call end()"
    clearTimeout emitterTimer

    res.end = originalEnd
    res.end data, encoding


# Returns a middle ware which has a job of keeping Heroku connections alive
#
# Wrapps around res.end() and ensures that end() also stops our keep alive functionality.
module.exports = (waitSeconds = 15, maxIterations = 10) ->
  (req, res, next) ->
    setupKeepAlive res, waitSeconds, maxIterations
    next()
