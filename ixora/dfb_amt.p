/* dfb_amt.p
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

/* {mainhead.i} */
def shared var g-today as date . 
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
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  Message " Записи OURBNK нет в файле sysc !! ".
  pause . 
  return .
 end.
ourbank = sysc.chval.


x = 40 . y = 5 . h = 13 .
ym = 5 .
repeat :

 update v-crc label "Валюта  " with column x + 2
  side-label overlay no-hide frame crc.
 wt-crc = v-crc .
/*
h = 0 . */
for each v-dfb. delete v-dfb . end .
for each dfb where dfb.crc = v-crc .
 /*
 h = h + 1. */
 create v-dfb.
 v-dfb.dfb = dfb.dfb .
 v-dfb.slc = " ".
end.
              /*
if h > 13 then h = 13 .
                */

form " " v-dfb.dfb v-dfb.slc 
 " " with column x row y h down overlay
 no-hide frame ddd .
           /*
   display tout with side-label row 21 no-box frame ttt.
           */
repeat :
display "  <space> - выделить/снять. ........." with no-label no-box
row ym + 5 frame ss.
display "  <a>     - выделить все НОСТРО. ...." with no-label no-box
row ym + 6 frame ss1.
display "  <d>     - снять все НОСТРО...... .." with no-label no-box
row ym + 7 frame ss2.
display "  <F1>    - рассчитать..............." with no-label no-box
row ym + 8 frame ss3.
display "  <F4>    - установить валюту........" with no-label no-box
row ym + 9 frame ss4.
pause 0 .
 find first v-dfb no-error.
 if not avail v-dfb then leave .

 cur = recid(v-dfb).

repeat:
 clear frame ddd all.
 find v-dfb where recid(v-dfb) = cur .
 view frame ddd.
 pause 0.

repeat with frame ddd:
  display v-dfb.dfb column-label "НОСТРО" v-dfb.slc column-label "Выдел.".
  find next v-dfb no-error.
  if not avail v-dfb then leave.
  if frame-line = h then leave .
  down with frame ddd.
  pause 0.
 end.
/*
 display frame-down(ddd) frame-line(ddd).
 */
 up frame-line(ddd) - 1  with frame ddd.

repeat:

 find v-dfb where recid(v-dfb) = cur .
 display v-dfb.dfb v-dfb.slc with frame ddd.
 color display message v-dfb.dfb  with frame ddd.

 readkey . /* !!!!!!!!!!!!! */

    /*
     find que of v-dfb no-error. if avail que then
     display que.pid with column 10 row 5 frame aaa .
    */
 color display normal v-dfb.dfb with frame ddd.

 if keyfunction(lastkey) = "cursor-up" then
     do:
      find prev v-dfb no-error.
      if avail v-dfb then do:
      cur = recid(v-dfb).
      if frame-line(ddd) = 1 then
       scroll down with frame ddd .
       else
       up 1 with frame ddd.
      end.
     end.

 if keyfunction(lastkey) = "cursor-down" then
     do:
      find next v-dfb no-error.
      if avail v-dfb then do:
      cur = recid(v-dfb).
      if frame-line(ddd) = frame-down(ddd)  then
       scroll up with frame ddd .
       else
       down 1 with frame ddd.
      end.
     end.
 if keyfunction(lastkey) = "home" then
     do:
      find first v-dfb .
      cur = recid(v-dfb).
      leave .
     end.

 if keyfunction(lastkey) = "right-end" then
     do:
      find last v-dfb .
      iss = h .
      repeat :
      iss = iss - 1.
      find prev v-dfb .
      if iss = 1 then leave .
      end.
       cur = recid(v-dfb).
       leave .
     end.

 if keyfunction(lastkey) = " " then
     do:
      if  v-dfb.slc = "*" then v-dfb.slc = " " .
       else  v-dfb.slc = "*" .
     end.

 if keyfunction(lastkey) = "a" then
     do:
      for each v-dfb . v-dfb.slc = "*" . end .
      leave .
     end.

 if keyfunction(lastkey) = "d" then
     do:
      for each v-dfb . v-dfb.slc = " " . end .
      leave .
     end.

 if keyfunction(lastkey) = "page-down" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find next v-dfb no-error .
      if not avail v-dfb then
      do:
       find last v-dfb .
       find prev v-dfb .
       find prev v-dfb .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(v-dfb).
       leave .
     end.
 if keyfunction(lastkey) = "page-up" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find prev v-dfb no-error .
      if not avail v-dfb then
      do:
       find first v-dfb .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(v-dfb).
       leave .
     end.

 if keyfunction(lastkey) = "End-Error" then leave .


 if keyfunction(lastkey) = "GO" then leave .
 else
  do:

      find first v-dfb where v-dfb.dfb 
       begins keyfunction(lastkey) no-error.
      if avail v-dfb then do:
       cur = recid(v-dfb).
       leave .
      end.
      else find v-dfb where recid(v-dfb) = cur .
  end.

end.

 if keyfunction(lastkey) = "End-Error" then leave .
 if keyfunction(lastkey) = "GO" then leave .
pause 0.

end.
 if keyfunction(lastkey) = "End-Error" then leave .

/*
 vtoday = today.
 vtime  = string(time,"HH:MM:SS").
*/

