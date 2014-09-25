raven = require 'raven'


module.exports = (app) ->
  if sentry_dsn = process.env.SENTRY_DSN
    raven.patchGlobal sentry_dsn
    app.use raven.middleware.express sentry_dsn
