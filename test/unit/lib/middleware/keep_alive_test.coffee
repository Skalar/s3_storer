require('../../../spec_helper')()
EventEmitter = require('events').EventEmitter

keepAlive = require '../../../../lib/middleware/keep_alive'



class MockResponse extends EventEmitter
  constructor: ->
    super()
    @reset()

  reset: ->
    @writes = []
    @ended = null

  write: (data) -> @writes.push data
  end: (data) -> @ended = data



next = ->
req = {}
res = new MockResponse




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

    it "emits keepAliveTimeout on the response", (done) ->
      middleware req, res, next
      res.on 'keepAliveTimeout', -> done()
      clock.tick 3000
