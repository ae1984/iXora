/* prov-afn.p
 * MODULE
        --
 * DESCRIPTION
        Отчет по итогам классификации кредитов, вошедших в портфели однородных МСБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.6.2
 * AUTHOR
        28/04/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared temp-table wrk
    field cifname as char
    field cif as char
    field branch as char
    field grp as int
    field crc as char
    field opnamt as deci
    field od as deci
    field od-day as int
    field perc-tg as deci
    field perc-day as deci
    field portf as char
    field res-perc as deci
    field res-sum as deci
    field pooln as char
    field od13 as deci
    field rezerv as deci
    index cif cif.

def new shared var v-sum_msb as deci no-undo.
def new shared var s-td as date.
def new shared var dat1 as date.
def new shared var v-dt as date no-undo.
def new shared var POROG as deci.
def new shared var REZERV as deci extent 4.
def var nm as integer no-undo.
def var ny as integer no-undo.
def var i as int.

dat1 = date(month(g-today),1,year(g-today)).
display dat1 label ' Дата ' format '99/99/9999' with side-label row 5 centered frame dat.
update dat1 with side-label row 5 centered frame dat.

s-td = g-today.
v-sum_msb = 0.

nm = month(g-today) + 1.
ny = year(g-today).
if nm = 13 then assign nm = 1 ny = ny + 1.
v-dt = date(nm,1,ny).

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk2.
end.
if connected ("txb") then disconnect "txb".

POROG = round(v-sum_msb * 0.0002, 2).

find sysc where sysc.sysc = 'lnodnorf' no-lock no-error.
if avail sysc then REZERV[4] = deci(entry(1, sysc.chval, "|")).


{r-brfilial.i &proc = "prov-afn2"}

  define stream m-out.
  output stream m-out to prov-afn.html.

  put stream m-out "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

  put stream m-out "<table
                     border=""0""
                     cellpadding=""0""
                     cellspacing=""0""
                     style=""border-collapse: collapse""
                   >"
                 skip.

put stream m-out unformatted "<tr><td><table border=""0"" cellpadding=""10"" cellspacing=""0""
              style=""border-collapse: collapse" ">" skip
              "<tr style=""font:bold" "" ">"
              "<td align=""center"">Кредиты МСБ за " dat1 "</td>"
              "<tr></tr>"
              "</tr>".

put stream m-out "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
              style=""border-collapse: collapse" ">" skip
              "<tr style=""font:bold" "" ">"
              "<td bgcolor=""#CCCCCC"" align=""center"">Наименование<br>заемщика</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Код<br>заемщика</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Филиал<br></td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Группа<br></td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Валюта<br>кредита</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Одобренная<br>сумма<br>тенге</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Остаток ОД<br>(тенге)</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Дней<br>проср.<br>ОД</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Начислен.<br>% (тенге)</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Дней<br>проср.<br>%</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Портфель<br>Однор.<br>кредитов</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">%<br>резерва</td>"
              "<td bgcolor=""#CCCCCC"" align=""center"">Сумма<br>резерва<br>(тенге)</td>"
              /*"<td bgcolor=""#CCCCCC"" align=""center"">Сумма<br>списанного ОД</td>"*/
              "</tr>".

do i = 1 to 4:
    for each wrk where wrk.pooln = string(i) no-lock use-index cif:
         put stream m-out unformatted
            "<tr>"
            "<td>" wrk.cifname "</td>"
            "<td>" wrk.cif "</td>"
            "<td>" wrk.branch "</td>"
            "<td>" wrk.grp "</td>"
            "<td>" wrk.crc "</td>"
            "<td>" replace(string(wrk.opnamt),".",",") "</td>"
            "<td>" replace(string(wrk.od),".",",") "</td>"
            "<td>" wrk.od-day "</td>"
            "<td>" replace(string(wrk.perc-tg),".",",") "</td>"
            "<td>" wrk.perc-day "</td>"
            "<td>" wrk.portf "</td>"
            "<td>" replace(string(wrk.rezerv),".",",") "</td>"
            "<td>" replace(string(wrk.res-sum),".",",") "</td>"
            /*"<td>" replace(string(wrk.od13),".",",") "</td>"*/
            "</tr>".
    end.
end.

put stream m-out "</table></body></html>" skip.

output stream m-out close.
unix silent cptwin prov-afn.html excel.exe.
unix silent rm prov-afn.html.
