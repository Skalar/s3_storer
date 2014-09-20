module.exports = (req, res, next) ->
  if process.env.REQUIRE_SSL is 'true' and req.headers['x-forwarded-proto'] isnt 'https'
    res.redirect "https://#{req.hostname}#{req.url}"
  else
    next()
