/* 4sb.p
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
        3СБ 28/07/03 marinav
                        1.Объединила ссудную и просрочееную задолженность (3СБ)
                        2.В расширенный отчет добавила срок кредита
                        3.В сокращенный отчет дабавила среднюю % ставку  по группе
            30/07/03 nataly
                        изменено название
                        были добавлены признак резидентсва, сектор эк-ки и валюта  к счету ГК
                        при выводе сокращенной формы отчета цифровые данные с точкой были заменены на запятую
            02/08/2004 madiar - учет уровней индексации
            03/08/2004 madiar - просроченный ОД - в отдельную колонку
            12/08/2004 madiar - в связи c изменением числа пар-ров в lonbal - отредактировал вызов
            16/08/2004 madiar - в связи c изменением числа пар-ров в lonbal - отредактировал вызов
            08/09/2005 madiar - убрал учет индексации
            21.05.08   marinav - консолидация
            08/12/2010 evseev  - меню выбора формирования отчета Переченем шифров объектов кодирования с разбивкой или без неё
            13/12/2010 evseev  - добавление столбца "срок погашения" sub11
            04/04/2011 dmitriy - в расшифровке сводного отчета формирование суммы кредита и просрочки в тенге, а не в тыс. тенге
            04.08.2011 aigul - вывод экон сектор из справочника клиента
            25/04/2012 evseev  - rebranding. Название банка из sysc.
            27/04/2012 evseev  - повтор
*/

{global.i}
{nbankBik.i}

def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summaprsr as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var coun as int init 1.
def var v-summa like lon.opnamt.
def var v-summaprsr like lon.opnamt.
def var v-summaproc like lon.opnamt.
def var i as int.
def new shared variable v-dt  as date format "99/99/9999".
/*evseev */
def new shared variable v-d-cod like sub-cod.d-cod.
def var v-list as char.
def var v-list1 as char.
def var v-sel as int.
/*end evseev */

def new shared temp-table  wrk
    field lon    like lon.lon
    field crc    like lon.crc
    field name   like cif.name
    field gl     like lon.gua
    field amount like lon.opnamt
    field balansprsr like lon.opnamt
    field sub1   like sub-cod.ccode
    field sub2   like sub-cod.ccode
    field sub3   like sub-cod.ccode
    field sub4   like sub-cod.ccode
    field sub5   like sub-cod.ccode
    field sub6   like sub-cod.ccode
    field sub7   like sub-cod.ccode
    field sub8   like sub-cod.ccode
    field sub9   like sub-cod.ccode
    field sub10   like sub-cod.ccode
    field sub11   as char
    field sub71   like sub-cod.ccode
    field proc   like lon.prem
    field procsum like lon.opnamt.

def var crlf as char.
crlf = chr(10) + chr(13).


v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .
 if v-dt = g-today then run tb('Внимание!','День не закрыт.','Данные на текущий момент',string(v-dt)).

/*evseev */
v-d-cod = 'lntgt'.
v-sel = 0.
v-list = " 1. Без разбивки по шифрам объекта кредитования | 2. С разбивкой по шифрам объекта кредитования (lntgt_1)".
v-list1 = "lntgt,lntgt_1".

run sel2("Вид отчета",v-list,output v-sel).
if v-sel > 0 then v-d-cod = entry(v-sel,v-list1).
else return.
/*end evseev */


{r-brfilial.i &proc = "4sb_b"}


/**/
define stream m-out.
output stream m-out to 4sb.html.
put stream m-out "<html><head><title>" + v-nbank1 + "</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf.

put stream m-out "<tr align=""center""><td><h3>Отчет о предоставленных займах за "
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
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код вида эк. деят-ти (по клиенту)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма задол-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма проср.задол-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Процент</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма проц</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код вида эк. деят-ти (по залогу)</td>"
                  "</tr>".

for each wrk break by wrk.crc desc by wrk.gl.

   put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " '`' wrk.sub1 format "x(5)" "</td>"
               "<td> " wrk.gl format "x(7)" "</td>"
               "<td> " '`' wrk.sub2 format "x(5)" "</td>"
               "<td> " '`' wrk.sub4 format "x(5)" "</td>"
               "<td> " '`' wrk.sub5 format "x(5)" "</td>"
               "<td> " '`' wrk.sub7 format "x(5)" "</td>"
               "<td> " '`' wrk.sub8 format "x(5)" "</td>"
               "<td> " wrk.amount format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.balansprsr format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.proc format '>9.99%' "</td>"
               "<td> " wrk.procsum format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.sub11 format "x(35)" "</td>"
               "<td> " '`' wrk.sub71 format "x(5)" "</td>"
               "</tr>" crlf.

    accumulate wrk.amount (TOTAL by wrk.crc).
    accumulate wrk.balanspr (TOTAL by wrk.crc).
    accumulate wrk.procsum (TOTAL by wrk.crc).
    coun = coun + 1.

    if last-of (wrk.crc) then
    do:
       find crc where crc.crc = wrk.crc no-lock no-error.
       summa1 = accum total by wrk.crc wrk.amount.
       summaprsr = accum total by wrk.crc wrk.balansprsr.
       summa2 =  accum total by wrk.crc wrk.procsum.
       v-summa = v-summa + accum total by wrk.crc wrk.amount.
       v-summaprsr = v-summaprsr + accum total by wrk.crc wrk.balansprsr.
       v-summaproc = v-summaproc + accum total by wrk.crc wrk.procsum.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО " crc.des "</b></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " summa1 format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td><b> " summaprsr format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td></td>"
                 "<td><b> " summa2 format '>>>>>>>>>>>9.99' "</b></td>"
                 "</td></tr><tr></tr><tr></tr>" crlf crlf crlf.
      coun = 1.
    end.

