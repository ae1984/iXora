/* inkclose.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оплата инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        При закрытии опердня
 * AUTHOR
         dpuchkov
 * CHANGES
         02.09.05 dpuchkov обрабатываем с частичной оплатой затем неоплаченые
         05.12.05 dpuchkov вынес обработку в отдельную i-ку
         17.11.2008 alex - инкассовые, статус 03
         10/12/2008 alex - принятие отзывов до 18:00
         22.05.2009 galina - изменила и пополнила порядок КНП для погашения налоговых ИР согласно СЗ от ОД от 22/05/09
         27.05.2009 galina - перебор по КНП до конца списка
         29.05.2009 galina - убрала сортировку по времени и счету aas и указала новый индекс aaardt
         10.06.2009 galina - добавила поле vo в таблице t-inc
         20/10/2009 galina - не формируем платеж автоматически, если есть приоставление кроме платежей в бюджет и СО одновременно
         08/12/2009 galina - меняем статус wait на accept для РПРО и отзывов РПРО
         01/04/2011 madiyar - перекомпиляция
         06/06/2011 evseev - переход на ИИН/БИН
         20/06/2011 evseev - изменение в inkclose.i
         23/06/2011 evseev - изменение в inkclose.i
         24/06/2011 evseev - изменение в inkclose.i
         27/06/2011 evseev - изменение в inkclose.i
         24/10/2011 evseev - изменение в inkclose.i
         02/11/2011 evseev - изменение в inkclose.i
         11/01/2012 evseev - изменил порядок КНП для погашения налоговых ИР согласно СЗ от ОД от 10/01/12
         15.06.2012 evseev - ТЗ-1397. изменение в i-шке
         17.09.2012 evseev - ТЗ-1445
         08.02.2013 evseev - tz-1710
         31/07/2013 galina - ТЗ 1994 добавила логирование при смене статуса с wait на accept

*/
{global.i}
{comm-txb.i}
{get-dep.i}
{chbin.i}

def var ourcode as integer.
def var vparam2 as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".
def var v-jh like jh.jh.
def var d-SumOfPlat as decimal init 0.
def var d-tmpSum as decimal init 0.
def var op_kod AS CHAR format "x(1)".
def var v-usrglacc as char.
def new shared var s-rmzir as char.
def var d_sum as decimal.
def var s-vcourbank as char.
def var d_arsum as decimal decimals 2.
def var d_arsummy as decimal decimals 2.
def var v-opl as char.
def var v-ax1 as integer init 0.
  def buffer bv-aaa for aaa.
  def buffer bv-aas for aas.
  def buffer b-ink for inc100.
def var v_sec as char.
def var r-cover as integer.
def var v-dt1 as date.


ourcode = comm-cod().
d_sum = 0.

/* инкассовые, статус 03 */
def new shared temp-table t-inc no-undo
    field jss like inc100.jss
    field iik like inc100.iik
    field crc like inc100.crc
    field sum like inc100.sum
    field num like inc100.num
    field ref like inc100.ref
    field stat2 like inc100.stat2
    field vo like inc100.vo
    field bin like inc100.bin.
/* инкассовые, статус 03 */

def buffer b-inc100 for inc100.
def buffer b2-inc100 for inc100.



/*проверка на оплату только 1 раз в  день*/

do transaction:
    find sysc where sysc.sysc= "INKS" exclusive-lock no-error.
    if avail sysc then do:
       if g-today = date(sysc.chval) then return.
       else sysc.chval = string(g-today).
    end.
end.

run savelog("inkclose", '------- Старт------').

for each aaar where aaar.a4 <> "1"  exclusive-lock:
    find first remtrz where remtrz.remtrz = aaar.a1 no-lock no-error.
    if avail remtrz then do:
       find first que of remtrz no-lock no-error.
       if avail remtrz and avail que then do:
          if que.pid = "F"   then aaar.a4 = "1".
          if que.pid = "ARC" then aaar.a4 = "1".
       end.
    end.
    else delete aaar.
end.


def new shared var s_l_inkopl as logical init false.  /* переменная оплаты ИР */
define temp-table tmp-aaa like aaa field sm as decimal.


s-vcourbank = comm-txb().
for each tmp-aaa:
    delete tmp-aaa.
end.

/* fsum - первоначал  */
/* docprim - остаточн */
def var fname1 as char.
def var t-sum as decimal.

fname1 = "inkpay" + substring(string(g-today), 1, 2) + substring(string(g-today), 4, 2) + ".txt".

def stream m-out.
output stream m-out to inkpay.txt.

def buffer taas1 for aas.
def buffer b-blkaas for aas.
def buffer oldaas for aas.
def buffer baas4 for aas.
def var l_afnd as logical init False.

def var d-acctmp as decimal.
def var v-acctmp as char.
def var olds     as decimal.
def var v-exist1 as char no-undo.
def var v-exist2 as char no-undo.
def temp-table t-iaccs
    field  icif like aaa.cif
    field  iaaa like aaa.aaa
    field  fsum like aas.fsum
    field  docdat like aas.docdat
    field  knp like aas.knp
    field  kbk like aas.kbk
    field  fnum like aas.fnum.

