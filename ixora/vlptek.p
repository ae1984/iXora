/* vlptek.p
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        28/03/2006 nataly  - добавила run st-poz
        14/04/06 nataly добавили колонку чистая позиция
        20/07/06 nataly добавила филиал г Караганда
        07/08/06 nataly добавила проверку на vst1 = 0
        24.07.09 marinav - перевод в тенге с учетом внебаланса
        01/02/12 dmitriy - расчет Чистой ВП в KZT для UAH,GBP,SEK,AUD,CHF
        09.11.2012 dmitriy - изменение алгоритма в связи с добавлением новых счетов конвертации (ТЗ 1569)
        04.12.2012 dmitriy - изменил формулу для расчета ВП на начало и конец периода
        18.02.2013 dmitriy - убрал проверку на разность остатков на начало и конец периода. СЗ от 18.02.2013
*/

{stvar.i "NEW"}
{st-poz.i "NEW"}  /* New temp-table */

def input parameter p-bank as char.

def shared temp-table wrk
field bank as char
field crc as char
field ost1 as deci format 'zzz,zzz,zzz,zz9.99-'
field ost2 as deci format 'zzz,zzz,zzz,zz9.99-'
field dr as deci format 'zzz,zzz,zzz,zz9.99-'
field cr as deci format 'zzz,zzz,zzz,zz9.99-'
field arpsaist as deci format 'zzz,zzz,zzz,zz9.99-'
field arppras as deci format 'zzz,zzz,zzz,zz9.99-'.

def shared var fdt as date .
def  var vst1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var ven1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var dr1  as decimal format 'zzz,zzz,zz9.99-'.
def  var cr1  as decimal format 'zzz,zzz,zz9.99-'.
def  var sum8  as decimal format 'z,zzz,zzz,zz9.99-'.
def var v1858 as deci.
def var v2858 as deci.

def shared stream rpt.
def shared var sum1 as decimal.
def shared var sum2 as decimal.
def shared var sum3 as decimal.
def shared var sum4 as decimal.
def shared var sum5 as decimal.
def shared var sum6 as decimal.
def shared var sum7 as decimal.
def shared var sum88 as decimal.
def shared var v-branch as char.
def shared var v-crc as integer.

find last txb.glday where txb.glday.gdt lt fdt and txb.glday.crc eq v-crc and txb.glday.gl = 185800 no-lock no-error.
if available txb.glday then vst1 = txb.glday.dam - txb.glday.cam.
else vst1 = 0.

vst1 = -1 * vst1.
ven1 = vst1.

find first txb.jl where txb.jl.jdt = fdt and (txb.jl.gl = 185800 or txb.jl.gl = 285800) and txb.jl.crc = v-crc use-index jdt no-lock no-error.
if available txb.jl then do:
    for each txb.jl no-lock where txb.jl.jdt = fdt and (txb.jl.gl  = 185800 or txb.jl.gl = 285800) and txb.jl.crc = v-crc use-index jdt.
        dr1 = dr1  + txb.jl.dam .
        cr1 = cr1 + txb.jl.cam.
    end. /*for each txb.jl*/
end. /*if avail txb.jl*/
ven1 = ven1 - dr1  + cr1.

/*if ven1 = 0  and vst1 = 0  then next.*/

/*  if dr1 = 0 and cr1 = 0 and  dr2 = 0 and cr2 = 0 then next.
 */
run st-poz.


find st-poz where st-poz.crc = v-crc no-lock no-error.
find last txb.crchis where crchis.crc = v-crc and crchis.rdt <= fdt   use-index crcrdt no-lock no-error.
if avail crchis then do:
    if v-crc = 2 then sum8 =  (ven1 + st-poz.arppras - st-poz.arpsaist) * crchis.rate[1] + st-poz.arpus.
    if v-crc = 3 then sum8 =  (ven1 + st-poz.arppras - st-poz.arpsaist) * crchis.rate[1] + st-poz.arpeu.
    if v-crc = 4 then sum8 =  (ven1 + st-poz.arppras - st-poz.arpsaist) * crchis.rate[1] + st-poz.arpru.

    /* dmitriy */
    if v-crc = 5 or v-crc = 6 or v-crc = 7 or v-crc = 8 or v-crc = 9 then
    sum8 =  (ven1 + st-poz.arppras - st-poz.arpsaist) * crchis.rate[1] . /* для валют 5-9 arp счетов нет - бухгалтерия */
end.

put stream rpt skip  p-bank ' '   vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107 (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-'  at 147 skip .

/*===================================================*/
v2858 = 0. v1858 = 0.
find last txb.glday where txb.glday.gdt < fdt and txb.glday.crc = v-crc and txb.glday.gl = 285800 no-lock no-error.
if available txb.glday then v2858 = txb.glday.dam - txb.glday.cam.

find last txb.glday where txb.glday.gdt < fdt and txb.glday.crc = v-crc and txb.glday.gl = 185800 no-lock no-error.
if available txb.glday then v1858 = txb.glday.dam - txb.glday.cam.

create wrk.
wrk.bank = p-bank.
wrk.ost1 =  - v2858 - v1858 + st-poz.arppras - st-poz.arpsaist.
wrk.dr = dr1.
wrk.cr = cr1.
wrk.ost2 = - v2858 - v1858 - dr1 + cr1 + st-poz.arppras - st-poz.arpsaist.
wrk.arpsaist = st-poz.arpsaist.
wrk.arppras = st-poz.arppras.

find first txb.crc where txb.crc.crc = v-crc no-lock no-error.
if avail txb.crc then wrk.crc = txb.crc.code.
/*===================================================*/


/*
 if v-branch = 'pragma' then
    put stream rpt skip  'Алматы '  vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107 (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-'  at 147 skip .
 else

 if v-branch = 'branch1' then
    put stream rpt skip  'Астана '  vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107  (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-' at 147  skip.
 else

 if v-branch = 'branch2' then
    put stream rpt skip  'Уральск ' vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107  (ven1 + st-poz.arppras - st-poz.arpsaist) format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-' at 147   skip.
 else

 if v-branch = 'branch3' then
    put stream rpt skip 'Атырау '  vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107  (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127  sum8 format 'zzz,zzz,zzz,zz9.99-' at 147  skip.
 else

 if v-branch = 'branch4' then
    put stream rpt skip  'Актюб-к '  vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107  (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-' at 147  skip.
 else

  if v-branch = 'branch5' then
     put stream rpt skip 'Карган '  vst1 at 9 dr1 at 30 cr1 at 50 ven1  at 67 st-poz.arpsaist  at 87 st-poz.arppras  at 107  (ven1 + st-poz.arppras - st-poz.arpsaist)  format 'zzz,zzz,zzz,zz9.99-' at 127 sum8 format 'zzz,zzz,zzz,zz9.99-' at 147  skip.
*/

  sum1 = sum1 + vst1.
  sum2 = sum2 + dr1.
  sum3 = sum3 + cr1.
  sum4 = sum4 + ven1.
  sum5 = sum5 + st-poz.arppras.
  sum6 = sum6 + st-poz.arpsaist.
/*  sum7 = sum7 + sum4 + sum6 - sum5. */
  sum88 = sum88 + sum8.


