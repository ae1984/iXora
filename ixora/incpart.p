/* incpart.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Отчет по частичной оплате ИР
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
        14/05/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
       07.07.2009 galina - добавила столбец вид операции
       20/06/2011 evseev - изменение в inkstat.i
       28.05.2012 evseev - добавил поле референс
*/

{global.i}
def input parameter consld as logi no-undo.

def var dt1   as date no-undo.
def var dt2   as date no-undo.
def var v-txb as char no-undo.
def var v-grp as char no-undo.
def var v-acc as char no-undo.

{inkstat.i}

def new shared temp-table wrk no-undo
  field ref like inc100.ref
  field num like inc100.num
  field clname like inc100.name
  field iik like inc100.iik
  field sum like inc100.sum
  field ost as deci
  field stat like inc100.stat
  field rdt like inc100.rdt
  field rtm like inc100.rtm
  field mnu like inc100.mnu
  field bank as char
  field bankname as char
  field dtpay as date
  field sumpay as deci
  field vo as char
  index idx is primary bank num.

def var s-vcourbank as char no-undo.
def var v-bankname as char no-undo.
form dt1 label ' Укажите период с' format '99/99/9999'
    dt2 label ' по' format '99/99/9999' skip(1)
    v-grp label ' Подразделение...' format 'x(20)' skip(1)
    v-acc label ' Номер счета.....' format 'x(20)'
with side-label row 5 width 48 centered frame dat.

