{ htmlcup } = require 'htmlcup'
  
rootLayout = ({ head, header, body, footer, tail, minheight, minwidth })->
      # This seems rather complex, but it appears to be the simplest effective way to get what I want, flex isn't working as expected
      @printHtml "<!DOCTYPE html>\n"
      @html lang:"en", manifest:"coffeeconsole.appcache", style:"height:100%", ->
        head.call @
        @body style:"height:100%;margin:0;overflow:auto", ->
            @div id:"console", tabindex:"0", style:"height:100%;display:table;width:100%;max-width:100%", ->
                if false
                  header.call @, style:"display:table-row;min-height:1em;overflow:auto;max-height:5em", class:"consoleHeader"
                else if false
                  @div style:"display:table-row;min-height:1em;background:pink", ->
                    @div style:"max-height:5em;overflow-y:scroll;overflow-x:hidden;position:relative;display:block", ->
                      @div style:"float:left;width:100%", contentEditable:"true", ->
                        @div "x" for x in [ 0 .. 25 ]
                else
                  @div style:"display:table-row;min-height:1em", ->
                    @div style:"max-height:5em;overflow:hidden;position:relative;display:block", ->
                      @div style:"float:left;width:100%", ->
                        header.call @, class:"consoleHeader"
                @div style:"position:relative;height:100%;overflow:hidden;display:table-row", ->
                  @div style:"position:relative;width:100%;height:100%;min-height:#{minheight}", ->
                    @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:auto", ->
                      # x (container width)  y (contained width)
                      
                      # 2000 px              2000 px
                      # 1500 px              1500 px
                      # 1000 px              1000 px
                      # 800 px               1000 px
                      # 500 px               1000 px
                      # 300 px               600 px
                      # 200 px               400 px
                      # 150 px               300 px
                      # 100 px               200 px
                      
                      # y = ((x * 2) ^ 1000 px) _ x
                      #      min-width width     max-width
                      @div style:"width:200%;max-width:50em;min-width:100%;height:100%;overflow:hidden", ->
                        @div style:"position:relative;width:100%;height:100%;display:table", ->
                        # @div style:"position:relative;width:100%;max-width:100%;height:100%;overflow:auto", ->
                        #  @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:auto", ->
                        #    @div style:"position:relative;max-width:200%;min-width:60em;display:table;background:black", ->
                          body.call @
                footer.call @, id:"footer", style:"display:table-row"
            tail.call @

rootLayout.call htmlcup,
  minheight: "20em",
  minwidth: "60em",
  head: ->
    @meta charset:"utf-8"
    @title "html2cup - Convert HTML to CoffeeScript and back!"
    @meta id:"meta", name:"viewport", content:"width=device-width, user-scalable=no, initial-scale=1"
    @style """
      body { background:black; color: #ddd; }
      a { color:#5af; }
      a:visited { color:#49f; }
      a:hover { color:#6cf; }
      select, textarea { border: 1px solid #555; }
      """
  header: (opts)->
    @style """
        div.thisHeader, .thisHeader div { text-align:center; }
        """
    @div opts, ->
      @style """
        select { min-width:5em; max-width:30%; width:18em; }
        select, button { font-size:inherit; text-align:center;   }
        .button { display:inline-block; }
        button, .button, input, select:not(:focus):not(:hover) { color:white; background:black; }
        /* select option:not(:checked) { color:red !important; background:black !important; } */
        /* option:active, option[selected], option:checked, option:hover, option:focus { background:#248 !important; } */
        button, .button { min-width:5%; font-size:150%; border: 2px outset grey; }
        button:active, .button.button-on { border: 2px inset grey; background:#248; }
        .button input[type="checkbox"] { display:none; }
        .arrow { font-weight:bold;  }
        .editArea { height:100%;width:100%;box-sizing:border-box; }
        """
      @div class:"thisHeader", ->
        @select disabled:"1", ->
          @option "HTML"
          @option "PHP"
        @button id:"fromButton", class:"arrow", "«"
        @label id:"autoButton", class:"button button-on", ->
          @input type:"checkbox", checked:"1", onchange:'this.parentNode.setAttribute("class", "button button-" + (this.checked ? "on" : "off"))'
          @span id:"autoButtonText", "Auto"
        @button id:"toButton", class:"arrow", "»"
        @select disabled:"1", ->
          @option "CoffeeScript (htmlcup)"
          @option "Reflective CoffeeScript (htmlcup)"
  body: (opts)->
      @style """
        textarea { background: black; color: #ddd; }
        """
      @div style:"position:relative;display:table-cell;width:50%", ->
        # @span "&nbsp;"
        @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:hidden", ->
          @textarea id:"htmlArea", class:"editArea", ""
      @div style:"position:relative;display:table-cell;width:50%", ->
        # @span "&nbsp;"
        @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:hidden", ->
          @textarea id:"htmlcupArea", class:"editArea", ""
  footer: (opts)->
    @style """
        div.thisFooter, .thisFooter div { text-align:center; }
        """
    @div class:"thisFooter", opts, ->
      @b -> @a href:"https://github.com/rev22/html2cup", "html2cup"
      @span ->
        @span ": "
        @i "Convert HTML to Coffeescript and back!"
      @printHtml " &bull; "
      @a href:"https://github.com/rev22/htmlcup", "htmlcup"
      @printHtml " &bull; "
      @a href:"https://github.com/jashkenas/coffeescript", "Coffeescript"
      @printHtml " &bull; "
      @a href:"https://github.com/rev22/reflective-coffeescript", "Reflective Coffeescript"
  tail: ->
    @script src:"https://github.com/ajaxorg/ace-builds/raw/master/src-min-noconflict/ace.js", type:"text/javascript", charset:"utf-8"
    @script src:"pack.js?xxx"
    @coffeeScript ->
      inject = (options, callback) ->
        baseUrl = options.baseUrl or "../../src-noconflict"
        load = (path, callback) ->
          head = document.getElementsByTagName("head")[0]
          s = document.createElement("script")
          s.src = baseUrl + "/" + path
          head.appendChild s
          s.onload = s.onreadystatechange = (_, isAbort) ->
            if isAbort or not s.readyState or s.readyState is "loaded" or s.readyState is "complete"
              s = s.onload = s.onreadystatechange = null
              callback()  unless isAbort
            return

          return

        if true
          
          # load("ace.js", function() {
          ace.config.loadModule "ace/ext/textarea", ->
            if false
              event = ace.require("ace/lib/event")
              areas = document.getElementsByTagName("textarea")
              i = 0

              while i < areas.length
                event.addListener areas[i], "click", (e) ->
                  ace.transformTextarea e.target, options.ace  if e.detail is 3
                  return

                i++
            callback and callback()
            return

        return

      # });

      # Call the inject function to load the ace files.
      inject {}, ->
        
        # Transform the textarea on the page into an ace editor.
        for a in (x for x in document.getElementsByClassName("editArea")).reverse()
          do (a, e = ace.require("ace/ext/textarea").transformTextarea(a))->
            e = ace.require("ace/ext/textarea").transformTextarea(a)
            a.setupTransform(e)
            a.onchange = ->
              # alert "a onchange " + x
              e.setValue @value, -1
              return

            e.on "change", ->
              # alert "e change " + x
              a.value = e.getValue()
              a.oninput?()
              return

            e.on "blur", ->
              # alert "e blur " + x
              a.value = e.getValue()
              a.onblur?()
              return

            e.on "focus", ->
              a.onfocus?()
              return
        return
