inherits      = require 'inherits-ex'
path          = require 'path.js'
isNumber      = require 'util-ex/lib/is/type/number'
isFunction    = require 'util-ex/lib/is/type/function'
isObject      = require 'util-ex/lib/is/type/object'
defineProperty= require 'util-ex/lib/defineProperty'
Readable      = require('stream').Readable
Readable      = require('readable-stream').Readable unless Readable

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
    if options.cwd
      cwd = options.cwd
      dir = path.resolve cwd, dir
    else
      cwd = dir

    defineProperty @, '_cwd', cwd
    defineProperty @, '_base', dir
    defineProperty @, '_queue', [dir]
    defineProperty @, '_deepth', deepth

  _readdir: (dir, done)->
    done(new Error 'readdir function is not provided.')
  _stat: (file, done)->
    done(new Error 'stat function is not provided.')
  isAllowedDeepth: (file)->
    file = path.relative @_base, file
    deepth = path.toArray(file)
    deepth.length < @_deepth
  readdir: (dir, cb)->
    @_readdir dir, (err, result)->
      if not err
        result = result.map (file)->path.join(dir, file)
      cb(err, result)
  _read: ->
    queue = @_queue
    cwd   = @_cwd
    base  = @_base
    pushDir = (dir, stat)=>
      @readdir dir, (err, list)=>
        if not err
          queue.push.apply queue, list
          if base isnt dir
            oFile = path:dir, stat:stat, cwd:cwd
            oFile = @_makeObj(oFile) if @_makeObj
            if oFile?
              @push oFile
            else #skip this
              @_read()
          else # skip the base dir itself.
            @_read()
        else
          @emit('error', err)
        return

    if queue.length
      file = queue.shift()
      @_stat file, (err, stat)=>
        if not err
          if stat.isDirectory() and @isAllowedDeepth(file)
            pushDir file, stat
          else
            oFile = path:file, stat:stat, cwd:cwd
            oFile = @_makeObj(oFile) if @_makeObj
            if oFile?
              @push oFile
            else #skip this
              @_read()
        else
          @emit('error', err)
        return
    else # end of this steam.
      @push null
    return