end.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО </b></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " v-summa format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td><b> " v-summaprsr format '>>>>>>>>>>>9.99' "</b></td>"
                 "<td><b> " v-summaproc / v-summa * 100 format '>9.99%' "</b></td>"
                 "<td><b> " v-summaproc format '>>>>>>>>>>>9.99' "</b></td>"
                 "</td></tr>" crlf crlf crlf.

put stream m-out "</table>" crlf.
put stream m-out "</table>" crlf.

put stream m-out "</body></html>" crlf.
output stream m-out close.


output stream m-out to 4sb-1.html.
put stream m-out "<html><head><title>" + v-nbank1 + "</title>" crlf
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
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма проср.задол-ти</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Процент</td></tr>".

for each wrk break by wrk.sub1
                   by wrk.gl
                   by wrk.sub2
                   by wrk.sub4
                   by wrk.sub5
                   by wrk.sub7:

    accumulate wrk.amount (SUB-TOTAL by wrk.sub7).
    accumulate wrk.amount (SUB-TOTAL by wrk.gl).
    accumulate wrk.balansprsr (SUB-TOTAL by wrk.sub7).
    accumulate wrk.balansprsr (SUB-TOTAL by wrk.gl).
    accumulate wrk.procsum (SUB-TOTAL by wrk.sub7).
    accumulate wrk.procsum (SUB-TOTAL by wrk.gl).

    if last-of (wrk.sub7) then
    do:
        summa1 = accum sub-total by wrk.sub7 wrk.amount.
        summaprsr = accum sub-total by wrk.sub7 wrk.balansprsr.
        summa2 = accum sub-total by wrk.sub7 wrk.procsum.
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " '`' wrk.sub1 format "x(5)" "</td>"
               "<td> " wrk.gl format "x(7)" "</td>"
               "<td> " '`' wrk.sub2 format "x(5)" "</td>"
               "<td> " '`' wrk.sub4 format "x(5)" "</td>"
               "<td> " '`' wrk.sub5 format "x(5)" "</td>"
               "<td> " '`' wrk.sub7 format "x(5)" "</td>"
               "<td> "  round(summa1 / 1000, 0) format 'zzzzzzzzzzz9' "</td>"
               "<td> "  round(summaprsr / 1000, 0) format 'zzzzzzzzzzz9' "</td>"
               "<td> " summa2 / summa1 * 100 format '>9.99%' "</td>"
               "</tr>" crlf.
    coun = coun + 1.
    end.
    if last-of (wrk.gl) then
    do:
        summa1 = accum sub-total by wrk.gl wrk.amount.
        summaprsr = accum sub-total by wrk.gl wrk.balansprsr.
        summa2 = accum sub-total by wrk.gl wrk.procsum.
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> Итого </td>"
               "<td align=""left""> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> " round(summa1 / 1000, 0) format 'zzzzzzzzzzz9' "</td>"
               "<td> " round(summaprsr / 1000, 0) format 'zzzzzzzzzzz9' "</td>"
               "<td> " summa2 / summa1 * 100 format '>9.99%' "</td>"
               "</tr>" crlf.

    end.

end.
       put stream m-out
                 "<tr align=""right"">"
                 "<td></td><td  align=""left""><b> ИТОГО </b></td> <td></td><td></td> <td></td> <td></td> <td></td> "
                 "<td><b> " round( v-summa / 1000, 0) format 'zzzzzzzzzzz9' "</b></td>"
                 "<td><b> " round( v-summaprsr / 1000, 0) format 'zzzzzzzzzzz9' "</b></td>"
                 "<td><b> " v-summaproc / v-summa * 100 format '>9.99%' "</b></td>"
                 "</td></tr>" crlf crlf crlf.

put stream m-out "</table>" crlf.
put stream m-out "</table>" crlf.

put stream m-out "</body></html>" crlf.
output stream m-out close.



unix silent cptwin 4sb.html excel.exe.
unix silent cptwin 4sb-1.html excel.exe.

unix silent rm 4sb.html.
unix silent rm 4sb-1.html.


