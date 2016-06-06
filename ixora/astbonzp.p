/* astbonzp.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчет для отражения суммы удержания из заработной платы сотрудников для погашения займов по программе Астана-бонус
 * RUN
       Способ вызова программы, описание параметров, примеры вызова
 * CALLER
       Список процедур, вызывающих этот файл
 * SCRIPT
       Список скриптов, вызывающих этот файл
 * INHERIT
       Список вызываемых процедур
 * MENU
       3-4-2-23
 * AUTHOR
       10/04/2013 sayat(id00143) - ТЗ 1583 от 14/11/2012
 * BASES
	BANK
 * CHANGES

*/

def shared var g-today as date.
def shared var g-ofc like bank.ofc.ofc.

def new shared temp-table wrk
    field fil       as char
    field bank      as char
    field cif       as char
    field grp       as int
    field lon       as char
    field name      as char
    field crc       as int
    field lcnt      as char
    field rdt       as date
    field pdt       as date
    field opnamt    as decimal
    field amt       as decimal
    field od        as decimal
    field prc3      as deci
    field prc10     as deci
    field psum      as deci
    field csum      as deci.

def var v-crcname   as char.
def var v-psum      as deci.

def new shared var v-date as date.
def var nd  as int.
def var nm  as int.
def var nm1 as int.
def var ny  as int.
def var ny1 as int.
def var v-month as char.
def var k       as int.
def new shared var v-dt     as date.
def new shared var v-dt1    as date.

nm = month(g-today).
ny = year(g-today).

/*update "Дата: " v-date format "99/99/9999" no-label help "Введите дату." skip
skip with row 10 centered  side-label title "Астана-бонус" frame opt .
*/

form nm label 'Месяц' format '>9' validate (nm > 0 and nm < 13,'Неверное значение!') help "1-январь,2-февраль,3-март,...,12-декабрь" v-month no-label skip
     ny label 'Год  ' format '9999' skip
with side-label row 5 centered title "Удержание из ЗП по программе Астана Бонус за" overlay width 50 frame dat .

update nm with frame dat.

case nm:
    when 1 then v-month = 'январь'.
    when 2 then v-month = 'февраль'.
    when 3 then v-month = 'март'.
    when 4 then v-month = 'апрель'.
    when 5 then v-month = 'май'.
    when 6 then v-month = 'июнь'.
    when 7 then v-month = 'июль'.
    when 8 then v-month = 'август'.
    when 9 then v-month = 'сентябрь'.
    when 10 then v-month = 'октябрь'.
    when 11 then v-month = 'ноябрь'.
    when 12 then v-month = 'декабрь'.
end case.

displ nm v-month with frame dat.

update ny with frame dat.

v-date = date(nm,1,ny).
nm1 = nm + 1.
ny1 = ny.
if nm1 = 13 then do: nm1 = 1. ny1 = ny + 1. end.
run mondays(nm1, ny1, output nd).
v-dt = date(nm1,1,ny1).
v-dt1 = date(nm1,nd,ny1).

{r-brfilial.i &proc = "astbonzp1"}


def stream m-out.
output stream m-out to astbonzp95.htm.

put stream m-out unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream m-out unformatted "<h3 align=""center"" valign=""top"" colspan = 11> Cуммы удержания из заработной платы за  " + v-month + " " + string(ny, '9999') + " года <br>в счет погашения кредитов по программе ""Астана Бонус сотрудники"" </h3>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
    "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"">№ </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">ФИО заемщика </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Номер <br>договора </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата <br>договора </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата <br>очередного <br>платежа </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>полученного <br>кредита </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Оставшаяся <br>сумма <br>кредита </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>основного <br>долга (ОД)<br>к погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 3% <br>вознаграждения, <br>выплачиваемая <br>заемщиком <br>к погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 10% <br>субсидируемого <br>вознаграждения к <br>погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Итого <br>сумма <br>удержания из <br>заработной <br>платы <br>(сумма к <br>погашению) </td>".
if lookup(g-ofc,'id01143,BANKADM') > 0 then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>на <br>текущем <br>счете <br>заемщика </td>"
                                                                          "<td bgcolor=""#C0C0C0"" align=""center"">Нехватка <br>средств <br>на <br>текущем <br>счете <br>заемщика </td>".
