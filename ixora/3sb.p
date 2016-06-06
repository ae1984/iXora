﻿/* 3sb.p
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
  * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        13/12/2010 evseev - добавление столбца "срок погашения" sub09 , консолидация
        04/04/2011 dmitriy - в расшифровке сводного отчета формирование суммы кредита и просрочки в тенге, а не в тыс. тенге
*/

/*
 04/03/03  Задолженность по кредитам
*/


{global.i}


def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
define variable bilance  as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-cif as char format "x(30)".
def var v-ccode as char format "x(4)".
def var v-gl as char.
def var coun as int init 1.


def var v-summa like lon.opnamt.
def var v-summaproc like lon.opnamt.
def var stroka as char format "x(120)".
def var i as int.
define new shared variable v-dt     as date format "99/99/9999".
def new shared temp-table  wrk
    field lon    like lon.lon
    field crc    like lon.crc
    field name   like cif.name
    field gl     like lon.gua
    field amount like lon.opnamt
    field sub1   like sub-cod.ccode
    field sub2   like sub-cod.ccode
    field sub3   like sub-cod.ccode
    field sub4   like sub-cod.ccode
    field sub5   like sub-cod.ccode
    field sub6   like sub-cod.ccode
    field sub7   like sub-cod.ccode
    field sub8   like sub-cod.ccode
    field sub9   as char
    field proc   like lon.prem
    field procsum like lon.opnamt.

def var crlf as char.
crlf = chr(10) + chr(13).


v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .
 if v-dt = g-today then run tb('Внимание!','День не закрыт.','Данные на текущий  момент',string(v-dt)).

{r-brfilial.i &proc = "3sb_b"}

define stream m-out.
output stream m-out to 4sb.html.
put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf.

put stream m-out "<tr align=""center""><td><h3>Отчет об остатках ссудной задолженности по кредитам банка за "
                 string(v-dt) "</h3></td></tr><br><br>"
                 crlf crlf.
 put stream m-out "<br><br><tr></tr>".


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код займа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Бал. счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код объекта кредитования</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код займа по виду залога</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Форма соб-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код вида эк. деят-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма задол-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Процент</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок погашения</td>"
                  "</tr>".

for each wrk break by wrk.crc desc by wrk.gl.

   put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " '`' wrk.sub1 format "x(5)" "</td>"
               "<td> " wrk.gl format "x(4)" "</td>"
               "<td> " '`' wrk.sub2 format "x(5)" "</td>"
               "<td> " '`' wrk.sub4 format "x(5)" "</td>"
               "<td> " '`' wrk.sub5 format "x(5)" "</td>"
               "<td> " '`' wrk.sub7 format "x(5)" "</td>"
               "<td> " wrk.amoun format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.proc format '>9.99%' "</td>"
               "<td> " wrk.sub9 format "x(35)" "</td>"
               "</tr>" crlf.

    accumulate wrk.amount (TOTAL by wrk.crc).
    coun = coun + 1.

    if last-of (wrk.crc) then
    do:
       find crc where crc.crc = wrk.crc no-lock no-error.
       summa1 = accum total by wrk.crc wrk.amount.
       v-summa = v-summa + accum total by wrk.crc wrk.amount.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО " crc.des "</b></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " summa1 format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td></td>"
                 "</td></tr><tr></tr><tr></tr>" crlf crlf crlf.
      coun = 1.
    end.

end.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО </b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " v-summa format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td><b> " v-summaproc / v-summa * 100 format '>9.99%' "</b></td>"
                 "</td></tr>" crlf crlf crlf.

put stream m-out "</table>" crlf.
put stream m-out "</table>" crlf.

put stream m-out "</body></html>" crlf.
output stream m-out close.


output stream m-out to 4sb-1.html.
put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf.

put stream m-out "<tr align=""center""><td><h3>Отчет об остатках ссудной задолженности по кредитам банка за "
                 string(v-dt) "</h3></td></tr><br><br>"
                 crlf crlf.
 put stream m-out "<br><br><tr></tr>".


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код займа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Бал. счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код объекта кредитования</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код займа по виду залога</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Форма соб-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код вида эк. деят-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма задол-ти</td>"
                  "</tr>".

for each wrk break by wrk.sub1
                   by wrk.gl
                   by wrk.sub2
                   by wrk.sub4
                   by wrk.sub5
                   by wrk.sub7:

    accumulate wrk.amount (SUB-TOTAL by wrk.sub7).
    accumulate wrk.amount (SUB-TOTAL by wrk.gl).

    if last-of (wrk.sub7) then
    do:
        summa1 = accum sub-total by wrk.sub7 wrk.amount.
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " '`' wrk.sub1 format "x(5)" "</td>"
               "<td> " wrk.gl format "x(4)" "</td>"
               "<td> " '`' wrk.sub2 format "x(5)" "</td>"
               "<td> " '`' wrk.sub4 format "x(5)" "</td>"
               "<td> " '`' wrk.sub5 format "x(5)" "</td>"
               "<td> " '`' wrk.sub7 format "x(5)" "</td>"
               "<td> " round(summa1 / 1000, 0) format '>>>>>>>>>>>9.99' "</td>"
               "</tr>" crlf.
    coun = coun + 1.
    end.
    if last-of (wrk.gl) then
    do:
        summa1 = accum sub-total by wrk.gl wrk.amount.
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> Итого </td>"
               "<td align=""left""> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> " round(summa1 / 1000, 0) format '>>>>>>>>>>>9.99' "</td>"
               "</tr>" crlf.

    end.

end.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО </b></td> <td></td> <td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " round( v-summa / 1000, 0) format '>>>>>>>>>>>9.99' "</b></td>"
                 "</td></tr>" crlf crlf crlf.

put stream m-out "</table>" crlf.
put stream m-out "</table>" crlf.

put stream m-out "</body></html>" crlf.
output stream m-out close.



unix silent cptwin 4sb.html excel.exe.
unix silent cptwin 4sb-1.html excel.exe.

unix silent rm 4sb.html.
unix silent rm 4sb-1.html.