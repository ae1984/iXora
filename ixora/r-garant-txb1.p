/* r-garant-txb1.p
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
 * BASES
        BANK COMM TXB
 * CHANGES
	30.06.2010 - id00363
    11/11/2010 aigul - вывод temp.name увеличила вывод строки
    05/12/2011 id00700 - вывод temp.ost, увеличил вывод строки
*/

 /* r-garant-txb1.p
    отчет о выданных гарантиях консолид
    30.06.2010 */
/*{global.i new}*/
{functions-def.i}


def new shared stream m-out.
def new shared var v-dat as date no-undo.
def new shared var ecdivis as char no-undo.
define new shared var g-today  as date.
define new shared variable g-batch  as log initial false.

def new shared  temp-table temp
     field aaa       like  txb.aaa.aaa
     field ecdivis as char
     field regdt     like  txb.aaa.regdt
     field expdt     like  txb.aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  txb.cif.cif
     field name      like  txb.cif.sname
     field filial      like  txb.cmp.addr
     field crc       like  txb.crc.crc
     field code       like  txb.crc.code
     field sumzalog   like  txb.garan.sumzalog
     field ost       like  txb.jl.dam     init 0
     field ostkzt    like  txb.jl.dam     init 0.

 find last bank.cls no-lock no-error.
 g-today = if available bank.cls then bank.cls.cls + 1 else today.
 v-dat = g-today.

 update v-dat label ' Укажите дату ' format '99/99/9999'
        validate(v-dat ge 12/19/1999 and v-dat le g-today,
        "Дата должна быть в пределах от 19.12.1999 до текущего дня")
        skip with side-label row 5 centered frame dat .

 display '   Ждите...   '  with row 5 frame ww centered .

run txbs("r-garant-txb2.p").



/*find last txb.crchis where txb.crchis.crc = 'EUR' and txb.crchis.regdt <= v-dat no-lock no-error.*/
/*temp.ostkzt = temp.ost * txb.crchis.rate[1].*/


 output stream m-out to rpt.html.


 put stream m-out
'<html xmlns:o="urn:schemas-microsoft-com:office:office"                    '
'xmlns:x="urn:schemas-microsoft-com:office:excel"                           '
'xmlns="http://www.w3.org/TR/REC-html40">                                   '
'<meta http-equiv=Content-Type content="text/html; charset=windows-1251">    '
'<head>                                                                     ' skip.

 put stream m-out
"</head>                                                                               "
"<body link=blue vlink=purple class=xl25>                                              " skip.


 put stream m-out
"<p>&nbsp;</p><table width=90%><tr><td valign=middle align=center colspan=6><p></p><b><nobr>Счет  6555  \"Гарантийные поручительства  выданные банком\"</nobr>"
"<br><b>на " v-dat format '99/99/9999' ""
"</td><td>" skip.

find last bank.crchis where bank.crchis.crc = 3 and bank.crchis.rdt <= v-dat no-lock no-error.

put stream m-out
"<table border=1><tr><td>Евро</td><td x:num=" bank.crchis.rate[1] ">" bank.crchis.rate[1] "</td></tr>" skip.

find last bank.crchis where bank.crchis.crc = 4 and bank.crchis.rdt <= v-dat no-lock no-error.

put stream m-out
"<tr><td>RUR</td><td x:num=" bank.crchis.rate[1] ">" bank.crchis.rate[1] "</td></tr>" skip.

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.rdt <= v-dat no-lock no-error.

put stream m-out
"<tr><td>USD</td><td x:num=" bank.crchis.rate[1] ">" bank.crchis.rate[1] "</td></tr></table>"
"</td></tr></table><p></p>" skip.


 put stream m-out
