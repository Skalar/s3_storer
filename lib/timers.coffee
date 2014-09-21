# Public: Timers class represnets a set of timers which you can start and stop.
#
# Examples
#
#   timers = new Timers
#
#   timers.start 'my-named-timer'
#   timers.start 'other-timer'
#
#   # ...do some work
#
#   durationInMs = timers.stop 'my-named-timer'
#
#   # ..do other work too
#
#   otherDuration = timers.stop 'other-timer'
#
class Timers
  constructor: ->
    @timers = {}


  start: (name) ->
    throw new Error "Timer #{name} allready started!" if @timers[name]?
    @timers[name] = process.hrtime()

  stop: (name, precision = 2) ->
    throw new Error "Timer #{name} never started!" unless @timers[name]?

    diff = process.hrtime @timers[name]
    delete @timers[name]

    ms = diff[0] * 1e3 + diff[1] * 1e-6
    ms.toFixed precision



module.exports = Timers
