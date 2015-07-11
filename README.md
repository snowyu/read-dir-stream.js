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
var CustomReaddirStream = require('read-dir-stream')
var stream = CustomReaddirStream(dirName, {readdirFn:fs.readdir, statFn: fs.stat})

```

inherits from:

```js
var fs = require('graceful-fs')
var inherits = require('inherits-ex')
var ReaddirStream = require('read-dir-stream')
function MyReaddirStream() {
  ReaddirStream.apply(this, arguments)
}

inherits(MyReaddirStream, ReaddirStream);

MyReaddirStream.prototype._readdir = fs.readdir;
MyReaddirStream.prototype._stat = fs.stat;

var stream = new MyReaddirStream('.', readdir)

stream.on('data', function(file){
  console.log(file.path)
})
```

## API

### constructor(dirName, options)

* options:
  * readdirFn *(function)*: the readdir function you must be provided
  * statFn *(function)*: the stat function to get the file's stat(must be provided).
  * makeObjFn *(function)*: the optional makeObj callback function to make a file object.
    * the file, stat, cwd aruments will be passed through the function.
      * the file is the file path.
      * the stat is the file stats object if any.
      * the cwd is the dirName to read the dir.
    * the default makeObj function will return the object like this:
      * {path: file, stat: stat, cwd: cwd}
  * deepth *(number)*: the recursive deepth of readdir. defaults to 1.


## License

MIT
