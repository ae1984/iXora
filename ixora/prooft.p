/* prooft.p
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
        26/11/03 nataly добавлена обработка subledger SCU
        18/04/06 nataly добавлена обработка subledger TSF
*/

{mainhead.i TPRF1}  /* PROOF SHEET */

def temp-table wt
    field gl like gl.gl
    field sub like trxbal.sub
    field lev as int format ">>9" column-label "LEV"
    field crc like crc.crc
    field amt like glbal.bal column-label "SUBLEDGER"
    field bal like glbal.bal
    index gl gl
    index crc crc.

def stream s-err.
output stream s-err to value("prooft" + string(day(g-today),"99") + ".err").
def var i as int.
def var v-gl like gl.gl.
def var v-crc like crc.crc.
{image1.i rpt.img}
{image2.i}


for each trxbal no-lock: 
if trxbal.dam eq trxbal.cam then next.
if trxbal.sub eq "CIF" then do:
find aaa where aaa.aaa eq trxbal.acc no-lock no-error.
if available aaa then do:
if trxbal.level ge 1 and trxbal.level le 5 then do:
if trxbal.dam ne aaa.dr[trxbal.level] 
then put stream s-err aaa.aaa 
" trxbal.dam ne aaa.dr[" trxbal.level format "9" "] " trxbal.dam
aaa.dr[trxbal.level] skip.
if trxbal.cam ne aaa.cr[trxbal.level]
then put stream s-err aaa.aaa
" trxbal.cam ne aaa.cr[" trxbal.level format "9" "] " trxbal.cam
aaa.cr[trxbal.level] skip.
end.


v-gl = aaa.gl.
find trxlevgl where trxlevgl.gl eq aaa.gl and trxlevgl.subled eq "CIF"
and trxlevgl.level eq trxbal.level no-lock no-error.
end.
else put stream s-err "Not found CIF " aaa.aaa skip.
end.
else 
if trxbal.sub eq "LON" then do:
{prooft.i "LON"}
end.
else 
if trxbal.sub eq "arp" then do:
{prooft.i "arp"}
end.
else
if trxbal.sub eq "ast" then do:
{prooft.i "ast"}
end.
else
if trxbal.sub eq "ock" then do:
{prooft.i "ock"}
end.
else
if trxbal.sub eq "dfb" then do:
{prooft.i "dfb"}
end.
else
if trxbal.sub eq "fun" then do:
{prooft.i "fun"}
end.
if trxbal.sub eq "scu" then do:
{prooft.i "scu"}
end.
if trxbal.sub eq "tsf" then do:
{prooft.i "tsf"}
end.
else
if trxbal.sub eq "eps" then do:
{prooft.i "eps"}
end.


if trxbal.lev ne 1 then
if available trxlevgl then v-gl = trxlevgl.glr.
if available trxlevgl or trxbal.lev eq 1 then do:
find wt where wt.gl eq v-gl and wt.crc eq trxbal.crc no-error.
if not available wt then do :
create wt.
wt.gl = v-gl. 
wt.crc = trxbal.crc.
wt.lev = trxbal.level.
wt.sub = trxbal.sub.
end.
wt.amt = wt.amt + (trxbal.dam - trxbal.cam).
end.
/*
else displ trxbal.
*/
i = i + 1.

end.


/*
for each jl where jl.jdt eq g-today no-lock :
find wt where wt.gl eq jl.gl and wt.crc eq jl.crc no-error.
if available wt then do:
    if jl.dc eq "D" then 
    wt.bal = wt.bal + jl.dam.
    else 
    wt.bal = wt.bal - jl.cam.
end.
end.
*/

for each wt :
    find gl where gl.gl eq wt.gl no-lock no-error.
    if available gl then 
    if gl.type eq "L" or gl.type eq "O" or gl.type eq "R"
    then do:
        wt.amt = - wt.amt.
        wt.bal = - wt.bal.
    end.    
end.

for each glbal no-lock :
 find gl where gl.gl eq glbal.gl no-lock no-error.
 if available gl then do:
  if gl.subled ne "" then do:
   find wt where wt.gl eq gl.gl and wt.crc eq glbal.crc no-error.
   if not available wt then do :
    create wt.
    wt.gl = gl.gl.
    wt.crc = glbal.crc.
   end.
   wt.bal = wt.bal + glbal.bal.
  end.
  else do:
   find wt where wt.gl eq gl.gl and wt.crc eq glbal.crc no-error.
   if available wt then wt.bal = wt.bal + glbal.bal.
  end.
 end.
end.

for each aaa no-lock :
 do i = 1 to 5 :
  if aaa.dr[i] ne aaa.cr[i] then do:
  v-crc = aaa.crc.
   if i gt 1 then do:
   find trxlevgl where trxlevgl.gl eq aaa.gl and trxlevgl.lev eq i no-lock
   no-error.
   if available trxlevgl then do :
    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
    if available gl then do:
        if gl.type eq "E" or gl.type eq "R" then v-crc = 1.
    end.
    else put stream s-err unformatted
       "Not found gl for " "aaa " aaa.aaa " GL# " aaa.gl
       " level " i format ">9" " amount "
       aaa.dr[i] - aaa.cr[i] format ">>>,>>>,>>>,>>9.99-" skip.
   end.
   else put stream s-err unformatted
   "Not found trxlevgl for " "aaa " aaa.aaa " GL# " aaa.gl 
   " level " i format ">9" " amount "
   aaa.dr[i] - aaa.cr[i] format ">>>,>>>,>>>,>>9.99-" skip.
   end. 
   
   
   find trxbal where trxbal.sub eq "CIF" and trxbal.acc eq aaa.aaa and
   trxbal.crc eq v-crc and trxbal.lev eq i no-lock no-error.
   if not available trxbal then 
   put stream s-err unformatted 
   "Not found trxbal for " "CIF " aaa.aaa " level " i format ">9" " amount "
   aaa.cr[1] - aaa.dr[1] format ">>>,>>>,>>>,>>9.99-" skip.
  end.
 end.
end.
{prooft1.i "LON"}
{prooft1.i "AST"}
{prooft1.i "ARP"}
{prooft1.i "DFB"}
{prooft1.i "FUN"}
{prooft1.i "SCU"}
{prooft1.i "TSF"}
{prooft1.i "OCK"}
{prooft1.i "EPS"}
 
output stream s-err close.
pause 0.
{report1.i 59}
pause 0.
{report2.i 132}
pause 0.
find sysc "GLDATE" no-lock.
vtitle = "Проверочный отчет(proof sheet) за " + string(sysc.daval,"99/99/9999").

for each wt no-lock break by wt.crc by wt.gl :
if wt.bal eq wt.amt and wt.bal eq 0 then next.
find gl where gl.gl eq wt.gl no-lock no-error.
find crc where crc.crc eq wt.crc no-lock no-error.
find glbal where glbal.gl eq wt.gl and glbal.crc eq wt.crc no-lock no-error.
displ 
wt.gl column-label "Счет ГК"  
gl.subled  column-label "Тип"
wt.lev column-label "Уровень"
crc.code column-label "Вал"
gl.des column-label "Наименование"
wt.amt column-label "Подсчета"
wt.bal column-label "Баланс"
(wt.bal ne wt.amt) or wt.sub ne gl.subled  format  "***/   " 
column-label "ТСТ" with width 133.
pause 0.
end.

{report3.i}
pause 0.
unix silent /bin/cat 
value("prooft" + string(day(g-today),"99") + ".err") >> rpt.img .
pause 0.
{image3.i}


