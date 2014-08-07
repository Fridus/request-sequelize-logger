
path = require 'path'
fs = require 'fs'
request = require 'request'

requireTest = (path) ->
  require((process.env.APP_SRV_COVERAGE || '../') + path)

requireLogger = -> requireTest('lib/sequelize-logger')


Sequelize = require 'sequelize'
sequelize = new Sequelize('test', 'root', '')

chai = require 'chai'
assert = chai.assert
expect = chai.expect
chai.should()

describe 'sequelize-logger', ->
  logger = null

  before (done) ->
    logger = requireLogger()('test_sequelize_logger', sequelize, Sequelize)
    sequelize.sync(force: true).done done

  it 'is a function', ->
    expect(requireLogger()).to.be.a('function')

  it 'Simple GET', (done) ->
    req = request.get('http://httpbin.org/get', { qs: { args: 1 } })
    logger(req)

    req.once 'logger-end', (model) ->
      expect(model.url).to.equal('http://httpbin.org/get?args=1')
      expect(model.method).to.equal('GET')
      expect(model.headers).to.deep.equal({
        host: 'httpbin.org'
      })
      expect(model.body).to.equal(undefined)
      expect(model.start).to.a('date')

      expect(model.statusCode).to.equal(200)
      expect(model.resHeaders).to.be.a('object')
      expect(model.resJSON).to.be.a('object')
      expect(model.resBody).to.be.a('object')
      expect(model.time).to.a('number')
      expect(model.end).to.a('date')

      done()

  it 'Simple POST with JSON', (done) ->
    req = request.post 'http://httpbin.org/post',
      json:
        some: data: 1
    logger(req)

    req.once 'logger-end', (model) ->
      expect(model.url).to.equal('http://httpbin.org/post')
      expect(model.method).to.equal('POST')
      expect(model.headers).to.deep.equal({
        accept: 'application/json'
        'content-length': 19
        'content-type': 'application/json'
        host: 'httpbin.org'
      })
      expect(model.body).to.deep.equal(
        some: data: 1
      )
      expect(model.start).to.a('date')

      expect(model.statusCode).to.equal(200)
      expect(model.resHeaders).to.be.a('object')
      expect(model.resJSON).to.be.a('object')
      expect(model.resBody).to.be.a('object')
      expect(model.time).to.a('number')
      expect(model.end).to.a('date')

      done()