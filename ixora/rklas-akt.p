/* rklas-akt.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет "История классификации активов для провизий"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-5-4
 * AUTHOR
        31/01/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        15.08.2012 kapar - ТЗ 1440
*/

{global.i}

def new shared var dat1 as date.
def new shared var v-reptype as integer no-undo.

def new shared temp-table wrk
    field branch as char
    field cif as char
    field cifname as char
    field longr as inte
    field lonpool as char
    field londog as char
    field crc as char
    field opndt as date
    field duedt as date
    field opnamt as deci
    field od as deci
    field afn% as deci
    field afntg as deci
    field msfotg as deci
    field msfo% as deci
    field msfopen as deci
    field allmsfo as deci
    field msfo-afn as deci
    field bal_inter as deci
    field bal_penal as deci.

def frame fdat
    dat1 format "99/99/9999" label "Формирование на дату"
with side-labels centered row 10.

def var v-list as char.
def var v-sel  as int.

def var v-repname as char no-undo extent 5.
    v-repname[1] = "юридическим лицам".
    v-repname[2] = "Физическим лицам".
    v-repname[3] = "БД".
    v-repname[4] = "МСБ".
    v-repname[5] = "всем клиентам".

dat1 = date(month(today), 1, year(today)).

update dat1 validate (dat1 <> ? and dat1 <= g-today, "Неверная дата!") with frame fdat.
hide frame fdat.

if day(dat1) <> 1 then dat1 = date(month(dat1), 1, year(dat1)).

v-list = "Юр.л.|Физ.л.|БД|МСБ|Все|".
run sel2 ("Вид отчета",v-list , output v-sel).
v-reptype = v-sel.


{r-brfilial.i &proc = "rklas-akt2"}


define stream m-out.
output stream m-out to klas-akt.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out  unformatted "<tr align=""center""><td>История классификации активов для провизий <br>"
                               "на " dat1 format "99.99.9999" "</tr>".

put stream m-out  unformatted  "<tr align=""center""><td>Отчет сформирован  по " v-repname[v-sel] "</td>"
                               "</tr>" skip.
put stream m-out "<tr></tr>".


put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
              style=""border-collapse: collapse" ">" skip
              "<tr style=""font:bold" "" ">"
              "<td align=""center"">Филиал</td>"
              "<td align=""center"">Код<br>клиента</td>"
              "<td align=""center"">Ф.И.О.<br>заемщика</td>"
              "<td align=""center"">Группа</td>"
              "<td align=""center"">Пул<br>МСФО</td>"
              "<td align=""center"">№ Договора<br>банковского<br>займа</td>"
              "<td align=""center"">Валюта<br>кредита</td>"
              "<td align=""center"">Дата<br>выдачи</td>"
              "<td align=""center"">Дата<br>погашения</td>"
              "<td align=""center"">Одобренная<br>сумма (в<br>тенге</td>"
              "<td align=""center"">Остаток<br>основного<br>долга<br>(в тенге)</td>"
              "<td align=""center"">Начисл.%<br>(в тенге)</td>"
              "<td align=""center"">Штрафы</td>"
              "<td align=""center"">%<br>резерва<br>АФН</td>"
              "<td align=""center"">Резерв<br>АФН (в<br>тенге</td>"
              "<td align=""center"">Резерв<br>МСФО ОД<br>(в тенге)</td>"
              "<td align=""center"">Резерв<br>МСФО<br>%%<br>(в тенге)</td>"
              "<td align=""center"">Резерв<br>МСФО<br>Пеня<br>(в тенге)</td>"
              "<td align=""center"">Общая сумма<br>резерва МСФО<br>(в тенге)</td>"
              "<td align=""center"">Разница<br>МСФО/АФН</td>"
              "</tr>".

for each wrk no-lock:
    put stream m-out unformatted "<tr>"
        "<td>" wrk.branch "</td>"
        "<td>" wrk.cif "</td>"
        "<td>" wrk.cifname "</td>"
        "<td>" wrk.longr "</td>"
        "<td>" wrk.lonpool "</td>"
        "<td>`" wrk.londog "</td>"
        "<td>" wrk.crc "</td>"
        "<td>" wrk.opndt format "99.99.9999" "</td>"
        "<td>" wrk.duedt format "99.99.9999" "</td>"
        "<td>" replace(trim(string(wrk.opnamt, ">>>>>>>>>>>9.99")),'.',',') "</td>"
        "<td>" replace(trim(string(wrk.od, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.bal_inter, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.bal_penal, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.afn%, ">>>>>>>>>>>9.99")),'.',',') "</td>"
        "<td>" replace(trim(string(wrk.afntg, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.msfotg, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.msfo%, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.msfopen, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.allmsfo, ">>>>>>>>>>>9.99")),'.',',')  "</td>"
        "<td>" replace(trim(string(wrk.msfo-afn, "->>>>>>>>>>>9.99")),'.',',')  "</td>"
    "</tr>".
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
unix silent cptwin klas-akt.html excel.exe.
unix silent rm klas-akt.html.

