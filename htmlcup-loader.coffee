{ htmlcup } = require 'htmlcup'

htmlcup = htmlcup.extendObject
  _: (x)->
    @nesting.spaced = 1
    htmlcup.printHtml x
  modApply: (x)-> x.apply @
  nesting:
    level: 0
  autoSpacing: (justTest)->
    return if @nesting.spaced
    spacing = "\n" + Array(@nesting.level + 1).join("    ")
    return spacing if justTest
    @_ spacing
  compileTag: (tagName, isVoid, isRawText) -> tag = { tagName, isVoid, isRawText }; (args...) ->
    # @autoSpacing()
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
    # @nesting.spaced = 0
    return if isVoid
    if f
      oldNesting = @nesting
      try
        @nesting =
          level: oldNesting.level + 1
          tag: tag
          parent: oldNesting
        f.apply @
      finally
        @nesting = oldNesting
    if s
      if isRawText
        @printHtml s
      else
        @printHtml @quoteTagText s
    @printHtml '</' + tagName + '>'

htmlcup = htmlcup.compileLib()

module.exports = htmlcup
