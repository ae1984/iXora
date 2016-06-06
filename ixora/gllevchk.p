/* gllevchk.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def buffer tx for  trxlevgl.
def buffer txl for trxlevgl.
def var v-fil as cha. 
def stream log. 
v-fil = "glleverr.log".
output stream log to value(v-fil).
Put stream log unformatted 
 " If there is only this record - it means Ok ." skip . 

for each gl where lev = 1 and sub ne "" and not totact  . 
 find first trxlevgl where trxlevgl.glr = gl.gl and trxlevgl.lev = 1 no-error . 

 if not avail trxlevgl then  
    do: 
     create trxlevgl . 
     trxlevgl.gl = gl.gl . 
     trxlevgl.sub  = gl.sub . 
     trxlevgl.glr = gl.gl. 
     trxlevgl.lev = 1 . 
    end. 
end. 
 

for each tx where tx.glr ne 0 break by tx.gl by tx.lev. 
/* display tx.  */ 
 find first gl where gl.gl = tx.glr no-lock no-error.
 if not avail  gl then do:  put stream log unformatted "Счет не найден " + string(tx.glr) skip. next. end.
/* if gl.sub = "" then do: delete tx. 
 next . end.  */
 if gl.sub ne tx.sub then 
    do:
      put stream log unformatted 
       " gl.sub ne trxlevgl.sub: " + string(tx.gl) + ":" + tx.sub + 
       " " + string(gl.gl) + ":" + gl.sub skip. 
    end.
 if gl.lev ne tx.lev then
    do:
      put stream log unformatted
       " gl.lev ne trxlevgl.lev: " + string(tx.gl) + ":" + string(tx.lev) +  
       " " + string(gl.gl) + ":" + string(gl.lev)   skip.
    end.
 if gl.totact then do:
     put stream log unformatted
     string(tx.gl) + ":" + " gl.gl " + string(gl.gl) + " - total gl " skip. 
 end.
  if last-of(tx.lev) then 
      put stream log unformatted skip . 
end.

output stream log close .
unix value("joe -rdonly " + v-fil) . 

