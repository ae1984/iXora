/*

  01.08.2003 nadejda - ®ЇБЁ¬Ё§ ФЁО ФЁЄ«®ў 
*/

{global.i}
def var v-point like poin.point.
def var v-dep like ppoint.depart.

def temp-table gll 
  field gllist like gl.gl
  index gllist is primary unique gllist.

def var i as int.
def var tt as cha.
def var v-gll as char format "x(10)".
def var v-name like gl.des init "".
def var vgl like pglbal.gl.
def var v-sysc like sysc.chval.
def var inc as integer.
def var pr as int.
def buffer t-pglbal for pglbal.

find sysc where sysc.sysc = "GLPNT" no-lock no-error.
do i = 1 to num-entries(sysc.chval).
  tt = trim (entry (i, sysc.chval)).
  if tt = "" then next.

  inc = integer (tt) no-error.
  if not error-status:error and not can-find (gll where gll.gllist = inc) then do:
    create gll.
    gll.gllist = inc.
  end.
end.

/* 01.08.2003 nadejda 
repeat :
 create gll .
 gll.gllist = substr(tt,1,index(tt,",") - 1 ).
 tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
 if tt = "" or tt = " " then leave .
end.
*/

for each gll :
 for each ppoint :
  for each crc where sts ne 9 no-lock :
    find pglbal where pglbal.point = ppoint.point and
          pglbal.depart = ppoint.depart and pglbal.gl = gll.gllist
          and pglbal.crc = crc.crc no-lock no-error.
    if not available pglbal then do  :
      create pglbal.
      assign pglbal.point = ppoint.point
             pglbal.depart = ppoint.depart
             pglbal.gl = gll.gllist
             pglbal.crc = crc.crc
             pglbal.dam = 0
             pglbal.cam = 0
             pglbal.mdam = 0
             pglbal.mcam = 0
             pglbal.ydam = 0
             pglbal.ycam = 0
             pglbal.bal = 0.
     end.
  end.
end.
end.

for each jl where jl.jdt = g-today no-lock use-index jdt :

/*
    find ofc where ofc.ofc = jl.who no-lock no-error.
    if available ofc then do :
       v-point =  ofc.regno / 1000 - 0.5 .
       v-dep = ofc.regno - v-point * 1000.
    end.
*/

    v-point = jl.point.
    v-dep = jl.depart.

    find pglbal where pglbal.point = v-point and pglbal.depart = v-dep and
         pglbal.gl = jl.gl and pglbal.crc = jl.crc no-error.
    if available pglbal and ( jl.dam <> 0 or jl.cam <> 0 ) then do :
       pglbal.dam = pglbal.dam + jl.dam.
       pglbal.cam = pglbal.cam + jl.cam.
    end.
end.


for each pglbal :
   find first gl where gl.gl = pglbal.gl no-lock no-error.
   if available gl then pglbal.bal = pglbal.dam - pglbal.cam .
   else  do:
     message 'Nepareizi ievads GALV.GR konta numurs -> faila SYSC = GLPNT'.
     pause.
   end.
   if gl.type eq "L" or gl.type eq "O" or gl.type eq "R" then pglbal.bal = - pglbal.bal.
end.

repeat inc = 1 to 9:
  for each gl where gl.totlev = inc /*and gl.totgl ne 0*/:
    if gl.totgl ne 0 then do:
      pr = 0.
      find first gll where gll.gllist = gl.gl no-error.
      if not available gll then pr = 1.
      find first gll where gll.gllist = gl.totgl no-error.
      if not available gll then pr = 1.
      if pr = 0 then do :

        for each ppoint :
         for each crc where crc.sts <> 9 :
          find pglbal where pglbal.point = ppoint.point and pglbal.dep =
               ppoint.dep and pglbal.gl = gl.gl and pglbal.crc = crc.crc.
            find t-pglbal where t-pglbal.point = ppoint.point and t-pglbal.dep =
            ppoint.dep and t-pglbal.gl eq gl.totgl and t-pglbal.crc eq crc.crc.
            t-pglbal.bal = t-pglbal.bal + pglbal.bal.
         end.
        end.

      end.
    end.
  end.
end.

for each pglbal:
  find last pglday where pglday.point = pglbal.point and
       pglday.depart = pglbal.depart and pglday.gl  = pglbal.gl and
       pglday.crc = pglbal.crc no-error.
  if not available pglday or
   ( available pglday and pglday.dam <> pglbal.dam or pglday.cam <> pglbal.cam
   or pglday.bal <> pglbal.bal ) then do :
       create pglday.
       assign pglday.point = pglbal.point
              pglday.depart = pglbal.depart
              pglday.gl  = pglbal.gl
              pglday.crc = pglbal.crc
              pglday.gdt = g-today
              pglday.dam = pglbal.dam
              pglday.cam = pglbal.cam
              pglday.bal = pglbal.bal.
  end.
end.

/*
  display " FINISH " string (time, "hh:mm:ss") with frame a5.
*/
