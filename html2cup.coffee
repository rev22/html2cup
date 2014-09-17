{ htmlcup } = require 'htmlcup'

htmlcup = htmlcup.extendObject
  withPhpChunks: (chunks)->
    orig = @
    phpLib = require './phpLib'
    phpLib.chunks = chunks
    lib = orig.extendObject
      phpLib: phpLib 
      origLib: orig
      printHtml: (x)-> @origLib.printHtml(@phpLib.dress(x))
      quoteText: (x)-> @phpLib.dress(@origLib.quoteText(x))
      phpChunk: (k, chunk)->
        @autoSpace() unless @noAutoSpaceBefore
        unless chunk?
          chunk = @chunks[k]
          unless chunk?
            throw "Could not find chuck with key #{k}"
        @origLib.printHtml chunk
        @nesting.spaced = if @noAutoSpace or @noAutoSpaceAfter then 1 else 0
        @
    lib.compileLib()
  _: (x)->
    @nesting.spaced = 1
    @printHtml x if x?
    @
  self: (x)-> @[x + 'Self'] ? @
  S: ()->
    x =
      autoSpaceSelf: @self('autoSpace')
      noAutoSpace: true
      modApplyTag: (tag, f)-> @self('autoSpace').modApplyTag tag, f; @
    x.__proto__ = @self('autoSpace')
    x
  SS: ()->
    x = 
      autoSpaceSelf: @self('autoSpace')
      noAutoSpaceAfter: true
      modApplyTag: (tag, f)-> @self('autoSpace').modApplyTag tag, f; @
    x.__proto__ = @self('autoSpace')
    x
  _n: (x = "\n")->
    @printHtml x
    @
  modApply: (f)-> f.apply @; @
  modApplyTag: (tag, f)->
    oldNesting = @nesting
    try
      @nesting =
        level: oldNesting.level + 1
        tag: tag
        parent: oldNesting
        spaced: oldNesting.spaced
      @modApply f
    finally
      oldNesting.spaced = @nesting.spaced 
      @nesting = oldNesting
    @
  nesting:
    level: 0
  autoSpace: (justTest)->
    return if @noAutoSpace
    return if @nesting.spaced
    spacing = "\n" + Array(@nesting.level + 1).join("    ")
    return spacing if justTest
    @_ spacing
  commentTag: (x)->
    @autoSpace() unless @noAutoSpaceBefore
    @printHtml "<!--#{x}-->"
    @nesting.spaced = if @noAutoSpace or @noAutoSpaceAfter then 1 else 0
    @
  compileTag: (tagName, isVoid, isRawText) -> tag = { tagName, isVoid, isRawText }; (args...) ->
    @autoSpace() unless @noAutoSpaceBefore
    @printHtml "<#{tagName}"
    for arg in args
      if typeof arg is 'function'
        f = arg
        break
      if typeof arg is 'string'
        s = arg
        break
      for x,y of arg
        if y?
          @printHtml " #{x}=\"#{@quoteText y}\""
        else
          @printHtml " #{x}"
    @printHtml '>'
    if isVoid
      @nesting.spaced = if @noAutoSpace or @noAutoSpaceAfter then 1 else 0
      return
    else
      @nesting.spaced = 0
    if f
      @modApplyTag tag, f
    else if s?
      if isRawText
        @_ s
      else
        @_ @quoteTagText(s)
    else
      @nesting.spaced = 1
    @autoSpace()
    @printHtml '</' + tagName + '>'
    @nesting.spaced = if @noAutoSpace or @noAutoSpaceAfter then 1 else 0
    @

htmlcup = htmlcup.compileLib()

module.exports = htmlcup
