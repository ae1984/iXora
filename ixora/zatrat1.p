/* zatrat1.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        zatratdat.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-14-3
 * AUTHOR
        06/06/05 nataly
 * CHANGES
*/

def shared var m1 as integer format 'z9'.
def shared var m2 as integer format 'z9'.
def shared var y1 as integer format '9999'.
def shared  var v-attn as char.
define shared var g-today  as date.

def var v-day as integer.
def var j as integer.
def var dt as date .
def var v-rate as decimal.

def var v-dep as char.
def var v-gl as char.

def temp-table t-gl2
      field gl like txb.gl.gl.

def shared temp-table bastjl
      field gl like txb.jl.gl
      field gl1 like txb.jl.gl
      field jdt like txb.jl.jdt
      field ast like txb.jl.acc
      field dam like txb.jl.dam
      field cam like txb.jl.cam
      field dep as char
      field jh like txb.jl.jh .

find txb.sysc where sysc.sysc = 'k-gl' no-lock no-error.
if avail txb.sysc then v-gl = sysc.chval.

for each txb.trxlevgl no-lock  where lookup(substr(string(trxlevgl.gl),1,4),v-gl) <> 0  and
lev = 3.
   find t-gl2 where t-gl2.gl = trxlevgl.glr no-lock no-error.
if not avail t-gl2 then do:
    create t-gl2. 
    t-gl2.gl = trxlevgl.glr.
 end. 
end.

run   mondays(m2,y1,output v-day)  .
do dt = date(m1,01,y1) to date(m2,v-day,y1):

 for each t-gl2 no-lock .
  for each txb.jl  no-lock where jdt = dt and txb.jl.gl = t-gl2.gl use-index jdt.

   find last txb.crchis where crchis.crc = jl.crc 
       and crchis.rdt <= dt   use-index crcrdt no-lock no-error.
   if not available txb.crchis then do:  
     message 'Не задан курс для валюты ' jl.crc .
     v-rate =  1. 
   end.

  find last txb.hist where hist.pkey = "AST" and hist.skey = jl.acc and 
                       hist.date <= jl.jdt no-lock no-error.
  if not avail txb.hist then do:
     if date(m1,01,y1) < g-today then do:
        find first txb.hist where hist.pkey = "AST" and hist.skey = jl.acc and
                              hist.date >= jl.jdt no-lock no-error.
     end.
  end.
  if not avail txb.hist then find first txb.ast where ast.ast = jl.acc no-lock no-error.

   if avail txb.hist then  do: 
    if hist.date <= jl.jdt then  v-dep = hist.chval[1].
     else hist.chval[2].
  end.
  else  v-dep = ast.attn . 
/*  if v-dep <> v-attn then next.*/
     create bastjl.
     assign bastjl.gl = jl.gl
            bastjl.jh = jl.jh 
            bastjl.dam = jl.dam
            bastjl.cam = jl.cam
            bastjl.ast = jl.acc
            bastjl.dep = v-dep
            bastjl.jdt = jl.jdt.
    find  first txb.trxlevgl where trxlevgl.glr = jl.gl no-lock no-error.
    if avail txb.trxlevgl then bastjl.gl1 = trxlevgl.gl. else bastjl.gl1 = 0.
  end. /*jl*/
 end. /*astjl*/
end.  /*dt*/