def var v-mt100in as char no-undo.
def var v-mt998in as char no-undo.


run savelog("inkclose", " Старт смена статуса wait на accept ИР" ).
do transaction:
    find first inc100 where (inc100.mnu eq "wait") and (inc100.stat eq 0) and (inc100.bank = s-vcourbank) no-lock no-error.
    if avail inc100 then do:

        v-mt100in = "/data/import/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
        input through value( "find " + v-mt100in + ";echo $?").
        repeat:
            import unformatted v-exist1.
        end.

        if v-exist1 <> "0" then do:
            unix silent value ("mkdir " + v-mt100in).
            unix silent value("chmod 777 " + v-mt100in).
        end.

        for each inc100 where (inc100.mnu eq "wait") and (inc100.stat eq 0) and (inc100.bank = s-vcourbank) exclusive-lock:
            unix silent value("mv /data/import/inkarc/" + string(year(inc100.rdt),"9999") + string(month(inc100.rdt),"99") + string(day(inc100.rdt),"99") + "/" + inc100.filename + " " + v-mt100in).
            assign inc100.mnu = "accept"
                   inc100.rdt = g-today
                   inc100.rtm = time.
            run savelog("inkclose", " Смена статуса wait на accept ИР " + inc100.ref).
        end.
    end.
end.
run savelog("inkclose", " Конец смена статуса wait на accept ИР" ).

run savelog("inkclose", " Старт смена статуса wait на accept РПРО" ).
do transaction:
    find first insin where (insin.mnu eq "wait") and (insin.stat eq 0) and (insin.bank = s-vcourbank) no-lock no-error.
    if avail insin then do:

        v-mt998in = "/data/import/insarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
        input through value( "find " + v-mt998in + ";echo $?").
        repeat:
            import unformatted v-exist2.
        end.

        if v-exist2 <> "0" then do:
            unix silent value ("mkdir " + v-mt998in).
            unix silent value("chmod 777 " + v-mt998in).
        end.

        for each insin where (insin.mnu eq "wait") and (insin.stat eq 0) and (insin.bank = s-vcourbank) exclusive-lock:
            unix silent value("mv /data/import/insarc/" + string(year(insin.rdt),"9999") + string(month(insin.rdt),"99") + string(day(insin.rdt),"99") + "/" + insin.filename + " " + v-mt998in).
            assign insin.mnu = "accept"
                   insin.rdt = g-today
                   insin.rtm = time.
            run savelog("inkclose", " Смена статуса wait на accept РПРО " + insin.ref).
        end.
    end.
end.
run savelog("inkclose", " Конец смена статуса wait на accept РПРО" ).


run savelog("inkclose", " Старт смена статуса wait на accept отзыв ИР" ).
do transaction:
    find first inkor1 where inkor1.stat eq "wait" no-lock no-error.
    if avail inkor1 then do:
        v-mt100in = "/data/import/inkarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
        input through value( "find " + v-mt100in + ";echo $?").
        repeat:
            import unformatted v-exist1.
        end.

        if v-exist1 <> "0" then do:
            unix silent value ("mkdir " + v-mt100in).
            unix silent value("chmod 777 " + v-mt100in).
        end.

        for each inkor1 where inkor1.stat eq "wait" exclusive-lock:
            unix silent value("mv /data/import/inkarc/" + string(year(inkor1.rdt), "9999") + string(month(inkor1.rdt), "99") + string(day(inkor1.rdt), "99") + "/" + inkor1.filename + " " + v-mt100in).
            assign inkor1.stat = ""
                   inkor1.rdt = g-today
                   inkor1.rtm = time.
            run savelog("inkclose", " Смена статуса wait на accept отзыв ИР " + inkor1.ref ).
        end.
    end.
end.
run savelog("inkclose", " Конец смена статуса wait на accept отзыв ИР" ).

run savelog("inkclose", " Старт смена статуса wait на accept отзыв РПРО" ).
do transaction:
    find first insrec where insrec.stat eq "wait" no-lock no-error.
    if avail insrec then do:
        v-mt998in = "/data/import/insarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
        input through value( "find " + v-mt998in + ";echo $?").
        repeat:
            import unformatted v-exist2.
        end.

        if v-exist2 <> "0" then do:
            unix silent value ("mkdir " + v-mt998in).
            unix silent value("chmod 777 " + v-mt998in).
        end.

        for each insrec where insrec.stat eq "wait"exclusive-lock:
            unix silent value("mv /data/import/insarc/" + string(year(insrec.rdt), "9999") + string(month(insrec.rdt), "99") + string(day(insrec.rdt), "99") + "/" + insrec.filename + " " + v-mt998in).
            assign insrec.stat = ""
                   insrec.rdt = g-today
                   insrec.rtm = time.
            run savelog("inkclose", " Смена статуса wait на accept отзыв ИР " + insrec.ref ).
        end.
    end.
