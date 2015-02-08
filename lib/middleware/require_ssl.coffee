module.exports = (req, res, next) ->
  if process.env.REQUIRE_SSL is 'true' and not req.secure
    res.status(426)
    res.end("WARNING! Your S3 credentials has been compromised as you sent them over http.")
  else
    next()
