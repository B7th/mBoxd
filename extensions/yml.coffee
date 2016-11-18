yml = require 'node-yaml'
pug = require 'pug' # ?

# Creates also L for locals, an object which checks at each new branch whether it exists or not to avoid error

module.exports = (filename, imp, cb) =>
  data = yml.readSync filename
  if filename is @base + 'data.yml' # prime data.yml
    rmdir @into, (err, files) =>
      @build()