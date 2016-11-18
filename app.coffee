###
#
# mBoxd helps you design by watching file & polling database for changes
#
# the list of actions for each file type encountered
# the private data object constituted of all yml
# if express provided, the jade wrapper with access to the data object
# First goal: Stable Static website with Yaml, Pug, Stylus & Coffeescript.
# (poll database for triggers)
#
###

require('console-stamp')(console, 'HH:MM:ss.l')
log = console.log

requires = 
  #json:    'json'          # 
  express: 'express'
  watch:   'node-watch'    # To watch for "from" directory changes
  glob:    'glob'          # To have access to whole of files
  fs:      'fs'            # To read and Write files, create and delete folders
  yml:     'node-yaml'     # To read data files
  merge:   'merge'         # To merge objects together (recursively)
  copy:    'copy'          # To copy unchanged file into the public folder
  async:   'async'         # Cascade flow easily
  rmdir:   'rmdir'         # Delete intoFolder's content each time the app cleans up
  dirtree: 'dirtree'       # For a tree of all files
global[k] = require v for k, v of requires

mboxd = (app, options) ->
  
  @imps		= __dirname + '/imports/'
  @exts		= __dirname + '/extensions/'
  # easy check whether a file exists or not
  @exists	= (name) ->
    try fs.statSync name
    catch e
      return false
    true
  # reads file
  @read		= (name, call) ->
    try fs.readFile name, 'utf8', (err, text) =>
      throw err if err
      call text
  
  # writes file in the appropriate folder
  @write	= (name, ext, text) ->
    name = name.replace(@data.from, @data.into).replace(/[^.]+$/, ext)
    try fs.writeFile name, text, (err) -> throw err if err
  
  # Copies files that do not need to be changed
  @copy		= (name) ->
    folder = name.replace(@data.from, @data.into).replace /[^/]+$/, ''
    log 'copy', name, folder
    copy.one name, folder, (err,file) -> throw err if err
  
  @base = options.base or require.main.filename.replace /[^/]+$/, ''
  #watch @base + 'data.yml', => m app, @base, options
  @data = merge.recursive yml.readSync @imps + 'yml/data.yml',
    if @exists @base + 'data.yml' then yml.readSync @base + 'data.yml' else {}
  throw "Can't go back folders for security reasons" if /\.\./.test @data.into
  exts = {}
  for x in fs.readdirSync @exts
    exts[x.replace /\..+$/, ''] = require @exts + x
  exts = merge exts, options.exts
  this[ext] = act for ext, act of exts
  
  app.set 'views', @data.from
  app.engine 'pug', @pug.engine
  
  app.use express.static @data.into
  app.engine 'pug', (filePath, options, callback) ->
    #
  
  @tree = dirtree()
    .root    @data.from
    .exclude 'files',  /^\.DS/ #MacRap
    .exclude 'files', /^_/
    .exclude 'dirs', /^_/
    .create()
  # Get @tree and read all yml files
  # Do all other file types and check if newer than possibly existing other (async.map fs.stat)
  #@tree.read true, (err, files) ->
  #  log files
  # watches for changes on the private folder
  @watch = watch @base + @data.from,
    filter: (name) -> !/\/_/.test name # Don't watch private files/folders
    (name) =>
      return null unless @exists name  # Do nothing if the file was just deleted
      ext = name.split('.').pop()
      if this[ext]
        try this[ext] name,
          [name.replace(/[^/]+$/, ''), @imps + ext],
          (content) =>
            log name
            @write name, this[ext].ext, content
        catch e
          log e
      else
        @copy name

module.exports = (app, options={}) -> mboxd app, options

if require.main is module
  app = express()
  mboxd app, {}
  port = 2000
  app.listen port, -> log 'Ready! Server on port %d', port