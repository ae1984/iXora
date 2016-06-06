/* 4sb1_b.p
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
        21/05/08 marinav
 * CHANGES
        04/08/2010 - поправила определение кодов займа и кодов объекта кредитования
        13/12/2010 evseev - добавление столбца "срок погашения" sub11
        03.08.2011 aigul - код займов 05 передала на 07, 06 переделала на 08
        05/11/2013 Sayat(id01143) - ТЗ 2183 от 01/11/2013 отключил подмену кода займа lnshifr
*/


def var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
define variable bilance  as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-cif as char format "x(30)".
def var v-ccode as char format "x(4)".
def var v-gl as char.
def var v-srok as int init 0.
def buffer b-aaa  for txb.aaa.
def var v-rez as char format 'x(1)'.
def var v-val as char format 'x(1)'.


def shared var v-dt     as date format "99/99/9999".
def shared var v-dtn     as date format "99/99/9999".

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
    field sub9   like txb.sub-cod.ccode
    field sub10  like txb.sub-cod.ccode
    field sub11  as char
    field proc   like txb.lon.prem
    field procsum like txb.lon.opnamt.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
hide message no-pause.
message "Обрабатывается филиал  - " trim(txb.sysc.chval) .

for each txb.lon no-lock:
    summa = 0.

    for each txb.lonres where txb.lonres.lon = txb.lon.lon and lev = 1 and txb.lonres.jdt > v-dtn and txb.lonres.jdt <= v-dt and txb.lonres.dc = 'D'
         and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' no-lock:
         find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt le txb.lonres.jdt no-error.
       if avail txb.crchis then  summa = summa + txb.lonres.amt * txb.crchis.rate[1].
    end.
    if summa = 0 then next.

  create wrk.
   wrk.lon = txb.lon.lon.
   wrk.crc = txb.lon.crc.
   wrk.gl = substr(string(txb.lon.gl),1,4).
   wrk.proc = txb.lon.prem.
   wrk.amount = summa .
   wrk.procsum = round(wrk.amount * txb.lon.prem / 100,0).

   wrk.sub11 = ''.
   if txb.lon.duedt - txb.lon.rdt <= 30 then wrk.sub11 = 'до 1 мес (до 30 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 30 and txb.lon.duedt - txb.lon.rdt <= 90 then wrk.sub11 = 'от 1-3 мес (от 31 до 90 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 90 and txb.lon.duedt - txb.lon.rdt <= 180 then wrk.sub11 = 'от 3-6 мес (от 91 до 180 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 180 and txb.lon.duedt - txb.lon.rdt <= 270 then wrk.sub11 = 'от 6-9 мес (от 181 до 270 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 270 and txb.lon.duedt - txb.lon.rdt <= 365 then wrk.sub11 = 'от 9-12 мес (от 271 до 365 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 365 and txb.lon.duedt - txb.lon.rdt <= 730 then wrk.sub11 = 'от 1-2 лет (от 366 до 730 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 730 and txb.lon.duedt - txb.lon.rdt <= 1095 then wrk.sub11 = 'от 2-3 лет (от 731 до 1095 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 1095 and txb.lon.duedt - txb.lon.rdt <= 1825 then wrk.sub11 = 'от 3-5 лет (от 1096 до 1825 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 1825 and txb.lon.duedt - txb.lon.rdt <= 3650 then wrk.sub11 = 'от 5-10 лет (от 1826 до 3650 дней)'.
   if txb.lon.duedt - txb.lon.rdt > 3650 then wrk.sub11 = 'свыше 10лет (от 3651 дня и свыше)'.



  v-srok = txb.lon.duedt - txb.lon.rdt.
  v-srok = (round(v-srok * 12 / 365 , 0)) * 30.

  find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

/*nataly*/
  find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
  if available txb.sub-cod then  wrk.sub9 = txb.sub-cod.ccode. else wrk.sub9 = "0".

  v-rez = substr(txb.cif.geo,3,1).
  if v-rez <> '1' then v-rez = '2'.
  wrk.sub10 = v-rez.

  case txb.lon.crc:
   when 1 then v-val = '1'.
   when 2 or  when 3 then v-val = '2'.
   otherwise v-val = '3'.
  end case.

  wrk.gl = wrk.gl + wrk.sub10 + substr(wrk.sub9,1,1) + v-val.
/*nataly*/


  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnshifr' no-lock no-error.
    /*case txb.sub-cod.ccode:
        /*when '07' then wrk.sub1 = '05'.*/
        when '15' then wrk.sub1 = '13'.
        /*when '08' then wrk.sub1 = '06'.*/
        when '16' then wrk.sub1 = '14'.
        otherwise wrk.sub1 = txb.sub-cod.ccode.
    end case.*/
    wrk.sub1 = txb.sub-cod.ccode.


  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and d-cod = 'lntgt' no-lock no-error.
    if txb.sub-cod.ccode = '18' or txb.sub-cod.ccode = '19' then wrk.sub2 = '20'.
    else wrk.sub2 = txb.sub-cod.ccode.


/*marinav*/
 find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = 2 no-lock no-error.
  if available txb.lonsec1 then wrk.sub4 = "02".
  else do:
     find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
     if available txb.lonsec1 then do:
        wrk.sub4 = "0" + trim(string(txb.lonsec1.lonsec)).
     end.
     else wrk.sub4 = "04".
  end.
/*marinav*/

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and d-cod = 'lnhld' no-lock no-error.
     wrk.sub5 = txb.sub-cod.ccode.

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and d-cod = 'ecdivis' no-lock no-error.
     wrk.sub7 = txb.sub-cod.ccode.
     /*aigul*/
    /*if wrk.sub7 <> "0" then do:
        if wrk.sub1 = '05' then do:
            find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek"
            and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.ccod = "9" no-lock no-error.
            if avail txb.sub-cod then wrk.sub1 = '07'.
        end.
        if wrk.sub1 = '06' then do:
            find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek"
            and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.ccod = "9" no-lock no-error.
            if avail txb.sub-cod then wrk.sub1 = '08'.
        end.
    end.*/
    /**/
end.
/*Овердрафты*/

 for each txb.aaa no-lock where txb.aaa.sta ne 'C',
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
              /*nataly*/
                find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
                if available txb.sub-cod then  wrk.sub9 = txb.sub-cod.ccode. else wrk.sub9 = "0".

                 v-rez = substr(txb.cif.geo,3,1).
                 if v-rez <> '1' then v-rez = '2'.
                 wrk.sub10 = v-rez.

                 case txb.aaa.crc:
                  when 1 then v-val = '1'.
                  when 2 or  when 3 then v-val = '2'.
                  otherwise v-val = '3'.
                 end case.

                  wrk.gl = wrk.gl + wrk.sub10 + substr(wrk.sub9,1,1) + v-val.
        /*nataly*/
         end.
     end.
 end.
