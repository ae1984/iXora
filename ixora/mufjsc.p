/* mufjsc.p
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

def shared var g-today as date.
def shared var s-vbank as char.
def shared var s-datt as date.
def shared var s-num like clrdoc.pr.
def shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(9)"
    field bbic like bankl.bic
    field quo as inte format "zzzzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".
def shared stream m-doc.
for each ree where ree.bank matches s-vbank:
def var v-mudate as char format "x(20)".  /* v-valdt ? */
def var v-ref like rem.rem.
def var v-m1 as char format "x(32)".  /* v-ord */
def var v-m2 as char format "x(36)".  /* v-ord */
def var v-m3 as char format "x(36)".  /* v-ord */
def var v-m4 as char format "x(36)".  /* v-ord */
def var v-bm1 as char format "x(28)". /* v-ordins */
def var v-bm2 as char format "x(43)". /* v-ordins */
def var v-bm3 as char format "x(43)". /* v-ordins */
def var v-bm5 as char format "x(60)".
def var v-crccode like crc.code.
def var v-km as char format "x(15)".  /* номер счета плательщика */
def var v-km1 as char format "x(15)".
def var v-kbm as char format "x(3)".  /* код банка плательщика */
def var v-sm as char format "x(11)".  /* v-payment */
def var v-s1 as char format "x(33)".  /* v-bn */
def var v-s2 as char format "x(36)".  /* v-bn */
def var v-s3 as char format "x(36)".  /* v-bn */
def var v-bs1 as char format "x(28)".  /* v-bb */
def var v-bs2 as char format "x(43)".  /* v-bb */
def var v-bs3 as char format "x(43)".  /* v-bb */
def var v-bs5 as char format "x(60)".
def var v-ks as char format "x(15)".   /* v-ba */
def var v-ks1 as char format "x(15)".  /* v-ba */
def var v-kbs as char format "x(3)".   /* v-bb */
def var v-strtmp as char.
def var v-detpay like rem.detpay.
def var v-sumt as char extent 3 format "x(55)".
def var v-numurs as char format "x(13)".
def var v-docnum as inte.
def var i as inte.
def var j as inte.
def var ij as inte.
{men-l.f}

 v-mudate = string(year(g-today),'9999.g ')
          + string(day(g-today),'99') + '.'
          + men-l[month(g-today)].

 v-ref = string(ree.npk,"zz9").


find last cmp no-lock.
 v-m1 = trim(cmp.name) + " " + trim(cmp.addr[1]) + " "
      + trim(cmp.addr[2]) + " " + trim(cmp.addr[3]) .
 v-m2 = v-m1.
 v-m1 = substring(v-m1,1,32).
 i = r-index(v-m1," ").
 if i ne 0 then do:
    v-m1 = substring(v-m1,1,i - 1).
    v-m2 = substring(v-m2,i + 1).
 end.
 else v-m2 = substring(v-m2,33).
 v-m3 = v-m2.
 v-m2 = substring(v-m2,1,43).
 i = r-index(v-m2," ").
 if i ne 0 then do:
    v-m2 = substring(v-m2,1,i - 1).
    v-m3 = substring(v-m3,i + 1).
 end.
 else  v-m3 = substring(v-m3,44).

 v-m4 = v-m3.
 v-m3 = substring(v-m3,1,43).
 i = r-index(v-m3," ").
 if i ne 0 then do:
    v-m3 = substring(v-m3,1,i - 1).
    v-m4 = substring(v-m4,i + 1).
 end.
 else  v-m4 = substring(v-m4,44).

v-bm5 = substr(trim(cmp.name),1,60).
v-bm1 = trim(cmp.name).
v-bm2 = v-bm1.
v-bm1 = substring(v-bm1,1,29).
i = r-index(v-bm1," ").
if i ne 0 then do:
    v-bm1 = substring(v-bm1,1,i - 1).
    v-bm2 = substring(v-bm2,i + 1).
end.
else  v-bm2 = substring(v-bm2,30).

v-bm3 = v-bm2.
v-bm2 = substring(v-bm2,1,43).
i = r-index(v-bm2," ").
if i ne 0 then do:
    v-bm2 = substring(v-bm2,1,i - 1).
    v-bm3 = substring(v-bm3,i + 1).
end.
else  v-bm3 = substring(v-bm3,44).


v-crccode = "KZT".

find sysc where sysc.sysc = "clecod" no-lock.
if length(trim(sysc.chval)) = 3 then v-kbm = trim(sysc.chval).
else v-kbm = substring(sysc.chval,7,3).

find bankl where bankl.bank = "190" no-lock.
  v-km = trim(bankl.acct).


v-sm = string(ree.kopa,">>>>>>>9.99").

