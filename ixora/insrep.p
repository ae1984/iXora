/* insrep.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по РПРО
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        21/01/2011 evseev - перекомпилил из-за изменения inkstat.i
        12/05/2011 evseev - отбор на основании поля не bank, а bank1
        20/06/2011 evseev - изменение в inkstat.i
        28.05.2012 evseev - добавил поле референс
        03.07.2013 yerganat - tz1889, добавление вывода наименования клиента
*/

{global.i}
def input parameter consld as logi.

def var dt1     as date.
def var dt2     as date.
def var v-txb   as char.
def var v-grp   as char.
def var v-acc   as char.
def var v-instype as char.

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
output stream hrep to insreport.html.

put stream hrep unformatted
    "<html>" skip
    "<head>" skip
        "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
        "<title>Отчет по полученным распоряжениям о приостановлении расходных операций</title>" skip
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
            "<td width= 10%>Дата и время получения распоряжения о приостановлении РО</td>" skip
            "<td>N распоряжения о приостановлении РО</td>" skip
            "<td>Тип распоряжения</td>" skip
            "<td >Наименование клиента</td>" skip
            "<td>Счета налогоплательщика</td>" skip
            "<td>Заблокированные счета</td>" skip
            "<td>Закрытые счета</td>" skip
            "<td>Не найденные счета</td>" skip
            "<td>Первоначальный статус распоряжения с расшифровкой значения статуса</td>" skip
            "<td>Время и дата отправки первого сообщения в НК</td>" skip
            "<td>Статус распоряжения на дату формирования отчета</td>" skip
            "<td>Время и дата отправки последующего сообщения</td>" skip
            "<td>Подразделение</td>" skip
        "</tr>" skip.

if ((dt1 = ?) or (dt2 = ?)) and v-txb = "" and v-acc = "" then do:
    message "Не введён ни один параметр для поиска!" view-as alert-box.
    return.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb = "" and v-acc <> "" then do:
    for each insin where lookup(v-acc,insin.iik) > 0 no-lock:
        run report.
    end.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb <> "" and v-acc = "" then do:
    for each insin where /*insin.bank = v-txb*/ lookup(v-txb,insin.bank1) > 0 no-lock:
        run report.
    end.
end.

if ((dt1 = ?) or (dt2 = ?)) and v-txb <> "" and v-acc <> "" then do:
    for each insin where /*insin.bank = v-txb*/ lookup(v-txb,insin.bank1) > 0 and lookup(v-acc,insin.iik) > 0 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb = "" and v-acc = "" then do:
    for each insin where insin.rdt >= dt1 and insin.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb = "" and v-acc <> "" then do:
    for each insin where lookup(v-acc,insin.iik) > 0 and insin.rdt >= dt1 and insin.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb <> "" and v-acc = "" then do:
    for each insin where /*insin.bank = v-txb*/ lookup(v-txb,insin.bank1) > 0 and insin.rdt >= dt1 and insin.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and v-txb <> "" and v-acc <> "" then do:
    for each insin where lookup(v-acc,insin.iik) > 0 and /*insin.bank = v-txb*/ lookup(v-txb,insin.bank1) > 0 and insin.rdt >= dt1 and insin.rdt <= dt2 no-lock:
        run report.
    end.
end.

procedure report.
    v-instype = ''.
    case insin.type:
      when 'AC' then v-instype = 'Распоряжение о налогоплательщике'.
      when 'ACP' then v-instype = 'Распоряжение об агенте ОПВ'.
      when 'ASD' then v-instype = 'Распоряжение о плательщике СО'.
    end.
    put stream hrep unformatted
        "<tr align= right>" skip
            "<td>'" + insin.ref + "</td>" skip
            "<td>" + string(insin.rdt, "99/99/9999") + " " + string(insin.rtm, "hh:mm") + "</td>" skip
            "<td>" + insin.numr + "</td>" skip
            "<td>" + v-instype + "</td>" skip
            "<td>" + insin.clname + "</td>" skip
            "<td>" + insin.iik + "</td>" skip
            "<td>" + insin.blkaaa + "</td>" skip
            "<td>" + insin.clsaaa + "</td>" skip
            "<td>" + insin.erraaa + "</td>" skip
            "<td>" string(insin.stat,'99') + " " + entry(lookup(string(insin.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip.
            find first inshist where inshist.insref = insin.ref and inshist.outfile begins "INS" no-lock no-error.
            if avail inshist then put stream hrep unformatted
            "<td>" + string(insin.rdt, "99/99/9999") +  " " + string(inshist.rtm, "hh:mm") + "</td>" skip.
            else put stream hrep unformatted "<td></td>" skip.
            put stream hrep unformatted "<td>" + entry(lookup(insin.mnu, v-stat, "|"), v-stat2, "|") + "</td>" skip.
            if insin.mnu = 'returned' then do:
               find last inshist where inshist.insref = insin.ref and inshist.outfile begins "INS" no-lock no-error.
               if avail inshist then put stream hrep unformatted
               "<td>" + string(insin.rdt, "99/99/9999") +  " " + string(inshist.rtm, "hh:mm") + "</td>" skip.
               else put stream hrep unformatted "<td></td>" skip.
            end.
            else put stream hrep unformatted "<td></td>" skip.
            find first txb where txb.bank eq insin.bank no-lock no-error.
            if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
            else put stream hrep unformatted "<td>" + insin.bank + "</td>" skip.
   put stream hrep unformatted "</tr>" skip.
end.

put stream hrep unformatted "</table></body></html>".
output stream hrep close.
unix silent cptwin insreport.html iexplore.