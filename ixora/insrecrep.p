/* insrecrep.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по отзывам РПРО
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
        21/01/2010 galina - добавила филиал
        21/01/2011 evseev - перекомпилил из-за изменения inkstat.i
        25/05/2011 lyubov - добавлен столбец "Наименование клиента", консолидация оставлена только для базы ЦО
        20/06/2011 evseev - изменение в inkstat.i
        28.05.2012 evseev - добавил поле референс
        03.07.2013 yerganat - tz1889,  формирования консолидированного отчета
*/

{global.i}
def input parameter consld as logi.

def var dt1   as date.
def var dt2   as date.
def var v-txb as char.
def var v-grp as char.
def var v-acc as char.
def var v-recsts as char.

{inkstat.i}

def var s-vcourbank as char.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

s-vcourbank = trim(sysc.chval).

if not consld then do:
    s-vcourbank = trim(sysc.chval).
    find first txb where txb.bank eq s-vcourbank.
    if avail txb then v-grp = txb.info.
end.


form dt1 label ' Укажите период с' format '99/99/9999'
     dt2 label ' по' format '99/99/9999' skip(1)
     v-grp label ' Подразделение...' format 'x(20)' skip(1)
with side-label row 5 width 48 centered frame dat.

dt2 = today.
dt1 = date(month(dt2), 1, year(dt2)).

displ v-grp with frame dat.
update dt1 dt2 with frame dat.

hide frame dat.

def stream hrep.
output stream hrep to insreport.html.

put stream hrep unformatted
    "<html>" skip
    "<head>" skip
        "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
        "<title>Отчет по полученным отзывам распоряжений о приостановлении расходных операций.</title>" skip
        "<style type= text/css>" skip
            "TABLE \{ border-collapse: collapse; \}" skip
        "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width = 250% border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
        "<tr align= center>" skip
            "<td colspan= 10>Дата формирования отчета " + string(today, "99/99/99") + "</td>" skip
        "</tr>" skip
        "<tr style= font:bold; font-size:xx-small bgcolor= #C0C0C0 align= center>" skip
            "<td>Референс</td>" skip
            "<td>Дата отзыва и время получения отзыва</td>" skip
            "<td>N отзыва</td>" skip
            "<td>Номер отзываемого распоряжения</td>" skip
            "<td>Наименование клиента</td>" skip
            "<td>ИИК налогоплательщика</td>" skip
            "<td>Первоначальный статус отзыва с расшифровкой значения статуса</td>" skip
            "<td>Время и дата отправки первого сообщения в НК</td>" skip
            "<td>Статус отзыва на дату формирования отчета</td>" skip
            "<td>Подразделение</td>" skip
        "</tr>" skip.


if consld then do:

for each insrec where insrec.rdt >= dt1 and insrec.rdt <= dt2 no-lock:
    if insrec.stat = '' then v-recsts = 'Обрабатывается'.
    if insrec.stat = 'wait' then v-recsts = 'Получено после 18:00'.
    if insrec.stat <> '' and insrec.stat <> 'wait' then v-recsts = 'Принят'.
    find first insin where insin.ref eq insrec.insref no-lock no-error.
    find first inshist where inshist.insref = insrec.ref and inshist.outfile begins "RINS" no-lock no-error.
    put stream hrep unformatted "<tr align= right>" skip
    "<td>'" + insrec.ref + "</td>" skip
    "<td>" + string(insrec.rdt, "99/99/9999") + string(insrec.rtm,'hh:mm:ss') +  "</td>" skip
    "<td>" + insrec.num + "</td>" skip
    "<td>" + insrec.insnum + "</td>" skip
    "<td>" + insrec.name + "</td>" skip
    "<td>" + insin.iik + "</td>" skip
    "<td>" + insrec.stat + " " + entry(lookup(string(insrec.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip
    "<td>" + string(inshis.rdt, "99/99/9999") + string(inshis.rtm,'hh:mm:ss') +  "</td>" skip
    "<td>" + v-recsts + "</td>".
    find first insin where insin.ref = insrec.insref no-lock no-error.
    if avail insin then do:
      find first txb where txb.bank eq insin.bank no-lock no-error.
        if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
        else put stream hrep unformatted "<td></td>" skip.
    end.
    else put stream hrep unformatted "<td></td>" skip.
    put stream hrep unformatted "</tr>" skip.
end.

end.

else do:

for each insin where insin.bank = s-vcourbank no-lock:
    find first insrec where insrec.insref = insin.ref and insrec.rdt >= dt1 and insrec.rdt <= dt2 no-lock no-error.
    if avail insrec then do:
    if insrec.stat = '' then v-recsts = 'Обрабатывается'.
    if insrec.stat = 'wait' then v-recsts = 'Получено после 18:00'.
    if insrec.stat <> '' and insrec.stat <> 'wait' then v-recsts = 'Принят'.
    /* find first insin where insin.ref eq insrec.insref no-lock no-error. */
    find first inshist where inshist.insref = insrec.ref and inshist.outfile begins "RINS" no-lock no-error.
    put stream hrep unformatted "<tr align= right>" skip
    "<td>'" + insrec.ref + "</td>" skip
    "<td>" + string(insrec.rdt, "99/99/9999") + string(insrec.rtm,'hh:mm:ss') +  "</td>" skip
    "<td>" + insrec.num + "</td>" skip
    "<td>" + insrec.insnum + "</td>" skip
    "<td>" + insrec.name + "</td>" skip
    "<td>" + insin.iik + "</td>" skip
    "<td>" + insrec.stat + " " + entry(lookup(string(insrec.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip
    "<td>" + string(inshis.rdt, "99/99/9999") + string(inshis.rtm,'hh:mm:ss') +  "</td>" skip
    "<td>" + v-recsts + "</td>".

   /* find first insin where insin.ref = insrec.insref no-lock no-error.
    if avail insin then do:*/
        find first txb where txb.bank eq insin.bank no-lock no-error.
        if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
        else put stream hrep unformatted "<td></td>" skip.
    /*end.
    else put stream hrep unformatted "<td></td>" skip.*/
    put stream hrep unformatted "</tr>" skip.
end.
end.

end.

put stream hrep unformatted "</table></body></html>".
output stream hrep close.
unix silent cptwin insreport.html iexplore.