pug = require 'pug'

# Each request to an element from @data will be
# stored somewhere to check files to recreate when changes are made

# multiplePath = (path=[]) -> # as well as _private ones from the first

# L is accessible directly with @  

module.exports = (name, imports, write) =>
  write pug.renderFile name, filename:name #, plugins: [multiplePath imports]

module.exports.ext = 'html'

module.exports.engine = ->