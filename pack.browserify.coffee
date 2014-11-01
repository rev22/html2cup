# alert "hello"

process.versions ?= { }
process.node = "0.10.25"
process.stderr ?= { }
errorLog = [ ]
process.stderr.write ?= (x)-> throw new Error "process.stderr.write: #{x}" # errorLog.push x
process.stdout ?= { }
process.stdout.isTTY ?= -> false
process.stdout.write = ->

(require 'fs').readFileSync = (x)->
  if /mime[.]types$/.test(x)
    return """
      application/javascript				js
      application/json				json
      image/gif					gif
      image/jpeg					jpeg jpg jpe
      image/png					png
      text/css					css
      text/html					html htm shtml
      text/plain					asc txt text pot brf srt
      """
  if /node[.]types$/.test(x)
    return """
      text/vtt  vtt
      application/x-chrome-extension  crx
      text/x-component  htc
      text/cache-manifest  manifest
      application/octet-stream  buffer
      application/mp4  m4p
      audio/mp4  m4a
      video/MP2T  ts
      text/event-stream  event-stream
      application/x-web-app-manifest+json   webapp
      text/x-lua  lua
      application/x-lua-bytecode  luac
      text/x-markdown  markdown md mkd
      text/plain  ini
      application/dash+xml mdp
      font/opentype  otf
      """
  if /zombie\/[.][.]\/[.][.]\/package[.]json$/.test(x)
    return """
      {
        "version": "0.1.0"
      }
      """

  throw new Error "Unexpected file requested: #{x}"

(require 'fs').readdirSync = (x)->
  if /properties$/.test(x)
    return []
  throw new Error "Unexpected directory requested: #{x}"

require('fs').existsSync = (x)->
  if /package[.]json$/.test(x)
    return false
  if /node_modules$/.test(x)
    return false
  throw new Error "Unexpected file existence query: #{x}"

window.app = app =
  objs:
    process: process
  eval: window.eval
  global: window.eval 'window'
  window: window

  html2cup: require './html2cup-conv-base'
  htmlcup: require './html2cup'

  require: require

  CoffeeScript: require 'reflective-coffeescript'

  view: ((x)-> r = {}; r[v] = document.getElementById(v) for v in x.split(","); r ) "toButton,fromButton,autoButtonText,htmlArea,htmlcupArea"

  accumulator: [ ]

  printHtml: (s)@>
    @accumulator.push s

  isConverting: false

  setupAutoconvert: @>
    @view.htmlArea.onfocus     = => @view.autoButtonText.innerHTML = "Auto→"
    @view.htmlcupArea.onfocus  = => @view.autoButtonText.innerHTML = "←Auto"
    @view.htmlArea.onblur      = => @view.autoButtonText.innerHTML = "Auto"
    @view.htmlcupArea.onblur   = => @view.autoButtonText.innerHTML = "Auto"
    @view.htmlArea.oninput     = => try @toCup() catch x
    @view.htmlcupArea.oninput  = => try @fromCup() catch x

  setup: @>
    @view.toButton.onclick    = => @toCup()
    @view.fromButton.onclick  = => @fromCup()
    @htmlcup.printHtml = (s)=> @printHtml(s)
    # @fs.readFileSync = (x)=> @readFileSync(x)
    # @fs.writeFileSync = (x)=> @readFileSync(x)
    @setupAutoconvert()
    @ace? and @setupAce()
    @view.htmlArea.setupTransform = (ace)->
      ace.getSession().setMode("ace/mode/html")
      ace.setTheme("ace/theme/merbivore")
    @view.htmlcupArea.setupTransform = (ace)->
      ace.getSession().setMode("ace/mode/coffee")
      ace.setTheme("ace/theme/merbivore")


  # ace: ace ? null
  # setupAce: @> @ace.edit(@view.htmlArea)

  Error: Error

  files: { }

  writeFileSync: (n, d)@>
    @files[n] = d

  readFileSync: (n)@>
    if (d = @files[n])?
      return d
    throw new @Error "Unexpected file requested during conversion: #{n}"

  fs: require 'fs'
  
  toCup: @>
    return if @isConverting
    try
      @isConverting = true
      fileContent = @view.htmlArea.value

      php = null
      inBody = null
      refcoffee = false
      includeChunks = false
      # file = "x.html"
      # @writeFileSync file, fileContent

      r = [ ]

      print = (x)-> r.push x
      echo = (x)-> print "#{x}\n"
      log = (x)->

      { window } = @global
      addEventListener = window.addEventListener

      readyy = =>
        @view.htmlcupArea.value = r.join ''
        @view.htmlcupArea.onchange?()
        @isConverting = false
      
      try
        @html2cup.window = @window
        @html2cup.htmlcupCode = "htmlcup"
        @html2cup.html2cup { fileContent, php, inBody, refcoffee, includeChunks, echo, print, log, readyy }
      finally
        @global.window.addEventListener = addEventListener
    finally
      @isConverting = false
  
  fromCup: @>
    return if @isConverting
    try
      @isConverting = true
      x = @view.htmlcupArea.value
      x = @CoffeeScript.compile x, bare:true
      try
        @accumulator = []
        @eval("(function(){#{x}}).call(htmlcup)")
        @view.htmlArea.value = @accumulator.join ''
        @view.htmlArea.onchange?()
      finally
        @accumulator = []
    finally
      @isConverting = false

  errorLog: errorLog

window.htmlcup = app.htmlcup

app.setup()
