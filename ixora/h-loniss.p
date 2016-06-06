/* h-loniss.p
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

def shared var s-lon like lon.lon.
def var v-cntall as int .
def var v-cnt as int.
def var v-lcnt as char.
def var v-cif like cif.cif.
def var v-sum as dec format ">>>,>>>,>>>,>>9.99-".
def var v-amt as dec.
def var v-crc like crc.crc. 

find lon where lon.lon eq s-lon no-lock no-error.
find loncon where loncon.lon eq  s-lon no-lock no-error.
v-lcnt = substring(loncon.lcnt,1,12).
v-cif = lon.cif.
v-crc = lon.crc.
v-sum = 0.
for each loncon where substring(loncon.lcnt,1,12) eq v-lcnt and
loncon.cif eq v-cif no-lock :
find lon where lon.lon eq loncon.lon no-lock no-error.
if lon.crc ne v-crc then do:
message "Кредит " + lon.lon " выдан в другой валюте."
view-as alert-box.
next.
end.

if available lon then do :
v-cntall = v-cntall + 1.
v-amt = 0.
for each trxbal where trxbal.sub eq "LON" and trxbal.acc eq loncon.lon
and trxbal.crc eq lon.crc no-lock :
    if trxbal.lev eq 1 or trxbal.lev eq 7 or trxbal.lev eq 8 then
    v-amt = v-amt + trxbal.dam - trxbal.cam.
end.
if v-amt ne 0 then v-cnt = v-cnt + 1.
v-sum = v-sum + v-amt .
end.
end.
message "Кредитная линия " v-lcnt +
".\n Всего траншей " + trim(string(v-cntall,">>>>9")) 
+ ".\n В том числе с остатком " + trim(string(v-cnt,">>>9")) +  
" на сумму " + trim(string(v-sum,">>>,>>>,>>>,>>>,>>9.99-"))  
view-as alert-box.
