/* uvedword.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Уведомление в ответ на заявку на получение овердрафта
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14/09/2011 dmitriy
 * BASES
        BANK
 * CHANGES
        23/09/2011 dmitriy - изменил алгоритм формирования номера заявки из номера овердрафта
        30/09/2013 galina - ТЗ1371 выводим суммы прописью на казахском и на русском
*/


{global.i}

def var list1 as char initial "70,80".

def shared var s-lon like lon.lon.
def stream m-out.

def var itog-od   as deci.
def var itog-perc as deci.
def var payment1 as deci.
def var payment2 as deci.

def var v-ofile as char.
def var v-ifile as char.
def stream v-out.
def var v-str as char.

function sum-space returns char (input sum as deci).
    def var s as char.
    def var s1 as char.
    def var s2 as char.
    def var n as int.
    def var n1 as int.
    def var i as int.

    s = string(sum).
    n = length(s).
    if n <= 3 then n1 = 1.
    if n > 3 and n <= 6 then n1 = 2.
    if n > 6 and n <= 9 then n1 = 3.
    if n > 9 and n <= 12 then n1 = 4.
    if n > 12 and n <= 15 then n1 = 5.

    s2 = ''.
    if n1 = 1 then s2 = s.
    if n1 > 1 then do:
        do i = 1 to n1:
           if n - 3 * i + 1 >= 1 then s1 = " " + substr(s, n - 3 * i + 1 , 3). /* &nbsp */
           else if  n - 3 * i + 1 = 0 then s1 = substr(s, 1 , 2).
           else if  n - 3 * i + 1 < 0 then s1 = substr(s, 1 , abs(n - 3 * i + 1)).
           s2 = s1 + s2.
        end.
    end.

    return s2.
end function.

function tiin returns char (input sum as deci).
    def var s as char.
    def var s1 as char.
    def var sum1 as int.

    sum = sum - trunc(sum,0).
    s = string(sum).
    s1 = substr(s, 2, 2).
    if length(s1) = 1 then s1 = s1 + '0'.
    if s1 = '' then s1 = '00'.

    return s1.
end function.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.

def var s-ourbank as char no-undo.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

/* Сумма основного долга */
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock:
    itog-od = itog-od + lnsch.stval.
end.

/* Сумма вознаграждения долга */
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock:
    itog-perc = itog-perc + lnsci.iv-sc.
end.

/* Первый платеж */
find first lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock no-error.
if avail lnsci then payment1 = lnsci.iv-sc.

/* Второй платеж */
payment2 = (itog-od + itog-perc) - payment1.

if lookup (string(lon.grp), list1) > 0 then run PrintUved.
else message " Уведомление формируется только для групп кредитов 70 и 80 " view-as alert-box error.



