/* garancom.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Отчет по амортизации комиссии по гарантиям вывод данных
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        garancomf.p
 * MENU
        3.4.12.6
 * AUTHOR
        06/09/2013 galina по ТЗ 1779
 * BASES
        BANK COMM
 * CHANGES
*/

def new shared var v-dat    as date no-undo.
def new shared var v-rate   as deci no-undo extent 3.
def new shared var v-name as char no-undo extent 3.
def var v-dat0 as date no-undo.


def stream m-out.

def new shared  temp-table temp
     field filial     as   char
     field name       like cif.sname
     field numgar     as   char
     field gl         as   char
     field curr       as   char
     field sumgar     like garan.sumtreb
     field sumgarkzt  like garan.sumtreb
     field dtfrom     like aaa.regdt
     field dtto       like aaa.expdt
     field sumkom     like garan.sumkom
     field sumkomostB like garan.sumkom /*Остаток несамортизированной комиссии на балансе 286920*/
     field sumkomostC like garan.sumkom /*Остаток несамортизированной комиссии (расчетная величина)*/
     field sumkomostR like garan.sumkom /*Остаток несамортизированной комиссии разница между расчетной и реальной суммой*/.

 find last bank.cls no-lock no-error.
 v-dat0 = if available bank.cls then bank.cls.cls + 1 else today.
 v-dat  = v-dat0.

 update v-dat label ' Укажите дату ' format '99/99/9999'
        validate(v-dat ge 05/19/2006 and v-dat le v-dat0,
        "Дата должна быть в пределах от 05.07.2006 до текущего дня")
        skip with side-label row 5 centered frame dat .

 display '   Ждите...   '  with row 5 frame ww centered .
/*надо выяснить пересчет суммы гарантии в тенге на дату выдачи гарантии или на дату формирования отчета??????????*/
 for each bank.crc where bank.crc.crc > 1 and bank.crc.crc <= 4 no-lock:
    find last bank.crchis where bank.crchis.crc = bank.crc.crc and bank.crchis.rdt < v-dat no-lock no-error.
    if avail bank.crchis then assign v-rate[bank.crchis.crc - 1] =  bank.crchis.rate[1]
                                     v-name[bank.crchis.crc - 1] =  bank.crc.code.
 end.
 EMPTY TEMP-TABLE temp.
 {r-brfilial.i &proc = "garancomf"}

output stream m-out to garancom.html.
 put stream m-out
'<html xmlns:o="urn:schemas-microsoft-com:office:office"                    '
'xmlns:x="urn:schemas-microsoft-com:office:excel"                           '
'xmlns="http://www.w3.org/TR/REC-html40">                                   '
'<meta http-equiv=Content-Type content="text/html; charset=windows-1251">   '
'<head>                                                                     ' skip.

 put stream m-out
"</head> "
"<body link=blue vlink=purple class=xl25> " skip.

 put stream m-out
"<p>&nbsp;</p><table width=90%><tr><td valign=middle align=center colspan=6><p></p><b><nobr>Отчет по амортизации комиссии по гарантиям</nobr>"
"<br><b>по состоянию на " v-dat format '99/99/9999' ""
"</td></tr><tr></tr>" skip(2).

/* i = 1.
 do while i <= 3:
    if i = 1 then put stream m-out "<table border=1>".
    put stream m-out "<tr><td>" v-name[i] "</td><td x:num=" v-rate[i] ">" v-rate[i] "</td></tr>".
    if i = 3 then put stream m-out "</table></td></tr></table><p></p>".
    put stream m-out skip.
    i = i + 1.
 end.*/

 put stream m-out
" <table border=1> "
" <tr align=center> "
" <td ><b> <br>Филиал<br> </td> "
" <td ><b> <br>Наименование<br>принципала</td> "
" <td ><b><br>Номер<br>гарантии</td>  "
" <td ><b><br>Счет ГК</td>  "
" <td ><b><br>Валюта<br></td> "
" <td ><b>Сумма<br>гарантии в<br>номинале</td> "
" <td ><b>Сумма<br>гарантии в<br>тенге</td> "
" <td ><b> <br>Дата<br>выдачи</td> "
" <td ><b> <br>Дата<br>погашения</td> "
" <td ><b> <br>Сумма<br>комиссии</td> "
" <td ><b>Остаток<br>несамортизированной<br>комиссии на балансе<br>286920</td> "
" <td ><b>Остаток<br>несамортизированной<br>комиссии<br>(расчетная величина)</td> "
" <td ><b> <br>Разница<br> </td> "
" </tr>" skip.

put stream m-out
" <tr align=center> "
" <td ><b>1</td> "
" <td ><b>2</td> "
" <td ><b>3</td>  "
" <td ><b>4</td>  "
" <td ><b>5</td> "
" <td ><b>6</td> "
" <td ><b>7</td> "
" <td ><b>8</td> "
" <td ><b>9</td> "
" <td ><b>10</td> "
" <td ><b>11</td> "
" <td ><b>12</td> "
" <td ><b>13</td> "
" </tr>" skip.

for each temp break by temp.filial by temp.dtfrom:

    accum temp.sumkomostB (total by temp.filial).
    accum temp.sumkomostC (total by temp.filial).
    accum temp.sumkomostR (total by temp.filial).
    put stream m-out '<tr><td>' temp.filial                                      '</td>'
                        '<td>' temp.name       format 'x(500)'                   '</td>'
                        '<td>&nbsp;' temp.numgar       format 'x(20)'                  '</td>'
                        '<td>' temp.gl         format 'x(6)'                     '</td>'
                        '<td>' temp.curr        format 'x(3)'                    '</td>'
                        '<td>' temp.sumgar     format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        '<td>' temp.sumgarkzt  format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        '<td>&nbsp;' temp.dtfrom                                  '</td>'
                        '<td>&nbsp;' temp.dtto                                    '</td>'
                        '<td>' temp.sumkom     format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        '<td>' temp.sumkomostB format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        '<td>' temp.sumkomostC format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        '<td>' temp.sumkomostR format '-zzz,zzz,zzz,zzz,zz9.99'   '</td>'
                        skip.

    if last-of(temp.filial) then do:

        put stream m-out skip  '<tr><td colspan=10><b>ИТОГО ПО Фииалу: ' temp.filial '</td><td><b>'
                                accum  total by temp.filial temp.sumkomostB format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td><td>'
                                accum  total by temp.filial temp.sumkomostC format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td><td>'
                                accum  total by temp.filial temp.sumkomostR format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td></tr> ' skip(1).
        put stream m-out
	    " <tr> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td>  "
        " <td ></td>  "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " <td ></td> "
        " </tr>" skip.
    end.

end.



if v-select = 1 then do:
    put stream m-out skip  '<tr><td colspan=10><b>ИТОГО ПО БАНКУ: </td><td><b>'
                     accum  total temp.sumkomostB format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td><td>'
                     accum  total temp.sumkomostC format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td><td>'
                     accum  total temp.sumkomostR format '-zzz,zzz,zzz,zzz,zzz,zz9.99' '</td></tr> ' skip(1).
end.


put stream m-out "</table></html>" skip.

output stream m-out close.

unix silent cptwin garancom.html excel.
unix silent rm garancom.html.
hide all no-pause.