find bank where bank.bank = ree.bank no-lock.
 v-s1 = trim(bank.name) + " " + trim(bank.addr[1]) + " "
      + trim(bank.addr[2]) + " " + trim(bank.addr[3]).
 v-s2 = v-s1.
 v-s1 = substring(v-s1,1,34).
 i = r-index(v-s1," ").
 if i ne 0 then do:
    v-s1 = substring(v-s1,1,i - 1).
    v-s2 = substring(v-s2,i + 1).
 end.
 else v-s2 = substring(v-s2,35).

 v-s3 = v-s2.
 v-s2 = substring(v-s2,1,43).
 i = r-index(v-s2," ").
 if i ne 0 then do:
    v-s2 = substring(v-s2,1,i - 1).
    v-s3 = substring(v-s3,i + 1).
 end.
 else v-s3 = substring(v-s3,44).

 v-bs5 = substr(trim(bank.name),1,60).
 v-bs1 = bank.name.
 v-bs2 = v-bs1.
 v-bs1 = substring(v-bs1,1,29).
 i = r-index(v-bs1," ").
 if i ne 0 then do:
    v-bs1 = substring(v-bs1,1,i - 1).
    v-bs2 = substring(v-bs2,i + 1).
 end.
 else  v-bs2 = substring(v-bs2,30).
 v-bs3 = v-bs2.
 v-bs2 = substring(v-bs2,1,43).
 i = r-index(v-bs2," ").
 if i ne 0 then do:
    v-bs2 = substring(v-bs2,1,i - 1).
    v-bs3 = substring(v-bs3,i + 1).
 end.
 else  v-bs3 = substring(v-bs3,44).


v-ks = bank.acct.
v-ks1 = v-ks.
if index(v-ks1,"/") ne 0 then do :
    v-ks = substring(v-ks,1,index(v-ks,"/") - 1).
    v-ks1 = substring(v-ks1,index(v-ks1,"/") + 1).
end.
else v-ks1 = " ".

/*v-kbs = substring(rem.actinsact,1,10).*/
if length(trim(bank.bank)) = 3 then v-kbs = trim(bank.bank).
else if bank.bank begins "310101" then v-kbs = substring(bank.bank,7,3).
else v-kbs = substring(bank.bank,4,3).

v-strtmp = "".
run Sm-vrd(input truncate(ree.kopa,0),output v-strtmp).
v-strtmp = v-strtmp + " " + string(ree.kopa - truncate(ree.kopa,0),".99")
 + ".".
do i = 1 to 3:
   v-sumt[i] = " ".
end.
i = 1.
v-sumt[1] = substring(v-crccode,1,3) + " " .
j = 4.
repeat while i <= 3:
    ij = index(v-strtmp," ").
    if ij = 0 then ij = length(v-strtmp).
    if j + ij > 55 then do:
        i = i + 1.
        j = 0 .
    end.
    v-sumt[i] = v-sumt[i] + substring(v-strtmp,1,ij).
    j = j + ij.
    v-strtmp = substring(v-strtmp,ij + 1).
    if length(v-strtmp) = 0 then leave.
end.

v-detpay[1] = "Платежные документы клиентов.     ".
v-detpay[2] = "Приложений :     " + trim(string(ree.quo,"zzz9 ")) + "  шт.".

put stream m-doc
        "          С П И С О К    " at 15 skip
        "итоговых платежных поручений Nr" at 15 v-ref skip
        v-mudate at 22 skip
        v-kbm at 5 " " v-bm5 skip
        v-kbs at 5 " " v-bs5 skip(1)
      "-------------------------------------------" at 10 skip
      "|   Док.   |    Счет      |  Сумма (XXX)  |" at 10 skip
      "|   Nr     | получателя   |               |" at 10 skip
      "-------------------------------------------" at 10 skip.
v-docnum = 0.
for each clrdoc where clrdoc.bank = ree.bank and clrdoc.pr = s-num
                  and clrdoc.rdt = s-datt :
    v-docnum = v-docnum + 1.              
    put stream m-doc
        "|" at 10 clrdoc.rem at 11 "|" at 21 clrdoc.tacc at 23 "|" at 36
        clrdoc.amt format "zzz,zzz,zzz.99" at 38 "|" at 52 skip.
end.
    put stream m-doc
        "-------------------------------------------" at 10 skip
        "|" at 10 " Итого" at 11 "|" at 36 ree.kopa format "zzz,zzz,zzz.99"
        at 38 "|" at 52 skip
        "-------------------------------------------" at 10 skip(2).

for each clrdoc where clrdoc.rdt = s-datt and clrdoc.pr = s-num:
    clrdoc.maks = yes.
end.
{mujsc.f}
pause 0.
end.