on help of v-grp in frame dat do:
    {itemlist.i
        &file = "txb"
        &frame = "row 6 width 25 centered 18 down overlay "
        &where = " txb.consolid = true "
        &flddisp = " txb.info label 'Подразделение' format 'x(23)' "
        &chkey = "info"
        &chtype = "string"
        &index  = "txb"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-grp = txb.info.
    v-txb = txb.bank.
    displ v-grp with frame dat.
end.

dt2 = g-today.
dt1 = date(month(dt2), 1, year(dt2)).

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-vcourbank = trim(sysc.chval).

if consld then do:
    update dt1 dt2 with frame dat.
    v-txb = "".
end.
else do:
    v-txb = s-vcourbank.
    find first txb where txb.bank eq s-vcourbank no-lock no-error.
    if avail txb then v-grp = txb.info.
    if s-vcourbank = "TXB00" then update dt1 dt2 v-grp v-acc with frame dat.
    else do:
        displ v-grp with frame dat.
        update dt1 dt2 v-acc with frame dat.
    end.
end.

hide frame dat.

v-acc = trim(v-acc).
v-txb = trim(v-txb).

if ((dt1 = ?) or (dt2 = ?)) and v-txb = "" and v-acc = "" then do:
    message "Не введён ни один параметр для поиска!" view-as alert-box.
    return.
end.

if v-txb = s-vcourbank then do:

    find first comm.txb where comm.txb.bank = s-vcourbank no-lock no-error.
    if avail comm.txb then v-bankname = trim(txb.info).
    else v-bankname = s-vcourbank.
    if ((dt1 = ?) or (dt2 = ?)) and v-acc = "" then do:
        for each inc100 where inc100.bank = v-txb no-lock:
            run report.
        end.
    end.

    if ((dt1 = ?) or (dt2 = ?)) and v-acc <> "" then do:
        for each inc100 where inc100.bank = v-txb and inc100.iik = v-acc no-lock:
            run report.
        end.
    end.

    if dt1 <> ? and dt2 <> ? and v-acc = "" then do:
        for each inc100 where inc100.bank = v-txb and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
            run report.
        end.
    end.

    if dt1 <> ? and dt2 <> ? and v-acc <> "" then do:
        for each inc100 where inc100.bank = v-txb and inc100.iik = v-acc and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
            run report.
        end.
    end.
end.
else do:
    for each comm.txb where comm.txb.consolid and (if v-txb = '' then true else comm.txb.bank = v-txb) no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run incpart2(dt1,dt2,v-acc).
    end.
    if connected ("txb") then disconnect "txb".
end.

def stream hrep.
output stream hrep to increport.html.

put stream hrep unformatted
    "<html>" skip
    "<head>" skip
    "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
    "<title>Отчет по полученным инкассовым распоряжениям</title>" skip
    "<style type= text/css>" skip
    "TABLE \{ border-collapse: collapse; \}" skip
    "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
    "<tr align= center>" skip
    "<td colspan= 9>Дата формирования отчета " + string(today, "99/99/99") + "</td>" skip
    "</tr>" skip
    "<tr style= font:bold; font-size:xx-small bgcolor= #C0C0C0 align= center>" skip
        "<td>Референс</td>" skip
        "<td width= 10%>Дата и время получения ИР</td>" skip
        "<td width= 5%>N ИР</td>" skip
        "<td width= 15%>Наименование плательщика</td>" skip
        "<td width= 10%>Счет плательщика</td>" skip
        "<td width= 10%>Сумма ИР</td>" skip
        "<td width= 10%>Вид операции</td>" skip
        /*
        "<td width= 10%>Первоначальный статус ИР</td>" skip
        "<td width= 10%>Время и дата отправки первого сообщения в НК</td>" skip
        "<td width= 10%>Статус ИР на дату формирования отчета</td>" skip
        "<td width= 10%>Время и дата отправки последующего сообщения</td>" skip
        */
        "<td width= 10%>Подразделение</td>" skip
        "<td width= 10%>Дата част. платежа</td>" skip
        "<td width= 10%>Сумма част. платежа</td>" skip
        "<td width= 10%>Остаток ИР</td>" skip
        "<td width= 10%>Подпись уполн. лиц</td>" skip
    "</tr>" skip.

for each wrk no-lock:
    put stream hrep unformatted
        "<tr align= right>" skip
            "<td>'" + wrk.ref + "</td>" skip
            "<td>" + string(wrk.rdt, "99/99/9999") + " " + string(wrk.rtm, "hh:mm") + "</td>" skip
            "<td>" + string(wrk.num) + "</td>" skip
            "<td>" + string(wrk.clname) + "</td>" skip
            "<td>" + string(wrk.iik, "999999999") + "</td>" skip
            "<td>" + string(wrk.sum, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip

            "<td>" + wrk.vo + "</td>" skip
            /*"<td>" + string(wrk.rdt, "99/99/9999") + "</td>" skip
            "<td>" + entry(lookup(wrk.mnu, v-stat, "|"), v-stat2, "|") + "</td>" skip
            "<td>&nbsp;</td>" skip
            */
            "<td>" + wrk.bankname + "</td>" skip
            "<td>" + string(wrk.dtpay, "99/99/9999") + "</td>" skip
            "<td>" + string(wrk.sumpay, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip
            "<td>" + string(wrk.ost, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip
            "<td>&nbsp;</td>" skip
        "</tr>" skip.
end.

put stream hrep unformatted "</table></body></html>".
output stream hrep close.
unix silent cptwin increport.html iexplore.


procedure report.
    def var run1 as logi no-undo init yes.
    def var v-ost as deci no-undo init 0.
    find first aas where aas.aaa = inc100.iik and aas.fnum = string(inc100.num) no-lock no-error.
    if avail aas then v-ost = deci(aas.docprim).
    for each aaar where aaar.a5 = inc100.iik and aaar.a4 = '1' and aaar.a2 = string(inc100.num) no-lock:
        if run1 then do:
            if deci(aaar.a3) < inc100.sum then do:
                create wrk.
                assign wrk.ref = inc100.ref
                       wrk.num = inc100.num
                       wrk.clname = inc100.name
                       wrk.iik = inc100.iik
                       wrk.sum = inc100.sum
                       wrk.ost = v-ost
                       wrk.stat = inc100.stat
                       wrk.rdt = inc100.rdt
                       wrk.rtm = inc100.rtm
                       wrk.mnu = inc100.mnu
                       wrk.bank = s-vcourbank
                       wrk.bankname = v-bankname
                       wrk.dtpay = date(aaar.a6)
                       wrk.sumpay = deci(aaar.a3).
            end.
            else leave.
            run1 = no.
        end. /* if run1 */
        else do:
            create wrk.
            assign wrk.ref = inc100.ref
                   wrk.num = inc100.num
                   wrk.clname = inc100.name
                   wrk.iik = inc100.iik
                   wrk.sum = inc100.sum
                   wrk.ost = v-ost
                   wrk.stat = inc100.stat
                   wrk.rdt = inc100.rdt
                   wrk.rtm = inc100.rtm
                   wrk.mnu = inc100.mnu
                   wrk.bank = s-vcourbank
                   wrk.bankname = v-bankname
                   wrk.dtpay = date(aaar.a6)
                   wrk.sumpay = deci(aaar.a3).
        end.
        if lookup(inc100.vo, v-vo, "|") <> 0  then wrk.vo = inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|").
    end. /* for each aaar */
end.