put stream m-out unformatted "</tr>" skip.
k = 0.
for each wrk where wrk.grp = 95 no-lock:
    k = k + 1.
    /*if month(wrk.pdt) <> nm1 then next.*/
    put stream m-out unformatted
        "<tr>" skip
            "<td>" k "</td>" skip
            "<td>" wrk.name "</td>" skip
            "<td>&nbsp;" wrk.lcnt "</td>" skip
            "<td>" string(wrk.rdt, "99/99/9999") "</td>" skip
            "<td>" string(wrk.pdt, "99/99/9999") "</td>" skip
            "<td>" replace(string(wrk.opnamt,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.amt,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.od,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.prc3,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.prc10,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.psum,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            .
    if lookup(g-ofc,'id01143,BANKADM') > 0 then do:
        put stream m-out unformatted "<td>" replace(string(abs(wrk.csum),'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
        if wrk.csum + wrk.psum > 0 then put stream m-out unformatted "<td>" replace(string(wrk.csum + wrk.psum,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
        else put stream m-out unformatted "<td>" replace(string(0.00,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
    end.
    put stream m-out unformatted "</tr>" skip.
end.
put stream m-out unformatted "</table>" skip.
put stream m-out unformatted
    "<table cellpadding=""11"" cellspacing="""" style=""border-collapse: collapse"">".
put stream m-out unformatted
    "<tr></tr><tr style=""font:bold""><td ></td><td colspan=5 align=""left"">Директор департамента мидл-офиса</td><td colspan=3 align=""right"">_________________________ Рахимов С.С </td></tr>" skip
    "<tr></tr><tr style=""font:bold""><td ></td><td colspan=5 align=""left"">Директор департамента кадровой политики</td><td colspan=3 align=""right"">_________________________ Бендюк Л.Б. </td></tr>" skip.
put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "</body></html>".
output stream m-out close.
unix silent cptwin astbonzp95.htm excel.

def stream m-out1.
output stream m-out1 to astbonzp96.htm.

put stream m-out1 unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream m-out1 unformatted "<h3 align=""center"" valign=""top"" colspan = 11> Cуммы удержания из заработной платы за  " + v-month + " " + string(ny, '9999') + " года <br>в счет погашения кредитов по программе ""Астана Бонус""</h3>" skip.

put stream m-out1 unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
    "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"">№ </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">ФИО заемщика </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Номер <br>договора </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата <br>договора </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата <br>очередного <br>платежа </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>полученного <br>кредита </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Оставшаяся <br>сумма <br>кредита </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>основного <br>долга (ОД)<br>к погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 3% <br>вознаграждения, <br>выплачиваемая <br>заемщиком <br>к погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 10% <br>субсидируемого <br>вознаграждения к <br>погашению </td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Итого <br>сумма <br>удержания из <br>заработной <br>платы <br>(сумма к <br>погашению) </td>".
if lookup(g-ofc,'id01143,BANKADM') > 0 then put stream m-out1 unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>на <br>текущем <br>счете <br>заемщика </td>"
                                                                          "<td bgcolor=""#C0C0C0"" align=""center"">Нехватка <br>средств <br>на <br>текущем <br>счете <br>заемщика </td>".
put stream m-out1 unformatted "</tr>" skip.
k = 0.
for each wrk where wrk.grp = 96 no-lock:
    k = k + 1.
    /*if month(wrk.pdt) <> nm1 then next.*/
    put stream m-out1 unformatted
        "<tr>" skip
            "<td>" k "</td>" skip
            "<td>" wrk.name "</td>" skip
            "<td>&nbsp;" wrk.lcnt "</td>" skip
            "<td>" string(wrk.rdt, "99/99/9999") "</td>" skip
            "<td>" string(wrk.pdt, "99/99/9999") "</td>" skip
            "<td>" replace(string(wrk.opnamt,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.amt,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.od,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.prc3,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.prc10,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(wrk.psum,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            .
    if lookup(g-ofc,'id01143,BANKADM') > 0 then do:
        put stream m-out1 unformatted "<td>" replace(string(abs(wrk.csum),'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
        if wrk.csum + wrk.psum > 0 then put stream m-out1 unformatted "<td>" replace(string(wrk.csum + wrk.psum,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
        else put stream m-out1 unformatted "<td>" replace(string(0.00,'->>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
    end.
    put stream m-out1 unformatted "</tr>" skip.
end.
put stream m-out1 unformatted "</table>" skip.
put stream m-out1 unformatted
    "<table cellpadding=""11"" cellspacing="""" style=""border-collapse: collapse"">".
put stream m-out1 unformatted
    "<tr></tr><tr style=""font:bold""><td ></td><td colspan=5 align=""left"">Директор департамента мидл-офиса</td><td colspan=3 align=""right"">_________________________ Рахимов С.С </td></tr>" skip
    "<tr></tr><tr style=""font:bold""><td ></td><td colspan=5 align=""left"">Директор департамента кадровой политики</td><td colspan=3 align=""right"">_________________________ Бендюк Л.Б. </td></tr>" skip.
put stream m-out1 unformatted "</table>" skip.

put stream m-out1 unformatted "</body></html>".
output stream m-out1 close.
unix silent cptwin astbonzp96.htm excel.

