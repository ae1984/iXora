/* dfb_amtO.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

 {mainhead.i} 
def temp-table dfbamt field w-dfb like dfb.dfb field w-day as int
 field i-amt like  glbal.bal label "ВХОДЯЩИЕ"
 field o-amt like  glbal.bal label "ИСХОДЯЩИЕ"
 field o-sum like  glbal.bal label "СУММА"
 field w-crc like crc.crc .
def new shared var tout as int label " Время  ( сек ) " init 240 .
def buffer b-bank for bank.
def buffer wdfb for dfbamt.
def var wt-crc like crc.crc .
/* pause 0 */ .
def var i as int . 
def buffer t-rem for rem .
def var ym as int .
def var v-amt like glbal.bal.
def var vi-amt like glbal.bal.
define variable vtitle as char format "x(132)".
define variable vtoday as date.
define variable vtime  as cha format "x(8)".
def var x as int.
def var y as int.
def var h as int.
def var iss as int.
def var cur as int.
def var vvv as cha.
def var v-crc like crc.crc .
def temp-table v-dfb field dfb like dfb.dfb 
    field slc as cha format "x(1)" .
def var ourbank as cha. 
def var comprt as cha initial "joe  " format "x(10)" .


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  Message " Записи OURBNK нет в файле sysc !! ".
  pause . 
  return .
 end.
ourbank = sysc.chval.


x = 40 . y = 5 . h = 13 .
ym = 5 .

  update  comprt label  "Команда " skip
          with side-label row 5 centered frame dat .


repeat while v-crc eq 0 :
  
 update v-crc label "Валюта  " with column x + 2
  side-label overlay no-hide frame crc.
 wt-crc = v-crc .
end. 


for each v-dfb. delete v-dfb . end .
for each dfb where dfb.crc = v-crc .
 create v-dfb.
 v-dfb.dfb = dfb.dfb .
 v-dfb.slc = "*".
end.

form " " v-dfb.dfb v-dfb.slc 
 " " with column x row y h down overlay
 no-hide frame ddd .


for each dfbamt . delete dfbamt . end .
for each v-dfb where  v-dfb.slc = "*"  no-lock  :
  create dfbamt .
  w-dfb = v-dfb.dfb .
  w-crc = wt-crc .
  w-day = 0 .
  o-amt = 0 .
  i-amt = 0 .
end.
find first dfbamt no-error .
if not avail dfbamt then do : pause 0 . leave . end.
i = 0 .
 message " Ж Д И Т Е...  Р а с с ч е т......."  .
find first que use-index fprc no-lock no-error .
                            
if avail que and que.pid = "ARC" then do:
  find last que where que.pid = "ARC" use-index fprc no-lock no-error .
  find next que use-index fprc no-lock no-error .
end .

if avail que and que.pid = "D" then do:
  find last que where que.pid = "D" use-index fprc no-lock no-error .
  find next que use-index fprc no-lock no-error .
end .


