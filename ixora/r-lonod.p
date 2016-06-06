/* r-lonod.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


def shared var g-today as date.
def var crlf as char.
def var coun as int init 1.
def var v-jh as int init 0.
def var bilance as decimal format '->>>,>>>,>>>,>>9.99'.
def var v-acc like aaa.aaa.
def var sumbil as decimal format '->>>,>>>,>>>,>>9.99'.
def var datums  as date format '99/99/9999' label 'На'.

datums = g-today.

crlf = chr(10) + chr(13).

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 crlf.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf. 


put stream m-out "<tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr>"
                 crlf crlf.

put stream m-out "<tr align=""center""><td><h3>Овердрафты клиентов за " string(datums)
                 "</h3></td></tr><br>"
                 crlf crlf.

       put stream m-out "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Текущий счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на тек счете</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет овердрафта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на счете ОД</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней до погашения</td></tr>" crlf.



for each lon where lon.grp = 70 and lon.dam[1] - lon.cam[1] > 0 break by lon.crc by lon.cif.
 
   find first jl where jl.acc = lon.lon and jl.dc = 'd' no-lock no-error.
   if avail jl then v-jh = jl.jh.
 
   find first jl where jl.jh = v-jh and jl.dc = 'c' no-lock no-error.
   if avail jl then v-acc = jl.acc.

   find first aaa where aaa.aaa = v-acc no-lock no-error.
   
   find cif where cif.cif = lon.cif no-lock.
   find crc where crc.crc = lon.crc no-lock.

        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " lon.cif "</td>"
               "<td align=""left""> " trim(cif.prefix) + " " + cif.name format "x(60)" "</td>"
               "<td align=""left""> " crc.code "</td>"
               "<td align=""left""> " "`" v-acc "</td>"
               "<td> " aaa.cr[1] - aaa.dr[1] format '->>>>>>>>>>>9.99' "</td>"
               "<td align=""left""> " "`" lon.lon "</td>"
               "<td> " lon.dam[1] - lon.cam[1]  format '->>>>>>>>>>>9.99'  "</td>"
               "<td> " lon.rdt "</td>"
               "<td> " lon.duedt "</td>"
               "<td> " lon.duedt - datums "</td>"
               "</tr>" crlf.

         sumbil = sumbil + lon.dam[1] - lon.cam[1].
         coun = coun + 1.

    if last-of (lon.crc) then
    do:
       find crc where crc.crc = lon.crc no-lock.
       put stream m-out
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО " crc.des "</b></td> <td></td> <td></td> <td></td> <td></td> " 
                 "<td align=""right""><b>" sumbil format '->>>>>>>>>>>9.99' "</b></td></tr>" crlf.
       sumbil = 0.
    end.


end.


put stream m-out "</table>" crlf.
output stream m-out close.

unix silent cptwin rpt.html excel.exe. 