repeat:
output to rpt.img .
output close.

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
/*
 for each dfbamt . display dfbamt . end . 
  */
 message " Ж Д И Т Е...  Р а с с ч е т......."  .
/*
display string(time,"hh:mm:ss") i . 
*/
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

 
 
 end . /*
display string(time,"hh:mm:ss") i . pause .
         */


/*
for each t-rem where /* t-rem.grp = 2 and */ t-rem.valdt >= g-today
 and t-rem.vjh eq ?  and t-rem.valdt ne ?  use-index valdt no-lock .
                          
/*
 find b-bank where b-bank.bank = t-rem.bank no-lock no-error.
 
 if available b-bank then do:
 find first v-dfb where v-dfb.dfb = t-rem.tdfb and v-dfb.slc = "*"
      no-error .
*/
  find first v-dfb where v-dfb.dfb = t-rem.tdfb  and v-dfb.slc = "*"
      no-error .
   if  not avail v-dfb  then next .
   find first dfbamt where w-dfb = t-rem.tdfb and w-day eq
     ( t-rem.valdt - g-today ) no-error .
   if not avail dfbamt then do:
     find dfb where dfb.dfb = t-rem.tdfb no-lock .
     if ( dfb.crc ne wt-crc ) and wt-crc ne 0 then next.
     create dfbamt .
     w-dfb = t-rem.tdfb .
     w-day = valdt - g-today .
     dfbamt.w-crc = dfb.crc .
    end.
   if t-rem.grp = 2 then dfbamt.o-amt = o-amt + t-rem.payment.
   else if t-rem.grp = 1 and t-rem.jh = ? then
   i-amt = i-amt + t-rem.payment.
end.
efgfg
for each brem where /* brem.grp = 2 and */ brem.valdt >= g-today
 and brem.vjh eq ?  and brem.valdt ne ? use-index valdt no-lock .
 /*
 find b-bank where b-bank.bank = brem.bank no-lock no-error.
 if available b-bank then do:
   */
  find first v-dfb where v-dfb.dfb = brem.tdfb and v-dfb.slc = "*"
      no-error .
   if  not avail v-dfb  then next .
   find first dfbamt where w-dfb = brem.tdfb and w-day eq
     ( brem.valdt - g-today ) no-error .
   if not avail dfbamt then do:
     find dfb where dfb.dfb = brem.tdfb no-lock .
     if ( dfb.crc ne wt-crc ) and wt-crc ne 0 then next.
     create dfbamt .
     w-dfb = brem.tdfb .
     w-day = valdt - g-today .
     dfbamt.w-crc = dfb.crc .
    end. 
   if brem.grp = 2 then dfbamt.o-amt = o-amt + brem.payment.
   else if brem.grp = 1 and brem.jh = ? then
   i-amt = i-amt + brem.payment.
end.
*/

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
 
/*

for each dfbamt .
 display dfbamt.
 end .
 pause .
 
 */

output to rpt.img .

put """                    ВХОДЯЩИЕ            ИСХОДЯЩИЕ  """ skip .
for each dfbamt where ( dfbamt.w-crc = wt-crc or wt-crc = 0 )
 break by w-crc by w-dfb  by w-day  .
 if first-of(w-dfb) then do:
  find dfb where dfb.dfb = w-dfb no-lock .
  find trxbal where trxbal.subled = "dfb" and trxbal.acc = dfb.dfb
             and trxbal.level = 1 and trxbal.crc = dfb.crc no-lock no-error.
  find crc where crc.crc = w-crc no-lock .
  put
  """  ----------------------------------------------------------------------"""
  skip
  """" dfb.dfb " " "               Вх.остаток    --------->   "
  trxbal.pdam - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-" """" skip .
 if w-day = 0 then
 put """"
  g-today + w-day " "
  i-amt + dfb.dam[1] - trxbal.pdam format "z,zzz,zzz,zzz,zz9.99-" " "
  o-amt + dfb.cam[1] - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-" " "
  dfb.dam[1] - dfb.cam[1] + o-sum format "z,zzz,zzz,zzz,zz9.99-"
  """" skip .
 else
 if w-day > 0 then 
 put """"
  g-today + w-day " "
  i-amt " "
  o-amt " "
  dfb.dam[1] - dfb.cam[1] + o-sum format "z,zzz,zzz,zzz,zz9.99-"
  """" skip .
  else 
   put """"
     g-today + w-day " "
     i-amt " "
     o-amt " "
    "           -------   "
     """" skip .
  end . 
  
  
  
  
  
end.
put """" crc.code "  " g-today " " string(time,"hh:mm:ss")
"""" .
                  /*
put """ =============   End of Report =============================""".
                    */
pause 0 .

output close .



/*
display skip(2)
  "=====   DOKUMENTA BEIGAS   ====="   SKIP(15)
  with frame rptend{2} no-box no-label .
output close.
  */
              /*
    unix silent less rpt.img. */
    hide frame ddd .
    hide frame ss.
    hide frame ss1.
    hide frame ss2.
    hide frame ss3.
    hide frame ss4.
    run brrpt.
    pause 0 .
    if keyfunction(lastkey) = "End-Error" then leave .

  end.
 end.
 pause 0 .
end .
