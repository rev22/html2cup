module.exports =
  magic: 'PHP'
  chunks: { }
  hash: do (md5 = require('MD5')) -> (x)-> md5(x).substr(0,8)
  strip: (x)->
    if false
      x.replace /<[?]([^?]+|[?]+[^?>])*[?]>/g, (x)=> h = @hash(x); @chunks[h] = x; @magic + h
    else
      chunks = x.split /(<[?]|[?]>)/
      stripped = []
      php = []
      in_php = 0
      php_introns = 0
      for c in chunks
        if c is "<?"
          php_introns++
          in_php++
        if in_php > 0
          php.push c
        else if in_php is 0
          stripped.push c
        else
          throw "A PHP terminator code was found in excess"
        if c is "?>"
          in_php--
          if in_php is 0
            x = php.join ''
            php = []
            h = @hash x
            @chunks[h] = x
            stripped.push @magic + h
      if in_php is 1 and php_introns is 1
        in_php = 0
        x = php.join ''
        php = []
        h = @hash x
        @chunks[h] = x
        stripped.push @magic + h
      if in_php isnt 0
       throw "PHP code was not terminated"        
      stripped.join ''
        
  apply: (x)-> x.apply @
  memberp: (x)-> @chunks[x]?
  dress: (x)->
    x = x.replace /php[0-9a-z]{8}=""/g, (x)=> @chunks[x.substring(3,11)] ? "FAIL#{x}"
    x = x.replace /PHP[0-9a-z]{8}/g, (x)=> @chunks[x.substring(3,11)] ? "FAIL#{x}"
    x
  idp: (x)-> /^PHP[0-9a-z]{8}/.test(x) and @memberp(x.substring(3,11))
  idp_strict: (x)-> /^PHP[0-9a-z]{8}$/.test(x) and @memberp(x.substring(3,11))
  id2key: (x)->
    if /PHP[0-9a-z]{8}/.test(x)
      x.substring(3,11)
  split: (x)->
    l = []
    p = ""
    for y in x.split /(PHP[0-9a-z]{8})/
      if @memberp(y)
        p = p + y
        throw p
      if p.length
        l.push p
      p = y
    if p.length
      l.push p
    l
  hasAnyChunk: (x)->
    for y in x.split /PHP([0-9a-z]{8})/
      if @memberp(y)
        return true
    return false
  idToChunk: (x)->
    if @idp_strict x
      if y = @id2key(x)
        @chunks[y]
