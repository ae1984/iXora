
for each {1} no-lock :
 do i = 1 to 5 :
  if {1}.dam[i] ne {1}.cam[i] then do:
   v-crc = {1}.crc.
   if i gt 1 then do:
   find trxlevgl where trxlevgl.gl eq {1}.gl and trxlevgl.lev eq i no-lock
   no-error.
   if available trxlevgl then do :
    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
    if available gl then do:
        if gl.type eq "E" or gl.type eq "R" then v-crc = 1.
    end.
    else put stream s-err unformatted
       "Not found gl for " "{1} " {1}.{1} " GL# " {1}.gl
       " level " i format ">9" " amount "
       {1}.dam[i] - {1}.cam[i] format ">>>,>>>,>>>,>>9.99-" skip.
   end.
   else put stream s-err unformatted
   "Not found trxlevgl for " "{1} " {1}.{1} " GL# " {1}.gl 
   " level " i format ">9" " amount "
   {1}.dam[i] - {1}.cam[i] format ">>>,>>>,>>>,>>9.99-" skip.
   end.
   find trxbal where trxbal.sub eq "{1}" and trxbal.acc eq {1}.{1} and
   trxbal.crc eq v-crc and trxbal.lev eq i no-lock no-error.
   if not available trxbal then
   put stream s-err unformatted
   "Not found trxbal for " "{1} " {1}.{1} " level " i format ">9" " amount "
   {1}.dam[i] - {1}.cam[i] format ">>>,>>>,>>>,>>9.99-" skip.
  end.
 end.
end.
