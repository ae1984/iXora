function AllSpaceDelete returns char( p_str as char).
def var v-spstr as char.
v-spstr = p_str.

do while index(v-spstr," ") >0 :
   v-spstr = replace (v-spstr," ","").
end.
return v-spstr.
end function.

function SpaceDelete returns char( p_str as char).
def var v-spstr as char.
v-spstr = p_str.

do while index(v-spstr,"  ") >0 :
   v-spstr = replace (v-spstr,"  "," ").
end.
return v-spstr.
end function.

function sw-to-prog-amt returns decimal( p_amt as char).
def var v-amtstr as char.
def var v-amtdec as decimal.

v-amtstr = p_amt.
v-amtstr = replace (v-amtstr,",",".").

if substr(v-amtstr, length(v-amtstr)) = "." then do: 
  v-amtstr  = v-amtstr + "00".
end.

v-amtdec = decimal (v-amtstr).
return v-amtdec.
end function.

function str-to-time returns integer(v-stime as char).
def var v-time as integer.

def var v-hh as integer.
def var v-mm as integer.
def var v-ss as integer.

v-hh = integer(entry(1, v-stime,":")).
v-mm = integer(entry(2, v-stime,":")).
v-ss = integer(entry(3, v-stime,":")).

v-time = v-hh * 3600 + v-mm * 60 + v-ss.

return v-time.
end function.