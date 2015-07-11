chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

fs              = require 'fs'
path            = require 'path.js'
inherits        = require 'inherits-ex/lib/inherits'
extend          = require 'util-ex/lib/_extend'
ReaddirStream   = require '../src/'
setImmediate    = setImmediate || process.nextTick

class FReaddirStream
  inherits FReaddirStream, ReaddirStream
  constructor: (dir, opts)->
    return new FReaddirStream(dir, opts) unless this instanceof FReaddirStream
    super
  _readdir: fs.readdir
  _stat: fs.stat
  
describe 'ReaddirStream', ->
  describe '.constructor()', ->
    it 'should create an abstract readdir Stream', (done)->
      stream = ReaddirStream()
      stream.on 'error', (err)->
        err.message.should.have.include 'stat'
        done()
      stream.on 'data', ->
        done(new Error 'should no data')
    it 'should create an abstract readdir Stream(missing statFn)', (done)->
      stream = ReaddirStream('.', statFn: fs.stat)
      stream.on 'error', (err)->
        err.message.should.have.include 'readdir'
        done()
      stream.on 'data', ->
        done(new Error 'should no data')
    it 'should create an readdir Stream', (done)->
      stream = ReaddirStream(path.join(__dirname, 'fixtures'), readdirFn: fs.readdir, statFn: fs.stat)
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.have.length 4
        done()
      stream.on 'data', (file)->
        result.push path.relative file.cwd, file.path
  describe '.on("data")', ->
    lvl1 = [
      '123.md'
      'folder'
      'index.md'
      'readme.md'
    ]
    lvl2 = lvl1.concat [
      'folder/.test'
      'folder/README'
      'folder/sub1'
    ]
    lvl3 = lvl2.concat [
      'folder/.test/index'
      'folder/sub1/2'
      'folder/sub1/readme'
      'folder/sub1/sub2'
    ]
    lvl4 = lvl3.concat [
      'folder/sub1/sub2/index.md'
    ]
    it 'should get Stream data via defaults', (done)->
      stream = FReaddirStream(path.join(__dirname, 'fixtures'))
      stream._deepth.should.be.equal 1
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.be.deep.equal lvl1
        done()
      stream.on 'data', (file)->
        result.push path.relative file.cwd, file.path
    it 'should get Stream data via depth level 2', (done)->
      stream = FReaddirStream(path.join(__dirname, 'fixtures'), deepth:2)
      stream.should.have.property '_deepth', 2
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.be.deep.equal lvl2
        done()
      stream.on 'data', (file)->
        result.push path.relative file.cwd, file.path

    it 'should get Stream data via depth level 3', (done)->
      stream = FReaddirStream(path.join(__dirname, 'fixtures'), deepth:3)
      stream.should.have.property '_deepth', 3
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.be.deep.equal lvl3
        done()
      stream.on 'data', (file)->
        result.push path.relative file.cwd, file.path
    it 'should get Stream data via depth level 4', (done)->
      stream = FReaddirStream(path.join(__dirname, 'fixtures'), deepth:4)
      stream.should.have.property '_deepth', 4
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.be.deep.equal lvl4
        done()
      stream.on 'data', (file)->
        result.push path.relative file.cwd, file.path

    it 'should use custom makeObj function', (done)->
      len = 0
      makeObj = (file)->
        len++
        should.exist file
        should.exist file.stat
        should.exist file.stat
        should.exist file.cwd
        file.stat.should.be.instanceof fs.Stats
        path.relative file.cwd, file.path
      stream = FReaddirStream(path.join(__dirname, 'fixtures'), makeObjFn: makeObj)
      result = []
      stream.on 'error', (err)->
        done(err)
      stream.on 'end', ->
        result.should.be.deep.equal lvl1
        len.should.be.equal lvl1.length
        done()
      stream.on 'data', (file)->
        result.push file
