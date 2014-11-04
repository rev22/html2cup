# Copyright (c) 2014 Michele Bini

# MIT license

module.exports =
  phpLib: require './phpLib'
  path: require 'path'
  htmlcupCode: "require('html2cup')"
  fs: require 'fs'
  html2cup: ({file, fileContent, php, inBody, refcoffee, includeChunks, echo, print, log, readyy, htmlcupCode, fs })->
    fs ?= @fs
    htmlcupCode ?= @htmlcupCode
    includeChunks = false unless php

    coffeePrinter =
      print: print
      echo: echo
      run: (x)-> x.apply @
      indentation: 0
      p: (x, r)->
        @print Array(@indentation + 1).join "    "
        @echo x
        if r?
          oldIndentation = @indentation
          try
            @indentation++
            @.run(r)
          finally
            @indentation = oldIndentation
        
    php and= @phpLib
    inBody and=
      apply: (x)-> x.apply @

    path = @path
    Browser = @zombie
    browser = @zombie? and new Browser

    q = '"'
    oldQuot = (x)-> q + (x.replace(/["\\]/g, ((x)-> "\\#{x}"))) + q # "
    wQuot = (x)-> q + (x.replace(/["\\\t\r\n]/g, ((x)-> "\\#{x}")).replace(/\\\t/g, "\\t").replace(/\\\r/g, "\\r").replace(/\\\n/g, "\\n")) + q # "
    kQuot = (x)->
      return quot x if (x.length is 0) or (/[^$a-zA-Z0-9_]/).test x
      x

    rQuot = (x, indentation)->
      if refcoffee and /[^a-zA-Z -_.,]/.test x
        x = "''''\n" + x
        x.replace(/(\n|^)/g, "\n" + Array(indentation + 3).join('    '))
      else
        wQuot x

    quot = wQuot

    tempFiles = []
    cleanupTempFiles = ->
      fs.unlinkSync x for x in tempFiles

    php?.reset()

    php?.apply ->
      file ?= "input"
      @x = fileContent ? fs.readFileSync(file).toString()
      @x = @strip @x
      tempFiles.push(@temp = file + '.temp-php.html')
      fs.writeFileSync @temp, @x
      file = @temp
      fileContent and= @x

    @zombie? and inBody?.apply ->
      @x = fs.readFileSync(file).toString()
      @x = '<!doctype html>\n<html><head><title>html2cup temp html</title></head>\n<body>' + @x + '</body></html>\n'
      tempFiles.push(@temp = file + '.temp-in-body.html')
      fs.writeFileSync @temp, @x
      file = @temp

    entQuot = (x) ->
        x.replace /[&<>\" ]/g, (c) ->
          if c is '<'
            '&lt;'
          else if c is '>'
            '&gt;' # is this necessary?
          else if c is '&'
            '&amp;'
          else if c is '"'
            '&quot;'
          else
            "&nbsp;"

    withPageReady = if @zombie?
      url = 'file://' + path.resolve(file)

      log "loading #{url}"
      (x)-> browser.visit url, runScripts:false, loadCss:false, x
    else
      (x)->
        el = @window.document.createElement(if @inBody then "div" else "html")
        el.innerHTML = fileContent
        browser =
          document: el
          close: ->
        x isFragment:true

    withPageReady ({ isFragment })->
      cleanupTempFiles()
      try
        { doctype, head, body } = browser.document

        unless isFragment
          throw "document.doctype is missing!"  unless doctype?
          throw "document.head is missing!"     unless head?
          throw "document.body is missing!"     unless body?

        coffeePrinter.run ->
          attributes = (x)->
            r = []
            for y in (x.attributes ? [])
              { name, value } = y
              if 'string' is typeof name and 'string' is typeof value
                if (chunkContent = php?.idToChunk(value))?
                  value = """
                    @php(#{quot chunkContent})
                    """
                else
                  value = quot value
                r.push "#{kQuot name}:#{value}, "
            r.join ''
          printTree = (indentation, line, obj)=>
            pt = (line, obj)-> printTree(indentation + 1, line, obj)
            autoSpacing = -> "\n" + Array(indentation+1).join("    ")
            @p "#{line}", ->
              i = 0
              { childNodes } = obj
              if includeChunks
                n = []
                for y in childNodes
                  if y.nodeType is 3 and obj.tagName isnt 'SCRIPT' and obj.tagName isnt 'STYLE'
                    for z in php.split y.textContent
                      n.push
                        textContent: z
                        nodeType: if php.idp z
                          'phpchunk'
                        else
                          3
                  else
                    n.push y
                childNodes = n
              childNodesLength = childNodes.length
              spaced = 0
              while i < childNodesLength
                x = childNodes[i]
                i++
                isLast = (i is childNodesLength)
                { nodeType } = x
                if nodeType is 3
                  { textContent } = x
                  if textContent?
                    if autoSpacing() is textContent
                      spaced = 1
                    else if (r = /^((\n[^\n\S]*)*)\n[\t ]*$/.exec textContent)?
                      if r[1].length
                        post = if r[1] is "\n"
                          "()"
                        else
                          " #{quot entQuot(r[1]) }"
                        @p "@_n#{post}"
                      spaced = 1
                    else if /^[ \t\r\n]*$/.test textContent
                      @p "@_ #{rQuot textContent, indentation}" # , #{wQuot autoSpacing()}"
                      spaced = 1
                    else if textContent.length
                      @p "@_ #{rQuot entQuot(textContent), indentation}" # , #{wQuot autoSpacing()}"
                      spaced = 1
                  else
                    throw "Text node without textContent property!"
                else if nodeType is 1 or nodeType is 'phpchunk'
                  pre = if spaced
                    if isLast
                      "@Z()."
                    else
                      "@"
                  else
                    if isLast
                      "@S()."
                    else
                      "@_()."
                  if nodeType is 'phpchunk'
                    dressed = php.dress(x.textContent)
                    if (match = /^<[?]php if [(](.*)[)] *: [?]>$/.exec dressed)
                      @p "#{pre}phpIf #{rQuot "#{match[1]}", indentation}"
                    else if (match = /^<[?]php foreach [(](.*)[)] *: [?]>$/.exec dressed)
                      @p "#{pre}phpForeach #{rQuot "#{match[1]}", indentation}"
                    else if (match = /^<[?]php elseif [(](.*)[)] *: [?]>$/.exec dressed)
                      @p "#{pre}phpElseif #{rQuot "#{match[1]}", indentation}"
                    else if (match = /^<[?]php else *: [?]>$/.exec dressed)
                      @p "#{pre}phpElse()"
                    else if dressed is '<?php endif; ?>'
                      @p "#{pre}phpEndif()"
                    else if dressed is '<?php endforeach; ?>'
                      @p "#{pre}phpEndforeach()"
                    else
                      @p "#{pre}phpChunk '#{php.id2key x.textContent}', #{rQuot dressed, indentation}"
                    spaced = 0
                    continue
                  { tagName } = x
                  tagName = tagName.toLowerCase()
                  a = attributes(x)
                  textContent = null
                  isRaw = (tagName is "script" or tagName is "style")
                  if (c = x.childNodes)? and c.length is 1 and (isRaw or (c[0].nodeType is 3 and (textContent = c[0].textContent)? and (/[^ \t\r\n]/.test(textContent)) and (!includeChunks or !php.hasAnyChunk textContent)))
                    content = c[0].textContent
                    if isRaw
                      content = rQuot content, indentation
                    else
                      content = entQuot content
                      content = quot content
                    @p "#{pre}#{tagName} #{a}-> \@_ #{content}"
                  else if (c = x.childNodes)? and c.length is 0
                    if a is ""
                      a = "()"
                    else
                      a = ' ' + a.replace(/, *$/, "")
                    @p "#{pre}#{tagName}#{a}"
                  else
                    pt "#{pre}#{tagName} #{a}->", x
                  spaced = 0
                else if nodeType is 10
                  # { tagName } = x
                  # tagName ?= 'html'
                  # a = attributes(x)
                  # pt "@#{tagName.toLowerCase()} #{a}->", x
                  @p "@docType #{quot (x.name ? "html") }"
                else if nodeType is 8
                  # throw "here #{x.name}"
                  # warn(JSON.stringify(x))
                  # { textContent 
                  # split(/\r?\n/)
                  # @p "@_ #{quot  "<!--#{x.data}-->" }"
                  @p "@commentTag #{quot x.data}"
                else
                  throw "# Strange node type encountered: #{nodeType}"

          php?.apply ->
            coffeePrinter.p "phpChunks ="
            for h, x of @chunks
              x = if refcoffee
                x = "''''\n" + x
                x = x.replace(/(\n|^)/g, "\n      ")
              else
                " #{quot x}"
              coffeePrinter.p "    '#{h}':#{x}"
            coffeePrinter.p (if refcoffee then ";\n" else "")

          variant = ""
          php?.apply -> variant = ".withPhpChunks(phpChunks)"

          { document } = browser

          @zombie? and inBody?.apply ->
            document = document.body
              
          printTree 0, "#{htmlcupCode}#{variant}.modApply ->", document
            # @p "@docType #{quot doctype.name}"
            # printTree "do =>", browser.document
            # @p "@html ->", ->
            #   printTree "@head ->", head
            #   printTree "@body ->", body
        
      finally
        browser.close()

      readyy?()
