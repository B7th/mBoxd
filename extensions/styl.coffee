styl = require 'stylus'
nib = require 'nib'

module.exports = (name, imports, write) ->
  @read name, (text) =>
    try styl.render text, paths: imports, compress: false, (err, text) =>
      console.log err if err
      write text
    catch e
      log e
  # minify and others

module.exports.ext = 'css'