end.
run savelog("inkclose", " Конец смена статуса wait на accept отзыв РПРО" ).

do:
    def var vs-knpall as char.
    def var vs-knp as char.
    def var i-knpind as integer.
    /* КНП порядок установлен согл служебки от 01.12.05 */
    /* vs-knpall = "912,922,932,942,952,962,911,921,931,941,951,961,914,924,934,944,954,964,913,923,933,943,953,963" .*/
    /* КНП порядок установлен согл служебки от 22.05.2009 */
    /*vs-knpall = "911,914,917,921,924,927,931,934,937,941,944,947,951,954,957,961,964,967,978,979,981,984,987,991,994,912,915,918,922,925,928,932,935,938,942,945,948,952,955,958,962,965,968,982,985,988,992,913,916,923,926,929,933,936,939,943,946,949,953,956,959,963,966,969,983,986,989,993,995".*/


    /*vs-knpall = "912,915,918,922,925,928,932,935,938,942,945,948,952,955,958,965,966,967,968,982,985,988,992,911,914,917,921,924,927,931,934,937,941,944,947,951,954,957,961,981,984,987,991,994,913,916,919,923,926,929,933,936,939,943,946,949,953,956,959,983,986,989,993,995".*/

    vs-knpall = "911,914,917,921,961,981,984,987,991,994,912,915,918,922,923,924,965,966,967,968,982,985,988,992,913,916,919,978,986,989,993,995".

    do i-knpind = 1 to num-entries(vs-knpall):
       vs-knp = ENTRY(i-knpind, vs-knpall).
       {inkknp.i}
    end.


    /* частично */
    for each aas where aas.ln <> 7777777 and (aas.sta = 4 or aas.sta = 5 or aas.sta = 8) use-index aaardt exclusive-lock:
        if lookup(string(aas.knp), vs-knpall) <> 0 then next.
        if substr(aas.knp,1,1) <> "9" then next.
        if length(aas.knp) <> 3 then next.

        find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 1 no-lock no-error.
        if avail b-blkaas then next.

          find last b-blkaas where b-blkaas.aaa = aas.aaa and lookup(string(b-blkaas.sta), "11,16,17") <> 0 no-lock no-error.
          if avail b-blkaas then do:
             find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 2 no-lock no-error.
             if avail b-blkaas then do:
                next.
             end.
          end.


        if aas.fsum > decimal(aas.docprim)  then do:
           {inkclose.i}
        end.
    end.

    /* не оплачено */
    for each aas where aas.ln <> 7777777 and (aas.sta = 4 or aas.sta = 5 or aas.sta = 8) use-index aaardt exclusive-lock:
        if lookup(string(aas.knp), vs-knpall) <> 0 then next.
        if substr(aas.knp, 1, 1) <> "9" then next.
        if length(aas.knp) <> 3 then next.
        find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 1 no-lock no-error.
        if avail b-blkaas then next.


          find last b-blkaas where b-blkaas.aaa = aas.aaa and lookup(string(b-blkaas.sta), "11,16,17") <> 0 no-lock no-error.
          if avail b-blkaas then do:
             find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 2 no-lock no-error.
             if avail b-blkaas then next.
          end.


        if aas.fsum = decimal(aas.docprim) then do:
           {inkclose.i}
        end.
    end.
end.

/*Обработка инкассовых, поступивших только на валютные счета*/

for each inc100 where (inc100.mnu eq "blk") and (inc100.stat eq 1) and (inc100.bank eq s-vcourbank) no-lock:
    find aaa where aaa.aaa eq inc100.iik no-lock no-error.
    if (not avail aaa) or (aaa.crc eq 1) then next.

    do transaction:
        find first b-ink where b-ink.ref eq inc100.ref exclusive-lock no-error.
        if avail b-ink then do:
            assign b-ink.stat2 = "03" b-ink.mnu = "K2_sent".
            find current b-ink no-lock.
        end.
        create t-inc.
        assign t-inc.jss = inc100.jss
            t-inc.iik = inc100.iik
            t-inc.crc = inc100.crc
            t-inc.sum = inc100.sum
            t-inc.num = inc100.num
            t-inc.ref = inc100.ref
            t-inc.stat2 = inc100.stat2
            t-inc.vo = inc100.vo
            t-inc.bin = inc100.bin.
    end. /* transaction */
end.

/*Обработка инкассовых, поступивших только на валютные счета*/
/*налоговые*/
find first t-inc where t-inc.vo <> '07' and t-inc.vo <> '09' no-lock no-error.
if avail t-inc then run inkst03.

/*ОПВ и СО*/
find first t-inc where t-inc.vo = '07' no-lock no-error.
if avail t-inc then run 102st03('07').

find first t-inc where t-inc.vo = '09' no-lock no-error.
if avail t-inc then run 102st03('09').

output stream m-out close.
unix silent mv inkpay.txt value(fname1).

