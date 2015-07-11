inherits      = require 'inherits-ex'
path          = require 'path-ex'
isNumber      = require 'util-ex/lib/is/type/number'
isFunction    = require 'util-ex/lib/is/type/function'
isObject      = require 'util-ex/lib/is/type/object'
defineProperty= require 'util-ex/lib/defineProperty'
Readable      = require('stream').Readable
Readable      = require('readable-stream').Readable unless Readable
pathJoin      = path.join

module.exports = class ReaddirStream
  inherits ReaddirStream, Readable

  constructor: (dir, options)->
    if not (@ instanceof ReaddirStream)
      return new ReaddirStream dir, options

    if isObject dir
      options = dir
      dir = '.'
    options?={}
    options.highWaterMark?=1
    options.objectMode = true

    Readable.call @, options

    if isNumber options.deepth
      deepth = options.deepth
    if isNumber options.highWaterMark
      highWaterMark = options.highWaterMark
    if isFunction(t = options.makeObjFn)
      defineProperty @, '_makeObj', t
    if isFunction(t = options.readdirFn)
      defineProperty @, '_readdir', t
    if isFunction(t = options.statFn)
      defineProperty @, '_stat', t
    deepth?= 1

    defineProperty @, '_cwd', dir
    defineProperty @, '_queue', [dir]
    defineProperty @, '_deepth', deepth
  _makeObj: (file, stat, cwd)->
    path: file
    stat: stat
    cwd: cwd
  _readdir: (dir, done)->
    done(new Error 'readdir function is not provided.')
  _stat: (file, done)->
    done(new Error 'stat function is not provided.')
  readdir: (dir, cb)->
    @_readdir dir, (err, result)->
      if not err
        result = result.map (file)->pathJoin(dir, file)
      cb(err, result)
  _read: ->
    queue = @_queue
    cwd   = @_cwd
    pushDir = (dir, stat)=>
      @readdir dir, (err, list)=>
        if not err
          @_deepth--
          queue.push.apply queue, list
          if cwd isnt dir # skip the dir itself.
            @push @_makeObj dir, stat, cwd
          else @_read()
        else
          @emit('error', err)
        return

    if queue.length
      file = queue.shift()
      @_stat file, (err, stat)=>
        if not err
          if stat.isDirectory() and @_deepth>=0
            pushDir file, stat
          else
            @push @_makeObj file, stat, cwd
        else
          @emit('error', err)
        return
    else # end of this steam.
      @push null
    return
