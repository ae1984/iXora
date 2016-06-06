/* incplat.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по оплате ИР
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
        26/07/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        15.08.2011 -ruslan - изменил заголовок отчета, добавил новые поля, добавил столбец incregdt
        05/05/2012 evseev - подключил nbankBik.i
*/
{global.i}
{nbankBik.i}
def new shared var v-dt1 as date.
def new shared var v-dt2 as date.
def new shared temp-table t-incpart
    field incdt as date
    field incnum as char
    field incregdt as date
    field incsum as deci
    field clname as char
    field psum as deci
    field pdt as date
    field ostsum as deci /*на текущую дату*/
    field bank as char
    field sts as char
    index idx is primary bank incnum.

v-dt1 = g-today.
v-dt2 = g-today.
update v-dt1 label 'С' format '99/99/9999' validate (v-dt1 <= g-today, " Дата должна быть не позже текущей!")
       v-dt2 label 'ПО' format '99/99/9999' validate (v-dt2 <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat title "ПЕРИОД".

{r-brfilial.i &proc = "incplat1"}

define stream m-out.
output stream m-out to incplat.htm.

put stream m-out unformatted "<html><head><title> АО " + v-nbankDgv + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3> АО " + v-nbankDgv + "</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет по оплате ИР и ПТП</h3><br>" skip.
put stream m-out unformatted "<h3>С " string(v-dt1,'99/99/9999') " по " string(v-dt2,'99/99/9999') "</h3><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                             "<tr style=""font:bold"">"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Дата Док.</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">№ док.</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Дата рег.</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Наименование<BR>плательщика</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<BR>платежа</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>платежа</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ИР/ПТП</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Подразделение<BR>(филиал)</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Статус</td>"
                             "</tr>" skip.


for each t-incpart no-lock:
    find first txb where txb.bank = t-incpart.bank and txb.consolid no-lock no-error.
    put stream m-out unformatted "<tr>"
    "<td>" string(t-incpart.incdt,'99/99/9999') "</td>" skip
    "<td>" t-incpart.incnum  "</td>" skip
    "<td>" string(t-incpart.incregdt, '99/99/9999')  "</td>" skip
    "<td>" replace(trim(string(t-incpart.incsum,'>>>>>>>>>9.99')),'.',',')  "</td>" skip
    "<td>" t-incpart.clname  "</td>" skip
    "<td>" replace(trim(string(t-incpart.psum,'>>>>>>>>>9.99')),'.',',') "</td>" skip
    "<td>" string(t-incpart.pdt,'99/99/9999')  "</td>" skip
    "<td>" replace(trim(string(t-incpart.ostsum,'>>>>>>>>>9.99')),'.',',') "</td>" skip
    "<td>" txb.info "</td>" skip
    "<td>" t-incpart.sts "</td></tr>" skip.
end.
put stream m-out "</table></body></html>".
output stream m-out close.
unix silent value("cptwin incplat.htm excel").