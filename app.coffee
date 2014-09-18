express = require 'express'
debug = require('debug')('s3_storer')
logger = require 'morgan'

app = express()

app.use logger(process.env.MORGAN_LOG_FORMAT)

app.post '/store', (req, res) ->
  res.set('Content-Type', 'application/json')

  count = 0
  started = new Date()

  emitter = (waitSeconds) ->
    setTimeout(
      ->
        debug "Write new line response to keep connection alive"
        res.write "\n"
        count++
        if count < 5
          debug "Enque new emitter in #{waitSeconds} from now!"
          emitter(waitSeconds)
        else
          ended = new Date()
          json = JSON.stringify
            started: started
            ended: ended
            duration: "#{(ended - started) / 1000} sec"

          debug "Completed - end request"
          res.end(json)

      waitSeconds * 1000
    )

  debug "Started request"
  emitter(15)


module.exports = app
