// Generated by CoffeeScript 1.4.0
(function() {
  var htmlcup,
    __slice = [].slice;

  htmlcup = require('htmlcup').htmlcup;

  htmlcup = htmlcup.extendObject({
    withPhpChunks: function(chunks) {
      var lib, orig, phpLib;
      if (chunks == null) {
        chunks = {};
      }
      orig = this;
      phpLib = require('./phpLib');
      phpLib.chunks = chunks;
      lib = orig.extendObject({
        phpLib: phpLib,
        origLib: orig,
        printHtml: function(x) {
          return this.origLib.printHtml(this.phpLib.dress(x));
        },
        quoteText: function(x) {
          return this.phpLib.dress(this.origLib.quoteText(x));
        },
        phpChunk: function(k, chunk) {
          if (!this.noAutoSpaceBefore) {
            this.autoSpace();
          }
          if (chunk == null) {
            chunk = this.phpLib.chunks[k];
            if (chunk == null) {
              throw "Could not find chuck with key " + k;
            }
          }
          this.origLib.printHtml(chunk);
          this.nesting.spaced = this.noAutoSpace || this.noAutoSpaceAfter ? 1 : 0;
          return this;
        },
        phpIf0: function() {
          return this.phpIf("0");
        },
        phpIf: function(x) {
          return this.phpChunk(null, "<?php if (" + x + "): ?>");
        },
        phpForeach: function(x) {
          return this.phpChunk(null, "<?php foreach (" + x + "): ?>");
        },
        phpElseif: function(x) {
          return this.phpChunk(null, "<?php elseif (" + x + "): ?>");
        },
        phpElse: function() {
          return this.phpChunk(null, "<?php else: ?>");
        },
        phpEndif: function() {
          return this.phpChunk(null, "<?php endif; ?>");
        },
        phpEndforeach: function() {
          return this.phpChunk(null, "<?php endforeach; ?>");
        },
        php: function(x) {
          return this.phpLib.strip(x);
        }
      });
      return lib.compileLib();
    },
    _: function(x) {
      this.nesting.spaced = 1;
      if (x != null) {
        this.printHtml(x);
      }
      return this;
    },
    self: function(x) {
      var _ref;
      return (_ref = this[x + 'Self']) != null ? _ref : this;
    },
    S: function() {
      var x;
      x = {
        autoSpaceSelf: this.self('autoSpace'),
        noAutoSpace: true,
        modApplyTag: function(tag, f) {
          this.self('autoSpace').modApplyTag(tag, f);
          return this;
        }
      };
      x.__proto__ = this.self('autoSpace');
      return x;
    },
    SS: function() {
      return this.Z.apply(this, arguments);
    },
    Z: function() {
      var x;
      x = {
        autoSpaceSelf: this.self('autoSpace'),
        noAutoSpaceAfter: true,
        modApplyTag: function(tag, f) {
          this.self('autoSpace').modApplyTag(tag, f);
          return this;
        }
      };
      x.__proto__ = this.self('autoSpace');
      return x;
    },
    _n: function(x) {
      if (x == null) {
        x = "\n";
      }
      this.printHtml(x);
      return this;
    },
    modApply: function(f) {
      f.apply(this);
      return this;
    },
    modApplyTag: function(tag, f) {
      var oldNesting;
      oldNesting = this.nesting;
      try {
        this.nesting = {
          level: oldNesting.level + 1,
          tag: tag,
          parent: oldNesting,
          spaced: oldNesting.spaced
        };
        this.modApply(f);
      } finally {
        oldNesting.spaced = this.nesting.spaced;
        this.nesting = oldNesting;
      }
      return this;
    },
    nesting: {
      level: 0
    },
    autoSpace: function(justTest) {
      var spacing;
      if (this.noAutoSpace) {
        return;
      }
      if (this.nesting.spaced) {
        return;
      }
      spacing = "\n" + Array(this.nesting.level + 1).join("    ");
      if (justTest) {
        return spacing;
      }
      return this._(spacing);
    },
    commentTag: function(x) {
      if (!this.noAutoSpaceBefore) {
        this.autoSpace();
      }
      this.printHtml("<!--" + x + "-->");
      this.nesting.spaced = this.noAutoSpace || this.noAutoSpaceAfter ? 1 : 0;
      return this;
    },
    compileTag: function(tagName, isVoid, isRawText) {
      var tag;
      tag = {
        tagName: tagName,
        isVoid: isVoid,
        isRawText: isRawText
      };
      return function() {
        var arg, args, f, s, x, y, _i, _len;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (!this.noAutoSpaceBefore) {
          this.autoSpace();
        }
        this.printHtml("<" + tagName);
        for (_i = 0, _len = args.length; _i < _len; _i++) {
          arg = args[_i];
          if (typeof arg === 'function') {
            f = arg;
            break;
          }
          if (typeof arg === 'string') {
            s = arg;
            break;
          }
          for (x in arg) {
            y = arg[x];
            if ((y != null) && y !== "") {
              this.printHtml(" " + x + "=\"" + (this.quoteText(y)) + "\"");
            } else {
              this.printHtml(" " + x);
            }
          }
        }
        this.printHtml('>');
        if (isVoid) {
          this.nesting.spaced = this.noAutoSpace || this.noAutoSpaceAfter ? 1 : 0;
          return;
        } else {
          this.nesting.spaced = 0;
        }
        if (f) {
          this.modApplyTag(tag, f);
        } else if (s != null) {
          if (isRawText) {
            this._(s);
          } else {
            this._(this.quoteTagText(s));
          }
        } else {
          this.nesting.spaced = 1;
        }
        this.autoSpace();
        this.printHtml('</' + tagName + '>');
        this.nesting.spaced = this.noAutoSpace || this.noAutoSpaceAfter ? 1 : 0;
        return this;
      };
    }
  });

  htmlcup = htmlcup.compileLib();

  module.exports = htmlcup;

}).call(this);
