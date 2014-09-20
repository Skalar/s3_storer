module.exports = (req, res, next) ->
  if process.env.REQUIRE_SSL is 'true' and not req.secure
    res.redirect "https://#{req.hostname}#{req.url}"
  else
    next()
