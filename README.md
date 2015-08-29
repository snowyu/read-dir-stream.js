## read-dir-stream [![npm](https://img.shields.io/npm/v/read-dir-stream.svg)](https://npmjs.org/package/read-dir-stream)

[![Build Status](https://img.shields.io/travis/snowyu/read-dir-stream.js/master.svg)](http://travis-ci.org/snowyu/read-dir-stream.js)
[![downloads](https://img.shields.io/npm/dm/read-dir-stream.svg)](https://npmjs.org/package/read-dir-stream)
[![license](https://img.shields.io/npm/l/read-dir-stream.svg)](https://npmjs.org/package/read-dir-stream)

the custom readdir-stream class to create an object stream to read a dir.
You should implement your `readdir`, `stat` functions to use it.

## Usage

use it directly:

```js
var fs = require('graceful-fs')
var ReadDirStream = require('read-dir-stream')
var stream = ReadDirStream(dirName, {readdirFn:fs.readdir, statFn: fs.stat})

```

inherits from:

```js
var fs = require('graceful-fs')
var inherits = require('inherits-ex')
var ReadDirStream = require('read-dir-stream')
function MyReadDirStream() {
  ReadDirStream.apply(this, arguments)
}

inherits(MyReadDirStream, ReadDirStream);

MyReadDirStream.prototype._readdir = fs.readdir;
MyReadDirStream.prototype._stat = fs.stat;

var stream = new MyReadDirStream('.', readdir)

stream.on('data', function(file){
  console.log(file.path)
})
```

## API

### constructor(dirName, options)

* options:
  * `cwd` *(String)*: optional the current working directory.
  * `readdirFn` *[function(dirName, done)]*: the readdir function you must be provided
  * `statFn` *[function(fileName, done)]*: the stat function to get the file's stat(must be provided).
  * `makeObjFn` *[function(file)]*: the optional makeObj callback function to make a file object.
    * the `file` object will be passed to makeObjFn function:
      * `path`: is the file path.
      * `stat`: is the file stats object if any.
      * `cwd`: is the dirName of read-dir or cwd if cwd option exist.
    * this `file` will be ignored if return null.
    * this `file` object is used as the default if no makeObjFn provided.
  * deepth *(number)*: the recursive deepth of readdir. defaults to 1.


## License

MIT
