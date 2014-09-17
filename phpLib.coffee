module.exports =
  magic: 'PHP'
  chunks: { }
  hash: do (md5 = require('MD5')) -> (x)-> md5(x).substr(0,8)
  strip: (x)-> x.replace /<[?]([^?]+|[?]+[^?>])*[?]>/g, (x)=> h = @hash(x); @chunks[h] = x; @magic + h
  apply: (x)-> x.apply @
  dress: (x)-> x.replace /PHP[0-9a-z]{8}/g, (x)=> @chunks[x.substring(3,11)] ? "FAIL#{x}"
  memberp: (x)-> @chunks[x]?
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
    for y in x.split /(PHP[0-9a-z]{8})/
      if @memberp(y)
        return true
    return false
