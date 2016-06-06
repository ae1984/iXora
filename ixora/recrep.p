/* recrep.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Отчет по отзывам ИР
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
        14/05/2009 madiyar - описание статусов и причин отзывов вынес в общую i-шку
        29/05/2009 galina - выводим корректную дату инкассового распоряжения
        07.07.2009 galina - добавила столбец вид операцииs
        08.06.10 - переход на iban
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
def var v-voch as char.

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
output stream hrep to increport.html.

put stream hrep unformatted
    "<html>" skip
    "<head>" skip
        "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
        "<title>Отчет по полученным отзывам ИР</title>" skip
        "<style type= text/css>" skip
            "TABLE \{ border-collapse: collapse; \}" skip
        "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width= 200% border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
        "<tr align= center>" skip
            "<td colspan= 10>Дата формирования отчета " + string(today, "99/99/99") + "</td>" skip
        "</tr>" skip
        "<tr style= font:bold; font-size:xx-small bgcolor= #C0C0C0 align= center>" skip
            "<td >Референс</td>" skip
            "<td >Дата отзыва</td>" skip
            "<td >N отзыва</td>" skip
            "<td >Номер ИР</td>" skip
            "<td >Наименование клиента</td>" skip
            "<td >Номер счета</td>" skip
            "<td >Сумма ИР</td>" skip
            "<td >Дата ИР</td>" skip
            "<td >Вид операции</td>" skip
            "<td >Статус отзыва</td>" skip
            "<td >Причина</td>" skip
            "<td >Подразделение</td>" skip
        "</tr>" skip.


if consld then do:

for each inkor1 where inkor1.rdt >= dt1 and inkor1.rdt <= dt2 no-lock:
    v-voch = ''.
    find first inc100 where  inc100.num = inkor1.inknum and inc100.iik = inkor1.aaa no-lock no-error.
    if avail inc100 then if lookup(inc100.vo, v-vo, "|") <> 0  then v-voch = inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|").
    put stream hrep unformatted
        "<tr align= right>" skip
            "<td>'" + inkor1.ref + "</td>" skip
            "<td>" + string(inkor1.rdt, "99/99/9999") + "</td>" skip
            "<td>" + string(inkor1.num) + "</td>" skip
            "<td>" + string(inkor1.inknum) + "</td>" skip
            "<td>" + string(inkor1.name) + "</td>" skip
            "<td>" + string(inkor1.aaa,'x(20)') + "</td>" skip
            "<td>" + string(inkor1.sum, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip
            "<td>"  entry(3,string(inkor1.inkdt,'99/99/99'),'/') + '/' + entry(2,string(inkor1.inkdt,'99/99/99'),'/')  + '/' + entry(1,string(inkor1.inkdt,'99/99/99'),'/')  "</td>" skip
            "<td>"  v-voch  "</td>" skip
            "<td>" + entry(lookup(string(inkor1.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip
            "<td>" + entry(lookup(string(inkor1.rson, "99"), v-recall_reason, "|"), v-recall_reason2, "|") + "</td>" skip.

    find first inc100 where inc100.ref eq inkor1.inkref and inc100.num eq inkor1.inknum no-lock no-error.
    if avail inc100 then do:
        find first txb where txb.bank eq inc100.bank no-lock no-error.
        if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
        else put stream hrep unformatted "<td>" + inc100.bank + "</td>" skip.
    end.
    else put stream hrep unformatted "<td>" + inkor1.reschar[5] + "</td>" skip.

    put stream hrep unformatted "</tr>" skip.
end.

end.

else do:

for each inkor1 where inkor1.rdt >= dt1 and inkor1.rdt <= dt2 no-lock:
    v-voch = ''.
    find first inc100 where inc100.bank = s-vcourbank and inc100.num = inkor1.inknum and inc100.iik = inkor1.aaa no-lock no-error.
    if avail inc100 then do:
    if lookup(inc100.vo, v-vo, "|") <> 0  then v-voch = inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|").
    put stream hrep unformatted
        "<tr align= right>" skip
            "<td>'" + inkor1.ref + "</td>" skip
            "<td>" + string(inkor1.rdt, "99/99/9999") + "</td>" skip
            "<td>" + string(inkor1.num) + "</td>" skip
            "<td>" + string(inkor1.inknum) + "</td>" skip
            "<td>" + string(inkor1.name) + "</td>" skip
            "<td>" + string(inkor1.aaa,'x(20)') + "</td>" skip
            "<td>" + string(inkor1.sum, ">>>,>>>,>>>,>>>,>>9.99") + "</td>" skip
            "<td>"  entry(3,string(inkor1.inkdt,'99/99/99'),'/') + '/' + entry(2,string(inkor1.inkdt,'99/99/99'),'/')  + '/' + entry(1,string(inkor1.inkdt,'99/99/99'),'/')  "</td>" skip
            "<td>"  v-voch  "</td>" skip
            "<td>" + entry(lookup(string(inkor1.stat, "99"), v-sts, "|"), v-sts2, "|") + "</td>" skip
            "<td>" + entry(lookup(string(inkor1.rson, "99"), v-recall_reason, "|"), v-recall_reason2, "|") + "</td>" skip.

    /*find first inc100 where inc100.ref eq inkor1.inkref and inc100.num eq inkor1.inknum no-lock no-error.
    if avail inc100 then do:*/
        find first txb where txb.bank eq inc100.bank no-lock no-error.
        if avail txb then put stream hrep unformatted "<td>" + txb.info + "</td>" skip.
        else put stream hrep unformatted "<td>" + inc100.bank + "</td>" skip.
    /*end.
    else put stream hrep unformatted "<td>" + inkor1.reschar[5] + "</td>" skip.*/

    put stream hrep unformatted "</tr>" skip.
end.
end.

end.


put stream hrep unformatted "</table></body></html>".
output stream hrep close.
unix silent cptwin increport.html iexplore.