procedure PrintUved:

    def var kz_txt as char extent 20.
    def var ru_txt as char extent 20.
    def var str as char.
    def var str2 as char.
    def var strkz as char.
    def var tiin-perc as integer.
    def var tiin-od as integer.
    def var tiin-pay1 as integer.
    def var tiin-pay2 as integer.
    def var v-datastrru as char.
    def var v-datastrkz as char.
    def var v-datapercru as char.
    def var v-dataperckz as char.
    def var v-dataodru as char.
    def var v-dataodkz as char.
    def var dt1 as char.
    def var dt2 as char.
    def var num as char.
    def var v-pref as char.
    def var ru-odsum as char.
    def var kz-odsum as char.
    def var ru-percsum as char.
    def var kz-percsum as char.
    def var ru-pay1 as char.
    def var kz-pay1 as char.
    def var ru-pay2 as char.
    def var kz-pay2 as char.
    def var v-loncon as char.
    def var kz-od1 as char.
    def var ru-od1 as char.

    find first loncon where loncon.lon = s-lon no-lock no-error.
    if avail loncon then do:
        v-loncon = entry(1, loncon.lcnt, " ") no-error.
        num = entry(1, loncon.lcnt, "  ").
        num = substr(loncon.lcnt, length(num) + 2).
        if substr(num,1,1) = " " then num = substr(num,2).
        if num <> " " and length(num) = 1 then num = "0" + num.
        if num = "" or num = " " then num = "0".
    end.

    find first loncon where loncon.lcnt = v-loncon no-lock no-error.
    if avail loncon then find first lon where lon.lon = loncon.lon no-lock no-error.

    find first crc where crc.crc = lon.crc no-lock no-error.
    find first cif where cif.cif = lon.cif no-lock no-error.

    v-ifile = "/data/export/uved.htm".
    v-ofile = "uved.htm" .



    /*num = substr(loncon.lcnt, length(dt1) + 3, 2).*/

    /*if num = "" then num = " «__»".
    if length(num) = 1 then num = '0' + num.
    if substr(num,1,1) = '-' and length(num) = 2 then num = replace(num, '-', '0').*/

    if cif.prefix = "ТОО" then v-pref = "ЖШС".
    else if cif.prefix = "АО" then v-pref = "АЌ".
    else v-pref = cif.prefix.

    find last lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
    find first lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock no-error.

    run pkdefdtstr(lon.rdt, output v-datastrru, output v-datastrkz).
    run pkdefdtstr(lnsci.idat, output v-datapercru, output v-dataperckz).
    run pkdefdtstr(lnsch.stdat, output v-dataodru, output v-dataodkz).

    dt1 = entry(1, loncon.lcnt, "  ").
    dt2 = substr(loncon.lcnt, length(dt1) + 3, 5).
    if dt2 = "" then dt2 = "«__» _______ " + string(year(today)).

    find last lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
    tiin-od = trunc(abs((itog-perc + itog-od) - (round(itog-perc + itog-od, 0))) * 100, 0).
    tiin-perc = trunc(abs((itog-perc) - (round(itog-perc, 0))) * 100, 0).
    run Sm-vrd(itog-perc + itog-od, output ru-odsum).
    run Sm-vrd-KZ(itog-perc + itog-od, lon.crc, output kz-odsum).
    run Sm-vrd-KZ(itog-od, lon.crc, output kz-od1).
    run Sm-vrd(itog-od, output ru-od1).
    run Sm-vrd(itog-perc, output ru-percsum).
    run Sm-vrd-KZ(itog-perc, lon.crc, output kz-percsum).
    run Sm-vrd(payment1, output ru-pay1).
    run Sm-vrd-KZ(payment1, lon.crc, output kz-pay1).
    run Sm-vrd(payment2, output ru-pay2).
    run Sm-vrd-KZ(payment2, lon.crc, output kz-pay2).


    def var lonrdt as char.
    def var dd as char.
    def var mm as char.
    def var yy as char.

    dd = string(day(lon.rdt)).
    if length(dd) = 1 then dd = '0' + dd.
    mm = string(month(lon.rdt)).
    if length(mm) = 1 then mm = '0' + mm.
    yy = string(year(lon.rdt)).
   lonrdt = dd + '.' + mm + '.' + yy.

   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*n-dogovor*" then do:
              v-str = replace (v-str, "n-dogovor", loncon.lcnt).
              next.
           end.
           if v-str matches "*regdate*" then do:
              v-str = replace (v-str, "regdate", v-datastrru).
              next.
           end.
           if v-str matches "*kz-rdate*" then do:
              v-str = replace (v-str, "kz-rdate", v-datastrkz).
              next.
           end.
           if v-str matches "*zayavka*" then do:
              v-str = replace (v-str, "zayavka", num).
              next.
           end.
           if v-str matches "*overdate*" then do:
              v-str = replace (v-str, "overdate", lonrdt  ). /*dt2*/
              next.
           end.
           if v-str matches "*overperc*" then do:
              v-str = replace (v-str, "overperc", sum-space(trunc(itog-perc + itog-od,0)) + "," + tiin(itog-perc + itog-od)).
              next.
           end.
           if v-str matches "*percent*" then do:
              v-str = replace (v-str, "percent", sum-space(trunc(itog-perc,0)) + "," + tiin(itog-perc)).
              next.
           end.
           if v-str matches "*overdraft*" then do:
              v-str = replace (v-str, "overdraft", sum-space(trunc(itog-od,0)) + "," + tiin(itog-od)).
              next.
           end.
           if v-str matches "*rupref*" then do:
              v-str = replace (v-str, "rupref", cif.prefix).
              next.
           end.
           if v-str matches "*kzpref*" then do:
              v-str = replace (v-str, "kzpref", v-pref).
              next.
           end.
           if v-str matches "*cifname*" then do:
              v-str = replace (v-str, "cifname", cif.name).
              next.
           end.
           if v-str matches "*perc-dateru*" then do:
              v-str = replace (v-str, "perc-dateru", v-datapercru).
              next.
           end.
           if v-str matches "*perc-datekz*" then do:
              v-str = replace (v-str, "perc-datekz", v-dataperckz).
              next.
           end.
           if v-str matches "*od-dateru*" then do:
              v-str = replace (v-str, "od-dateru", v-dataodru).
              next.
           end.
           if v-str matches "*od-datekz*" then do:
              v-str = replace (v-str, "od-datekz", v-dataodkz).
              next.
           end.
           if v-str matches "*ru-percsum*" then do:
              v-str = replace (v-str, "ru-percsum", ru-percsum + ' тенге ' + tiin(itog-perc) + ' тиын').
              next.
           end.
           if v-str matches "*kz-percsum*" then do:
              v-str = replace (v-str, "kz-percsum", kz-percsum).
              next.
           end.
           if v-str matches "*tiin-perc*" then do:
              v-str = replace (v-str, "tiin-perc", string(tiin-perc)).
              next.
           end.
           if v-str matches "*tiin-od*" then do:
              v-str = replace (v-str, "tiin-od", string(tiin-od)).
              next.
           end.
           if v-str matches "*ru-odsum*" then do:
              v-str = replace (v-str, "ru-odsum", ru-odsum + ' тенге ' + tiin(itog-perc + itog-od) + ' тиын').
              next.
           end.
           if v-str matches "*kz-odsum*" then do:
              v-str = replace (v-str, "kz-odsum", kz-odsum).
              next.
           end.


           if v-str matches "*payment1*" then do:
              v-str = replace (v-str, "payment1", sum-space(trunc(payment1,0)) + "," + tiin(payment1)).
              next.
           end.
           if v-str matches "*payment2*" then do:
              v-str = replace (v-str, "payment2", sum-space(trunc(payment2,0)) + "," + tiin(payment2)).
              next.
           end.
           if v-str matches "*tiin-pay1*" then do:
              v-str = replace (v-str, "tiin-pay1", tiin(payment1)).
              next.
           end.
           if v-str matches "*tiin-pay2*" then do:
              v-str = replace (v-str, "tiin-pay2", tiin(payment2)).
              next.
           end.
           if v-str matches "*ru-pay1*" then do:
              v-str = replace (v-str, "ru-pay1", ru-pay1).
              next.
           end.
           if v-str matches "*kz-pay1*" then do:
              v-str = replace (v-str, "kz-pay1", kz-pay1).
              next.
           end.
           if v-str matches "*ru-pay2*" then do:
              v-str = replace (v-str, "ru-pay2", ru-pay2).
              next.
           end.
           if v-str matches "*kz-pay2*" then do:
              v-str = replace (v-str, "kz-pay2", kz-pay2).
              next.
           end.
           if v-str matches "*kz-od1*" then do:
              v-str = replace (v-str, "kz-od1", kz-od1).
              next.
           end.

           if v-str matches "*ru-od1*" then do:
              v-str = replace (v-str, "ru-od1", ru-od1 + ' тенге ' + tiin(itog-od) + ' тиын').
              next.
           end.

           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.
   unix silent cptwin value(v-ofile) winword.
end procedure.

