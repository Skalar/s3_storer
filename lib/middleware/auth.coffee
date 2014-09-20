auth = require 'basic-auth'

module.exports = (req, res, next) ->
  user = process.env.BASIC_AUTH_USER
  pass = process.env.BASIC_AUTH_PASSWORD

  if user? and pass?
    credentials = auth req

    if credentials and credentials.name is user and credentials.pass is pass
      next()
    else
      res
        .set('WWW-Authenticate': 'Basic realm="app"')
        .sendStatus 401
  else
    next()
