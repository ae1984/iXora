/* r-gar.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расшифровка условных обязательств по аккредитивам и гарантиям (отчет)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-garf.p
 * MENU
        3-4-12-5
 * AUTHOR
        30/06/2011 id00810
 * BASES
        BANK COMM TXB
 * CHANGES
        27/07/2011 id00810 - новые графы Бенефициар, Сумма комиссии
*/

def new shared var v-dat    as date no-undo.
def new shared var v-rate   as deci no-undo extent 3.
def var v-dat0 as date no-undo.
def var v-name as char no-undo extent 3.
def var i      as int  no-undo.
def stream m-out.

def new shared  temp-table temp
     field filial    as   char
     field cif       like txb.cif.cif
     field name      like txb.cif.sname
     field opf       as   char
     field vidusl    as   char
     field ecdivis   as   char
     field rez       as   char
     field ins       as   char
     field ref       as   char
     field regdt     like txb.aaa.regdt
     field expdt     like txb.aaa.expdt
     field code      like txb.crc.code
     field nps       as   char
     field sumtreb   like txb.garan.sumtreb
     field sumzalog  like txb.garan.sumzalog
     field zalog     as   char
     field classif   as   char
     field bal1      as   deci
     field bal2      as   deci
     field bal3      as   deci
     field bal4      as   deci
     field naim      like txb.garan.naim
     field sumkom    like txb.garan.sumkom .

 find last bank.cls no-lock no-error.
 v-dat0 = if available bank.cls then bank.cls.cls + 1 else today.
 v-dat  = v-dat0.

 update v-dat label ' Укажите дату ' format '99/99/9999'
        validate(v-dat ge 07/05/2006 and v-dat le v-dat0,
        "Дата должна быть в пределах от 05.07.2006 до текущего дня")
        skip with side-label row 5 centered frame dat .

 display '   Ждите...   '  with row 5 frame ww centered .

 for each bank.crc where bank.crc.crc > 1 and bank.crc.crc <= 4 no-lock:
    find last bank.crchis where bank.crchis.crc = bank.crc.crc and bank.crchis.rdt < v-dat no-lock no-error.
    if avail bank.crchis then assign v-rate[bank.crchis.crc - 1] =  bank.crchis.rate[1]
                                     v-name[bank.crchis.crc - 1] =  bank.crc.code.
 end.

run txbs("r-garf.p").

output stream m-out to rpt.html.
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
"<p>&nbsp;</p><table width=90%><tr><td valign=middle align=center colspan=6><p></p><b><nobr>Расшифровка условных обязательств</nobr>"
"<br><b>на " v-dat format '99/99/9999' ""
"</td><td>" skip.

 i = 1.
 do while i <= 3:
    if i = 1 then put stream m-out "<table border=1>".
    put stream m-out "<tr><td>" v-name[i] "</td><td x:num=" v-rate[i] ">" v-rate[i] "</td></tr>".
    if i = 3 then put stream m-out "</table></td></tr></table><p></p>".
    put stream m-out skip.
    i = i + 1.
 end.

 put stream m-out
" <table border=1> "
" <tr align=center> "
" <td ><b> <br>Филиал<br> </td> "
" <td ><b> <br>Наименование принципала<br> </td> "
" <td ><b>Организационно-<br>правовая <br>форма</td>  "
" <td ><b>Вид<br>условного<br>обязательства</td>  "
" <td ><b>Отрасль<br>экономики</td> "
" <td ><b> <br>Резиденство<br> </td> "
" <td ><b> <br>Инсайдер<br> </td> "
" <td ><b>Номер<br>гарантии/<br>аккредитива </td> "
" <td ><b>Дата<br>выдачи</td> "
" <td ><b>Дата<br>погашения</td> "
" <td ><b>Валюта<br>выдачи</td> "
" <td ><b>Счет<br>по НПС</td> "
" <td ><b>Основной<br>долг</td> "
" <td ><b>Сумма<br>обеспечения</td> "
" <td ><b>Характеристика<br>обеспечения</td> "
" <td ><b>Классификация<br>категория</td> "
" <td ><b>1<br>Фин.состояние</td> "
" <td ><b>2<br>Просрочка</td> "
" <td ><b>3<br>Рейтинг</td> "
" <td ><b>Итого<br>баллов</td> "
" <td ><b> <br>Бенефициар<br> </td> "
" <td ><b>Сумма<br>комиссии</td> "
" </tr>" skip.

 for each temp break by temp.nps by temp.expdt:

     accum temp.sumtreb (total by temp.nps).

       put stream m-out '<td>' temp.filial                              '</td>'
                        '<td>' temp.name     format 'x(500)'            '</td>'
                        '<td>' temp.opf                                 '</td>'
                        '<td>' temp.vidusl   format 'x(10)'             '</td>'
                        '<td>' temp.ecdivis  format 'x(50)'             '</td>'
                        '<td>' temp.rez                                 '</td>'
                        '<td>' temp.ins      format 'x(100)'            '</td>'
                        '<td>' temp.ref      format 'x(12)'             '</td>'
                        '<td>' temp.regdt                               '</td>'
                        '<td>' temp.expdt                               '</td>'
                        '<td>' temp.code                                '</td>'
                        '<td>' temp.nps                                 '</td>'
                        '<td>' temp.sumtreb  format 'zzz,zzz,zz9.99'    '</td>'
                        '<td>' temp.sumzalog format 'zz,zzz,zzz,zz9.99' '</td>'
                        '<td>' temp.zalog    format 'x(500)'            '</td>'
                        '<td>' temp.classif                             '</td>'
                        '<td>' temp.bal1     format '-zz9'              '</td>'
                        '<td>' temp.bal2     format '-zz9'              '</td>'
                        '<td>' temp.bal3     format '-zz9'              '</td>'
                        '<td>' temp.bal4     format '-zz9'              '</td>'
                        '<td>' temp.naim     format 'x(500)'            '</td>'
                        '<td>' temp.sumkom   format 'zzz,zzz,zz9.99'    '</td>'
                        '</tr>' skip.
 if last-of(temp.nps)
    then do:
	put stream m-out
	" <tr > "
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
    " <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" </tr>" skip.

       put stream m-out skip  '<tr><td colspan=12><b>ИТОГО ПО БАЛАНСОВОМУ СЧЕТУ: ' temp.nps '</td><td><b>'
                         accum  total by temp.nps temp.sumtreb   format 'zz,zzz,zzz,zz9.99' at 120 '</td><td colspan=9></td></tr> ' skip(1).
put stream m-out
	" <tr > "
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
    " <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
    " <td></td>"
	" <td></td>"
	" </tr>" skip.

    end.
 end.
put stream m-out
	" <tr > "
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
    " <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" <td></td>"
	" </tr>" skip.

       put stream m-out skip  '<tr><td colspan=12><b>ИТОГО:</td><td><b>'
                         accum  total temp.sumtreb format 'zz,zzz,zzz,zz9.99' at 120 '</td><td colspan=9></td></tr> ' skip(1).
 put stream m-out
 "</table></html>" skip.

 output stream m-out close.

unix silent cptwin rpt.html excel.

