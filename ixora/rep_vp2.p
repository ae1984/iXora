/* rep_vp2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        сбор данных для отчета по валют позиции
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

 * CHANGES
            03/05/2012 Luiza
            29/11/2012 Luiza TZ № 1570 285800 285900 185900

*/

{stvar.i "NEW"}
{st-poz.i "NEW"}  /* New temp-table */

def shared var fdt as date .
def  var vst1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var vst2 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var vst3 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var ven1 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var dr1  as decimal format 'zzz,zzz,zz9.99-'.
def  var cr1  as decimal format 'zzz,zzz,zz9.99-'.
def  var ven2 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var dr2  as decimal format 'zzz,zzz,zz9.99-'.
def  var cr2  as decimal format 'zzz,zzz,zz9.99-'.

def shared var sum1 as decimal.
def shared var sum2 as decimal.
def shared var sum3 as decimal.
def shared var sum4 as decimal.
def shared var sum5 as decimal.
def shared var sum6 as decimal.
/*def shared var sum7 as decimal.
def shared var sum8 as decimal.*/
def shared var v-branch as char.
def shared var v-crc as integer.

vst1 = 0.
vst2 = 0.
vst3 = 0.
 find last txb.glday where txb.glday.gdt lt fdt  and txb.glday.crc eq v-crc
   and txb.glday.gl = 185800 no-lock no-error.
 if available txb.glday then vst1 = txb.glday.dam - txb.glday.cam.
  else vst1 = 0.
  /*vst1 = -1 * vst1.*/

/* отстатки по 285800 */
 find last txb.glday where txb.glday.gdt lt fdt  and txb.glday.crc eq v-crc
   and txb.glday.gl = 285800 no-lock no-error.
 if available txb.glday then vst2 = txb.glday.dam - txb.glday.cam.
  else vst2 = 0.
  /*vst2 = -1 * vst2.*/

  vst1 = - vst2 - vst1.
  ven1 = vst1.

dr1 = 0.
cr1 = 0.
for each txb.jl no-lock where txb.jl.jdt = fdt and (txb.jl.gl  = 185800 or txb.jl.gl  = 285800)  and txb.jl.crc = v-crc use-index jdt.
    dr1 = dr1  + txb.jl.dam .
    cr1 = cr1 + txb.jl.cam.
end. /*for each txb.jl*/
ven1 = ven1 - dr1  + cr1.

if ven1 = 0  and vst1 = 0  then next.

run st-poz.
find st-poz where st-poz.crc = v-crc no-lock no-error.

sum1 = sum1 + vst1.
sum2 = sum2 + dr1.
sum3 = sum3 + cr1.
sum4 = sum4 + ven1.
sum5 = sum5 + st-poz.arppras.
sum6 = sum6 + st-poz.arpsaist.


