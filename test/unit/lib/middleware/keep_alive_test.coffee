require('../../../spec_helper')()

keepAlive = require '../../../../lib/middleware/keep_alive'

next = ->
req = {}
res =
  writes: []
  ended: null
  reset: ->
    @writes = []
    @ended = null
  write: (data) -> @writes.push data
  end: (data) -> @ended = data




describe "middleware - keepAlive", ->
  clock = null
  middleware = null

  beforeEach  ->
    clock = sinon.useFakeTimers()
    middleware = keepAlive 1, 2 # wait 1 second, 2 times, then give up

  afterEach ->
    res.reset()
    clock.restore()


  describe "regular end", ->
    it "writes new line each second, but stops if end is called on response", ->
      middleware req, res, next
      expect(res.writes.length).to.eq 0

      clock.tick 1001
      expect(res.writes.length).to.eq 1
      res.end 'some useful response'

      clock.tick 1001
      expect(res.writes.length).to.eq 1

  describe "timeout", ->
    it "writes new line each second", ->
      middleware req, res, next
      expect(res.writes.length).to.eq 0
      clock.tick 1001
      expect(res.writes.length).to.eq 1
      clock.tick 1001
      expect(res.writes.length).to.eq 2

    it "ends with a json error timeout", ->
      middleware req, res, next
      clock.tick 3000
      expect(res.ended).to.eq JSON.stringify(status: "timeout")