"<table border=1>					                                       "
" <tr align=center>                                                 "
"  <td ><b>Наименование клиента</td>            "
"  <td ><b>Валюта</td>                                                          "
"  <td ><b>Филиал</td>                                                          "
"  <td ><b>Сумма гарантии <br>в ин.валюте</td>                               "
"  <td ><b>Сумма гарантии <br> в тенге</td>                                "
"  <td ><b>Сумма <br>обеспечения</td>                                              "
"  <td ><b>Дата <br>выдачи</td>                                 "
"  <td ><b>Срок <br>погашения</td>                              "
"  <td ><b>Вид <br>обеспечения</td>                            "
"  <td ><b>Отрасль <br>экономики</td>                              "
" </tr>" skip.

 for each temp where  temp.ost <> 0
              break by temp.vid by temp.expdt.
/*              break by temp.vid by temp.cif by temp.expdt.*/
     accum temp.ostkzt (total by temp.vid).

/*    if first-of(temp.cif) then*/
       put stream m-out '<tr><td> ' temp.name format 'x(500)' '</td> '
                        '<td>'    temp.code  '</td> '
                        '<td>'    temp.filial[1]  '</td> '
                        '<td>'    temp.ost   format 'zz,zzz,zzz,zz9.99' '</td> '
                        '<td>'    temp.ostkzt format 'zz,zzz,zzz,zz9.99' '</td> '
			'<td>'	  temp.sumzalog	format 'zz,zzz,zzz,zz9.99' '</td>'
                        '<td>'    temp.regdt '</td> '
                        '<td>'    temp.expdt '</td> '
                        '<td>'    temp.vid   '</td>'
                        '<td>'    temp.ecdivis '</td></tr>' skip.
/*    else
       put stream m-out  '<tr><td> ' temp.name  '</td>'
                         '<td>' temp.code  '</td> '
                         '<td>'    temp.filial[1]  '</td> '
                         '<td>'temp.ost   format 'zzz,zzz,zz9.99' '</td>'
                         '<td>'temp.ostkzt   format 'zz,zzz,zzz,zz9.99' '</td>'
			 '<td></td>'
                         '<td>'temp.regdt '</td>'
                         '<td>'temp.expdt '</td>'
                         '<td>'temp.vid '</td>'
			 '<td>'    temp.ecdivis '</td></tr>' skip.
*/
 if last-of(temp.vid)
    then do:
	put stream m-out
	" <tr > "
	"  <td></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	" </tr>" skip.

       put stream m-out skip  '<tr><td colspan=4><b>ИТОГО ПО ВИДУ ГАРАНТИИ: ' temp.vid '</td><td><b>'
                         accum  total by temp.vid temp.ostkzt   format 'zz,zzz,zzz,zz9.99' at 63 '</td><td colspan=5></td></tr> ' skip(1).
	put stream m-out
	" <tr > "
	"  <td></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	" </tr>" skip.

    end.
 end.
	put stream m-out
	" <tr > "
	"  <td></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	"  <td ></td>"
	" </tr>" skip.

       put stream m-out skip  '<tr><td colspan=4><b>ИТОГО:</td><td><b>'
                         accum  total temp.ostkzt format 'zz,zzz,zzz,zz9.99' at 63 '</td><td colspan=5></td></tr> ' skip(1).


/*
 for each temp where temp.ost <> 0
               break by temp.code.
     accum temp.ost (total by temp.code).
     accum temp.ostkzt (total by temp.code).
     if last-of(temp.code) then
         put stream m-out space(43)
                          temp.code   ' '
                          accum total by temp.code temp.ost
                          format 'zzz,zzz,zz9.99'
                          accum total by temp.code temp.ostkzt
                          format 'zz,zzz,zzz,zz9.99'  at 63
                          skip.
 end.
*/

 put stream m-out
 "</table></html>" skip.

 output stream m-out close.

unix silent cptwin rpt.html excel.

/*
 if  not g-batch then do:
     pause 0 before-hide .
     run menu-prt( 'rpt.html' ).
     pause before-hide.
 end.
 {functions-end.i}
 return.
*/