/* 3sb.p
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
        COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        13/12/2010 evseev - добавление столбца "срок погашения" sub09 , консолидация
*/

/*
 04/03/03  Задолженность по кредитам
*/

def var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def var v-srok as int init 0.
def var v-pros_od as int init 0.
def var v-pros_prc as int init 0.
define shared variable v-dt     as date format "99/99/9999".
def buffer b-aaa  for txb.aaa.
def shared temp-table  wrk
    field lon    like txb.lon.lon
    field crc    like txb.lon.crc
    field name   like txb.cif.name
    field gl     like txb.lon.gua
    field amount like txb.lon.opnamt
    field sub1   like txb.sub-cod.ccode
    field sub2   like txb.sub-cod.ccode
    field sub3   like txb.sub-cod.ccode
    field sub4   like txb.sub-cod.ccode
    field sub5   like txb.sub-cod.ccode
    field sub6   like txb.sub-cod.ccode
    field sub7   like txb.sub-cod.ccode
    field sub8   like txb.sub-cod.ccode
    field sub9   as char
    field proc   like txb.lon.prem
    field procsum like txb.lon.opnamt.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
hide message no-pause.
message "Обрабатывается филиал  - " trim(txb.sysc.chval) .

for each txb.lon by txb.lon.gl:

  run atl-dat1(txb.lon.lon,v-dt,2,output summa).
  if summa = 0 then next.

  create wrk.
   wrk.lon = txb.lon.lon.
   wrk.crc = txb.lon.crc.
   wrk.gl = substr(string(txb.lon.gl),1,4).
   wrk.proc = txb.lon.prem.

   find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt le v-dt no-error.
    if avail txb.crchis then do.
       wrk.amount = summa * txb.crchis.rate[1].
    end.
   wrk.procsum = round(wrk.amount * txb.lon.prem / 100,0).

   run lndayspr_txb(txb.lon.lon , v-dt , no , output v-pros_od, output v-pros_prc).
   wrk.sub9 = ''.
   if v-pros_od <= 30 then wrk.sub9 = 'до 1 мес (до 30 дней)'.
   if v-pros_od > 30 and   v-pros_od <= 90 then wrk.sub9 = 'от 1-3 мес (от 31 до 90 дней)'.
   if v-pros_od > 90 and   v-pros_od <= 180 then wrk.sub9 = 'от 3-6 мес (от 91 до 180 дней)'.
   if v-pros_od > 180 and  v-pros_od <= 270 then wrk.sub9 = 'от 6-9 мес (от 181 до 270 дней)'.
   if v-pros_od > 270 and  v-pros_od <= 365 then wrk.sub9 = 'от 9-12 мес (от 271 до 365 дней)'.
   if v-pros_od > 365 and  v-pros_od <= 730 then wrk.sub9 = 'от 1-2 лет (от 366 до 730 дней)'.
   if v-pros_od > 730 and  v-pros_od <= 1095 then wrk.sub9 = 'от 2-3 лет (от 731 до 1095 дней)'.
   if v-pros_od > 1095 and v-pros_od <= 1825 then wrk.sub9 = 'от 3-5 лет (от 1096 до 1825 дней)'.
   if v-pros_od > 1825 and v-pros_od <= 3650 then wrk.sub9 = 'от 5-10 лет (от 1826 до 3650 дней)'.
   if v-pros_od > 3650 then wrk.sub9 = 'свыше 10лет (от 3651 дня и свыше)'.



  v-srok = txb.lon.duedt - txb.lon.rdt.
  v-srok = (round(v-srok * 12 / 365 , 0)) * 30.

  find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnshifr' no-lock no-error.
    wrk.sub1 = txb.sub-cod.ccode.

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
    wrk.sub2 = txb.sub-cod.ccode.

/*  if v-srok ge 0 and v-srok le 30 then wrk.sub3 =  "01".
  if v-srok ge 31 and v-srok le 90 then wrk.sub3 =  "02".
  if v-srok ge 91 and v-srok le 180 then wrk.sub3 =  "03".
  if v-srok ge 181 and v-srok le 360 then wrk.sub3 =  "04".
  if v-srok ge 361 and v-srok le 1080 then wrk.sub3 =  "05".
  if v-srok ge 1081 and v-srok le 1800 then wrk.sub3 =  "06".
  if v-srok ge 1801 then wrk.sub3 =  "07".
*/

 find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = 2 no-lock no-error.
  if available txb.lonsec1 then wrk.sub4 = "02".
  else do:
     find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
     if available txb.lonsec1 then do:
        if txb.lonsec1.lonsec = 1 then wrk.sub4 = "01".
        if txb.lonsec1.lonsec = 2 then wrk.sub4 = "02".
        if txb.lonsec1.lonsec = 3 then wrk.sub4 = "03".
        if txb.lonsec1.lonsec = 5 then wrk.sub4 = "05".
        if txb.lonsec1.lonsec = 4 then wrk.sub4 = "04".
        if txb.lonsec1.lonsec = 6 then wrk.sub4 = "06".
     end.
     else wrk.sub4 = "04".
  end.

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnhld' no-lock no-error.
     wrk.sub5 = txb.sub-cod.ccode.

/*  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and d-cod = 'lneko' no-lock no-error.
     wrk.sub6 = sub-cod.ccode.
*/
  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
     wrk.sub7 = txb.sub-cod.ccode.

/*  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and d-cod = 'lnopf' no-lock no-error.
     wrk.sub8 = sub-cod.ccode.
*/
end.
/*Овердрафты*/

 for each txb.aaa where txb.aaa.sta ne 'C',
     each txb.lgr of txb.aaa ,
     each txb.led of txb.lgr where txb.led.led = "DDA" no-lock:
     find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.


     find first b-aaa where b-aaa.aaa = txb.aaa.craccnt  no-lock no-error.
      if available b-aaa then do.
         find last txb.aab where txb.aab.aaa = b-aaa.aaa and txb.aab.fdt le v-dt
                  no-lock no-error.
         if avail txb.aab and txb.aab.bal <> 0 then do:
            find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le v-dt no-error.
            create wrk.
              wrk.lon = txb.aaa.aaa.
              wrk.crc = txb.aaa.crc.
              wrk.gl = '1401'.
              wrk.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
              wrk.amount = abs(txb.aab.bal * txb.crchis.rate[1]).
              wrk.sub1 = '01.1'.
              wrk.sub2 = '10'.
              wrk.sub3 = '01'.
              wrk.sub4 = '05'.
              wrk.sub5 = '20'.
              wrk.sub6 = '11'.
              wrk.sub7 = '51'.
              wrk.sub8 = '12'.
         end.
      end.
 end.
/**/