if avail que then 
 repeat :
  find remtrz of que no-lock . 
  i = i + 1 . 
   if 
   ( remtrz.scbank ne ourbank or remtrz.outcode = 4 )
   and remtrz.scbank ne ? and remtrz.scbank ne "" 
   and remtrz.jh1 eq ? and remtrz.valdt1 ne ? and remtrz.fcrc = wt-crc
     then do:
      find first v-dfb where v-dfb.dfb = remtrz.dracc and v-dfb.slc = "*"
         no-error .
     if avail v-dfb then do:
      find first dfbamt where w-dfb = remtrz.dracc and w-day eq
      ( remtrz.valdt1 - g-today ) no-error .
       if not avail dfbamt then do:
        find dfb where dfb.dfb = remtrz.dracc no-lock .
        if not (( dfb.crc ne wt-crc ) and wt-crc ne 0 )
         then do:
           create dfbamt .
           w-dfb = remtrz.dracc .
           w-day = remtrz.valdt1 - g-today .
           dfbamt.w-crc = dfb.crc .
         end.
       end.
       if avail dfbamt then 
         dfbamt.i-amt = i-amt + remtrz.amt.
     end .
   end.
  
  if remtrz.rcbank ne ourbank and remtrz.rcbank ne ? and remtrz.rcbank ne "" 
   and  remtrz.jh2 eq ? and remtrz.tcrc = wt-crc 
     and  remtrz.valdt2  ne ? then 
   do:
      find jh where jh.jh eq remtrz.jh1 no-lock no-error.
      if avail jh then 
        find first rem where rem.rem = substr(jh.party,1,10) 
        no-lock no-error.
      if ( avail rem and rem.vjh eq ? ) or not avail rem then 
      do:
      find first v-dfb where v-dfb.dfb = remtrz.cracc and v-dfb.slc = "*"
         no-error .
     if avail v-dfb then do:
      find first dfbamt where w-dfb = remtrz.cracc and w-day eq
      ( remtrz.valdt2 - g-today ) no-error .
       if not avail dfbamt then do:
        find dfb where dfb.dfb = remtrz.cracc no-lock .
        if not (( dfb.crc ne wt-crc ) and wt-crc ne 0 )
         then do:
           create dfbamt .
           w-dfb = remtrz.cracc .
           w-day = remtrz.valdt2 - g-today .
           dfbamt.w-crc = dfb.crc .
         end.
       end.
       if avail dfbamt then 
         dfbamt.o-amt = o-amt + remtrz.payment.
     end .
   end.
  end .
                 
  find next que use-index fprc no-lock no-error .
  if not avail que then leave .

  if pid = "ARC" then do:
   find last que where que.pid = "ARC" use-index fprc no-lock no-error .
   find next que use-index fprc no-lock no-error .
  end . 
  if not avail que then leave .

  if pid = "D" then do:
     find last que where que.pid = "D" use-index fprc no-lock no-error .
     find next que use-index fprc no-lock no-error .
  end .
  if not avail que then leave .
 end .

for each dfbamt where dfbamt.w-crc = wt-crc or wt-crc = 0
 break by w-dfb  by w-day .
 if first-of(w-dfb) then do:
  vi-amt = 0.
  v-amt = 0.
 end.
 v-amt = v-amt + dfbamt.o-amt.
 vi-amt = vi-amt + dfbamt.i-amt .
 dfbamt.o-sum = vi-amt - v-amt .
end.

output to rpt.img .

put "                    ВХОДЯЩИЕ            ИСХОДЯЩИЕ  " skip .

for each dfbamt where ( dfbamt.w-crc = wt-crc or wt-crc = 0 ) break by w-crc by w-dfb  by w-day  .

 if first-of(w-dfb) then do:
    find dfb where dfb.dfb = w-dfb no-lock .
    find trxbal where trxbal.subled = "dfb" and trxbal.acc = dfb.dfb and trxbal.level = 1 and trxbal.crc = dfb.crc no-lock no-error.
    if not avail trxbal then next.
    find crc where crc.crc = w-crc no-lock .
    put  "  -------------------------------------------------------------------------"  skip
         "  " dfb.dfb   "               Вх.остаток    --------->    "
         trxbal.pdam - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-"  skip .

    if w-day = 0 then
    put "  " g-today + w-day " "
        i-amt + dfb.dam[1] - trxbal.pdam format "z,zzz,zzz,zzz,zz9.99-" " "
        o-amt + dfb.cam[1] - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-" " "
        dfb.dam[1] - dfb.cam[1] + o-sum format "z,zzz,zzz,zzz,zz9.99-" skip .
    else
       if w-day > 0 then 
           put "  " g-today + w-day " " i-amt " " o-amt " "
           dfb.dam[1] - dfb.cam[1] + o-sum format "z,zzz,zzz,zzz,zz9.99-" skip .
       else 
           put g-today + w-day " " i-amt " " o-amt " "   "           -------   " skip .
 end .
end.

put skip(2) "  " crc.code "  " g-today " " string(time,"hh:mm:ss") skip.
pause 0.                  
output close.

unix silent value(comprt) rpt.img.
pause 0.
