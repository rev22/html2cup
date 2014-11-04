module.exports = ({ace, console})@>
 ace.define "ace/mode/refcoffee_highlight_rules", [
  "require"
  "exports"
  "module"
  "ace/lib/oop"
  "ace/mode/text_highlight_rules"
 ], (req, exports, module)->
  oop = undefined
  TextHighlightRules = undefined
  CoffeeHighlightRules = ->
    identifier = undefined
    keywords = undefined
    langConstant = undefined
    illegal = undefined
    supportClass = undefined
    supportFunction = undefined
    variableLanguage = undefined
    keywordMapper = undefined
    functionRule = undefined
    stringEscape = undefined
    identifier = "[$A-Za-z_\\x7f-\\uffff][$\\w\\x7f-\\uffff]*"
    keywords = ("this|throw|then|try|typeof|super|switch|return|break|by|continue|" + "catch|class|in|instanceof|is|isnt|if|else|extends|for|own|" + "finally|function|while|when|new|no|not|delete|debugger|do|loop|of|off|" + "or|on|unless|until|and|yes")
    langConstant = ("true|false|null|undefined|NaN|Infinity")
    illegal = ("case|const|default|function|var|void|with|enum|export|implements|" + "interface|let|package|private|protected|public|static|yield|" + "__hasProp|slice|bind|indexOf")
    supportClass = ("Array|Boolean|Date|Function|Number|Object|RegExp|ReferenceError|String|" + "Error|EvalError|InternalError|RangeError|ReferenceError|StopIteration|" + "SyntaxError|TypeError|URIError|" + "ArrayBuffer|Float32Array|Float64Array|Int16Array|Int32Array|Int8Array|" + "Uint16Array|Uint32Array|Uint8Array|Uint8ClampedArray")
    supportFunction = ("Math|JSON|isNaN|isFinite|parseInt|parseFloat|encodeURI|" + "encodeURIComponent|decodeURI|decodeURIComponent|String|")
    variableLanguage = ("window|arguments|prototype|document")
    keywordMapper = @createKeywordMapper(
      keyword: keywords
      "constant.language": langConstant
      "invalid.illegal": illegal
      "language.support.class": supportClass
      "language.support.function": supportFunction
      "variable.language": variableLanguage
    , "identifier")
    functionRule =
      token: [
        "paren.lparen"
        "variable.parameter"
        "paren.rparen"
        "text"
        "storage.type"
      ]
      regex: /(?:(\()((?:\"[^\")]*?\"|\'[^\')]*?\'|\/[^\/)]*?\/|[^()\"\'\/])*?)(\))(\s*))?([\-=]>)/.source

    stringEscape = /\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|[0-2][0-7]{0,2}|3[0-6][0-7]?|37[0-7]?|[4-7][0-7]?|.)/
    @$rules =
      start: [
        {
          token: "constant.numeric"
          regex: "(?:0x[\\da-fA-F]+|(?:\\d+(?:\\.\\d+)?|\\.\\d+)(?:[eE][+-]?\\d+)?)"
        }
        {
          stateName: "litdoc"
          token: "string"
          regex: "''''"
        }
        {
          stateName: "qdoc"
          token: "string"
          regex: "'''"
          next: [
            {
              token: "string"
              regex: "'''"
              next: "start"
            }
            {
              token: "constant.language.escape"
              regex: stringEscape
            }
            {
              defaultToken: "string"
            }
          ]
        }
        {
          stateName: "qqdoc"
          token: "string"
          regex: "\"\"\""
          next: [
            {
              token: "string"
              regex: "\"\"\""
              next: "start"
            }
            {
              token: "paren.string"
              regex: '#{'
              push: "start"
            }
            {
              token: "constant.language.escape"
              regex: stringEscape
            }
            {
              defaultToken: "string"
            }
          ]
        }
        {
          stateName: "qstring"
          token: "string"
          regex: "'"
          next: [
            {
              token: "string"
              regex: "'"
              next: "start"
            }
            {
              token: "constant.language.escape"
              regex: stringEscape
            }
            {
              defaultToken: "string"
            }
          ]
        }
        {
          stateName: "qqstring"
          token: "string.start"
          regex: "\""
          next: [
            {
              token: "string.end"
              regex: "\""
              next: "start"
            }
            {
              token: "paren.string"
              regex: '#{'
              push: "start"
            }
            {
              token: "constant.language.escape"
              regex: stringEscape
            }
            {
              defaultToken: "string"
            }
          ]
        }
        {
          stateName: "js"
          token: "string"
          regex: "`"
          next: [
            {
              token: "string"
              regex: "`"
              next: "start"
            }
            {
              token: "constant.language.escape"
              regex: stringEscape
            }
            {
              defaultToken: "string"
            }
          ]
        }
        {
          regex: "[{}]"
          onMatch: (val, state, stack)->
            @next = ""
            if val is "{" and stack.length
              stack.unshift "start", state
              return "paren"
            if val is "}" and stack.length
              stack.shift()
              @next = stack.shift() or ""
              return "paren.string"  unless @next.indexOf("string") is -1
            "paren"
        }
        {
          token: "string.regex"
          regex: "///"
          next: "heregex"
        }
        {
          token: "string.regex"
          regex: /(?:\/(?![\s=])[^[\/\n\\]*(?:(?:\\[\s\S]|\[[^\]\n\\]*(?:\\[\s\S][^\]\n\\]*)*])[^[\/\n\\]*)*\/)(?:[imgy]{0,4})(?!\w)/
        }
        {
          token: "comment"
          regex: "###(?!#)"
          next: "comment"
        }
        {
          token: "comment"
          regex: "#.*"
        }
        {
          token: [
            "punctuation.operator"
            "text"
            "identifier"
          ]
          regex: "(\\.)(\\s*)(" + illegal + ")"
        }
        {
          token: "punctuation.operator"
          regex: "\\."
        }
        {
          token: [
            "keyword"
            "text"
            "language.support.class"
            "text"
            "keyword"
            "text"
            "language.support.class"
          ]
          regex: "(class)(\\s+)(" + identifier + ")(?:(\\s+)(extends)(\\s+)(" + identifier + "))?"
        }
        {
          token: [
            "entity.name.function"
            "text"
            "keyword.operator"
            "text"
          ].concat(functionRule.token)
          regex: "(" + identifier + ")(\\s*)([=:])(\\s*)" + functionRule.regex
        }
        functionRule
        {
          token: "variable"
          regex: "@(?:" + identifier + ")?"
        }
        {
          token: keywordMapper
          regex: identifier
        }
        {
          token: "punctuation.operator"
          regex: "\\,|\\."
        }
        {
          token: "storage.type"
          regex: "[\\-=]>"
        }
        {
          token: "keyword.operator"
          regex: "(?:[-+*/%<>&|^!?=]=|>>>=?|\\-\\-|\\+\\+|::|&&=|\\|\\|=|<<=|>>=|\\?\\.|\\.{2,3}|[!*+-=><])"
        }
        {
          token: "paren.lparen"
          regex: "[({[]"
        }
        {
          token: "paren.rparen"
          regex: "[\\]})]"
        }
        {
          token: "text"
          regex: "\\s+"
        }
      ]
      heregex: [
        {
          token: "string.regex"
          regex: ".*?///[imgy]{0,4}"
          next: "start"
        }
        {
          token: "comment.regex"
          regex: "\\s+(?:#.*)?"
        }
        {
          token: "string.regex"
          regex: "\\S+"
        }
      ]
      comment: [
        {
          token: "comment"
          regex: "###"
          next: "start"
        }
        {
          defaultToken: "comment"
        }
      ]

    @normalizeRules()
    return
  "use strict"
  oop = req("../lib/oop")
  TextHighlightRules = req("./text_highlight_rules").TextHighlightRules
  oop.inherits CoffeeHighlightRules, TextHighlightRules
  exports.CoffeeHighlightRules = CoffeeHighlightRules
  return

 ace.define "ace/mode/matching_brace_outdent", [
  "require"
  "exports"
  "module"
  "ace/range"
 ], (req, exports, module)->
  Range = undefined
  MatchingBraceOutdent = undefined
  "use strict"
  Range = req("../range").Range
  MatchingBraceOutdent = ->

  (->
    @checkOutdent = (line, input)->
      return false  unless /^\s+$/.test(line)
      /^\s*\}/.test input

    @autoOutdent = (doc, row)->
      line = undefined
      match = undefined
      column = undefined
      openBracePos = undefined
      indent = undefined
      line = doc.getLine(row)
      match = line.match(/^(\s*\})/)
      return 0  unless match
      column = match[1].length
      openBracePos = doc.findMatchingBracket(
        row: row
        column: column
      )
      return 0  if not openBracePos or openBracePos.row is row
      indent = @$getIndent(doc.getLine(openBracePos.row))
      doc.replace new Range(row, 0, row, column - 1), indent
      return

    @$getIndent = (line)->
      line.match(/^\s*/)[0]

    return
  ).call MatchingBraceOutdent::
  exports.MatchingBraceOutdent = MatchingBraceOutdent
  return

 ace.define "ace/mode/folding/coffee", [
  "require"
  "exports"
  "module"
  "ace/lib/oop"
  "ace/mode/folding/fold_mode"
  "ace/range"
 ], (req, exports, module)->
  oop = undefined
  BaseFoldMode = undefined
  Range = undefined
  FoldMode = undefined
  "use strict"
  oop = req("../../lib/oop")
  BaseFoldMode = req("./fold_mode").FoldMode
  Range = req("../../range").Range
  FoldMode = exports.FoldMode = ->

  oop.inherits FoldMode, BaseFoldMode
  (->
    @getFoldWidgetRange = (session, foldStyle, row)->
      range = undefined
      re = undefined
      line = undefined
      startLevel = undefined
      startColumn = undefined
      maxRow = undefined
      startRow = undefined
      endRow = undefined
      level = undefined
      endColumn = undefined
      range = @indentationBlock(session, row)
      return range  if range
      re = /\S/
      line = session.getLine(row)
      startLevel = line.search(re)
      return  if startLevel is -1 or line[startLevel] isnt "#"
      startColumn = line.length
      maxRow = session.getLength()
      startRow = row
      endRow = row
      while ++row < maxRow
        line = session.getLine(row)
        level = line.search(re)
        continue  if level is -1
        break  unless line[level] is "#"
        endRow = row
      if endRow > startRow
        endColumn = session.getLine(endRow).length
        new Range(startRow, startColumn, endRow, endColumn)

    @getFoldWidget = (session, foldStyle, row)->
      line = undefined
      indent = undefined
      next = undefined
      prev = undefined
      prevIndent = undefined
      nextIndent = undefined
      line = session.getLine(row)
      indent = line.search(/\S/)
      next = session.getLine(row + 1)
      prev = session.getLine(row - 1)
      prevIndent = prev.search(/\S/)
      nextIndent = next.search(/\S/)
      if indent is -1
        session.foldWidgets[row - 1] = (if prevIndent isnt -1 and prevIndent < nextIndent then "start" else "")
        return ""
      if prevIndent is -1
        if indent is nextIndent and line[indent] is "#" and next[indent] is "#"
          session.foldWidgets[row - 1] = ""
          session.foldWidgets[row + 1] = ""
          return "start"
      else if prevIndent is indent and line[indent] is "#" and prev[indent] is "#"
        if session.getLine(row - 2).search(/\S/) is -1
          session.foldWidgets[row - 1] = "start"
          session.foldWidgets[row + 1] = ""
          return ""
      if prevIndent isnt -1 and prevIndent < indent
        session.foldWidgets[row - 1] = "start"
      else
        session.foldWidgets[row - 1] = ""
      if indent < nextIndent
        "start"
      else
        ""

    return
  ).call FoldMode::
  return

 ace.define "ace/mode/refcoffee", [
  "require"
  "exports"
  "module"
  "ace/mode/refcoffee_highlight_rules"
  "ace/mode/matching_brace_outdent"
  "ace/mode/folding/coffee"
  "ace/range"
  "ace/mode/text"
  "ace/worker/worker_client"
  "ace/lib/oop"
 ], (req, exports, module)->
  Rules = undefined
  Outdent = undefined
  FoldMode = undefined
  Range = undefined
  TextMode = undefined
  WorkerClient = undefined
  oop = undefined
  Mode = ->
    @HighlightRules = Rules
    @$outdent = new Outdent()
    @foldingRules = new FoldMode()
    return
  "use strict"
  Rules = req("./refcoffee_highlight_rules").CoffeeHighlightRules
  Outdent = req("./matching_brace_outdent").MatchingBraceOutdent
  FoldMode = req("./folding/coffee").FoldMode
  Range = req("../range").Range
  TextMode = req("./text").Mode
  WorkerClient = req("../worker/worker_client").WorkerClient
  oop = req("../lib/oop")
  oop.inherits Mode, TextMode
  (->
    indenter = undefined
    commentLine = undefined
    hereComment = undefined
    indentation = undefined
    indenter = /(?:[({[=:]|[-=]>|\b(?:else|try|(?:swi|ca)tch(?:\s+[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)?|finally))\s*$|^\s*(else\b\s*)?(?:if|for|while|loop)\b(?!.*\bthen\b)/
    commentLine = /^(\s*)#/
    hereComment = /^\s*###(?!#)/
    indentation = /^\s*/
    @getNextLineIndent = (state, line, tab)->
      indent = undefined
      tokens = undefined
      indent = @$getIndent(line)
      tokens = @getTokenizer().getLineTokens(line, state).tokens
      indent += tab  if not (tokens.length and tokens[tokens.length - 1].type is "comment") and state is "start" and indenter.test(line)
      indent

    @toggleCommentLines = (state, doc, startRow, endRow)->
      range = undefined
      console.log "toggle"
      range = new Range(0, 0, 0, 0)
      i = startRow

      while i <= endRow
        line = doc.getLine(i)
        continue  if hereComment.test(line)
        if commentLine.test(line)
          line = line.replace(commentLine, "$1")
        else
          line = line.replace(indentation, "$&#")
        range.end.row = range.start.row = i
        range.end.column = line.length + 1
        doc.replace range, line
        ++i
      return

    @checkOutdent = (state, line, input)->
      @$outdent.checkOutdent line, input

    @autoOutdent = (state, doc, row)->
      @$outdent.autoOutdent doc, row
      return

    @createWorker = (session)->
      worker = undefined
      worker = new WorkerClient(["ace"], "ace/mode/coffee_worker", "Worker")
      worker.attachToDocument session.getDocument()
      worker.on "error", (e)->
        session.setAnnotations [e.data]
        return

      worker.on "ok", (e)->
        session.clearAnnotations()
        return

      worker

    @$id = "ace/mode/refcoffee"
    return
  ).call Mode::
  exports.Mode = Mode
  return

