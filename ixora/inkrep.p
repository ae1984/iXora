/* inkrep.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Отчет по ИР
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
        --/--/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        14/05/2009 madiyar - вынес справочник статусов в i-шку; изменил запросы
        07.07.2009 galina - добавила столбец вид операции
        08.06.10 - переход на iban
        21/01/2011 evseev - перекомпилил из-за изменения inkstat.i
        20/06/2011 evseev - изменение в inkstat.i
        28.05.2012 evseev - добавил поле референс
*/

{global.i}
def input parameter consld as logi.

def var dt1     as date.
def var dt2     as date.
def var v-txb   as char.
def var v-grp   as char.
def var v-acc   as char.

{inkstat.i}

def var s-vcourbank as char.

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

dt2 = today.
dt1 = date(month(dt2), 1, year(dt2)).

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

if consld then do:
    update dt1 dt2 with frame dat.
    v-txb = "".
end.
else do:
    s-vcourbank = trim(sysc.chval).
    v-txb = s-vcourbank.

    find first txb where txb.bank eq s-vcourbank.
    if avail txb then v-grp = txb.info.
    if s-vcourbank = "TXB00" then update dt1 dt2 v-grp v-acc with frame dat.
    else do:
        displ v-grp with frame dat.
        update dt1 dt2 v-acc with frame dat.
    end.
end.

hide frame dat.

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
            "<td>N ИР</td>" skip
            "<td width= 15%>Наименование плательщика</td>" skip
            "<td width= 10%>Счет плательщика</td>" skip
            "<td width= 10%>Сумма ИР</td>" skip
            "<td width= 10%>Первоначальный статус ИР</td>" skip
            "<td width= 10%>Вид операции</td>" skip
            "<td width= 10%>Время и дата отправки первого сообщения в НК</td>" skip
            "<td width= 10%>Статус ИР на дату формирования отчета</td>" skip
            "<td width= 10%>Время и дата отправки последующего сообщения</td>" skip
            "<td width= 5%>Подразделение</td>" skip
        "</tr>" skip.

if ((dt1 = ?) or (dt2 = ?)) and v-txb = "" and v-acc = "" then do:
    message "Не введён ни один параметр для поиска!" view-as alert-box.
    return.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb = "" and v-acc <> "" then do:
    for each inc100 where inc100.iik = v-acc no-lock:
        run report.
    end.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb <> "" and v-acc = "" then do:
    for each inc100 where inc100.bank = v-txb no-lock:
        run report.
    end.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb <> "" and v-acc <> "" then do:
    for each inc100 where inc100.bank = v-txb and inc100.iik = v-acc no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb = "" and v-acc = "" then do:
    for each inc100 where inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb = "" and v-acc <> "" then do:
    for each inc100 where inc100.iik = v-acc and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb <> "" and v-acc = "" then do:
    for each inc100 where inc100.bank = v-txb and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb <> "" and v-acc <> "" then do:
    for each inc100 where inc100.iik = v-acc and inc100.bank = v-txb and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

procedure report.
    put stream hrep unformatted
        "<tr align= right>" skip
            "<td>'" + inc100.ref + "</td>" skip
            "<td>" + string(inc100.rdt, "99/99/9999") + " " + string(inc100.rtm, "hh:mm") + "</td>" skip
            "<td>" + string(inc100.num) + "</td>" skip
            "<td>" + string(inc100.name) + "</td>" skip
            "<td>" + string(inc100.iik, "x(20)") + "</td>" skip
            "<td>" + string(inc100.sum, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip
            "<td>" + entry(lookup(string(inc100.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip.
            if lookup(inc100.vo, v-vo, "|") <> 0  then
            put stream hrep unformatted "<td>"  inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|") "</td>" skip.
            else put stream hrep unformatted "<td></td>" skip.
            put stream hrep unformatted
            "<td>" + string(inc100.rdt, "99/99/9999") + "</td>" skip
            "<td>" + entry(lookup(inc100.mnu, v-stat, "|"), v-stat2, "|") + "</td>" skip
            "<td>&nbsp;</td>" skip.
            find first txb where txb.bank eq inc100.bank no-lock no-error.
            if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
            else put stream hrep unformatted "<td>" + inc100.bank + "</td>" skip.

   put stream hrep unformatted "</tr>" skip.
end.

put stream hrep unformatted "</table></body></html>".
output stream hrep close.
unix silent cptwin increport.html iexplore.