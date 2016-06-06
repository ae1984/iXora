/* spfbos.p
 * MODULE
          Справка по переводам
 * DESCRIPTION

 * BASES
          BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
          31.03.09 id00363
 * CHANGES
          06/09/11 dmitriy - добавил столбцы Номер транзакции и Наименование филиала
          11/10/2011 madiyar - отчет очень ресурсоемкий, поэтому разрешаем формировать только до 9 утра или после 6 вечера.
                               При необходимости формировать днем - правим настройку spfbos в справочник pksysc.
*/

{mainhead.i}

def var ttime as integer no-undo.
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "spfbos" no-lock no-error.
if not(avail pksysc and pksysc.loval) then do:
    ttime = time.
    if ttime > 32400 and ttime < 64800 then do:
        message skip "Данный отчет сильно влияет на производительность системы,~nпоэтому отчет можно формировать только в период времени с 18:00 до 09:00.~n~n" +
                "В случае крайней необходимости срочного формирования отчета обратитесь в техподдержку." skip(1) view-as alert-box information.
        return.
    end.
end.

/* 1 */
def var v-path as char no-undo.
def var v-run as char no-undo.

def new shared var j-info   as char.
def new shared var j-perkod   as char.

def var infoperkod as char.
def var j-fam as char.
def var j-name as char.
def var j-otch as char.

form j-info label ' ФИО...............' format 'x(1000)' view-as fill-in size 70 by 1 skip(1)
     j-perkod label ' РНН Отправителя...'  format '999999999999'
with side-label row 5 width 100 centered frame dat.


update j-info j-perkod with frame dat.


j-info = '*' + j-info + '*'.
j-perkod = '*' + j-perkod + '*'.


define stream rep.

output stream rep to myreport.html.


put stream rep unformatted

    "<html>" skip
    "<head>" skip
          "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
          "<title>Справка по переводам физ.лиц без открытия счета</title>" skip
             "<style type= text/css>" skip
             "TABLE \{ border-collapse: collapse; \}" skip
             "</style>" skip
    "</head>" skip
    "<body>" skip



    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0  >" skip
    "<tr align= center>" skip
    "<td colspan=11>Дата формирования справки по переводам " + string(today, "99/99/99") + "</td>" skip
    "</tr>" skip
    "<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0 align= center>" skip
    "<td>Система переводов</td>" skip
    "<td>Отпр/Полученный</td>" skip
    "<td>ФИО</td>" skip
    "<td>РНН</td>" skip
    "<td>Сумма</td>" skip
    "<td>Дата</td>" skip
    "<td>Номер транзакции</td>" skip
    "<td>Наименование филиала</td>" skip.



output stream rep close.


v-path = '/data/b'.

if connected ("txb") then disconnect "txb".

for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run spfbos-txb.
    if connected ("txb") then disconnect "txb".
end.


/*j-fam = '*' + entry(1,j-info,'') + '*'.
if num-entries(j-info,' ') > 1 then j-name = '*' + entry(2,j-info,'') + '*'.
if num-entries(j-info,' ') > 2 then j-otch = '*' + entry(3,j-info,'') + '*'.
*/
j-fam = entry(1,j-info,' ').
if num-entries(j-info,' ') > 1 then  j-name = entry(2,j-info,' ').
if num-entries(j-info,' ') > 2 then j-otch = entry(3,j-info,' ').

j-fam = '*' + j-fam + '*'.
j-name = '*' + j-name + '*'.
j-otch = '*' + j-otch + '*'.

j-perkod = '*' + j-perkod + '*'.

define stream rep.

output stream rep to myreport.html append.



for each comm.translat where comm.translat.fam matches j-fam AND comm.translat.name matches j-name AND comm.translat.otch matches j-otch AND comm.translat.rnn matches j-perkod
no-lock break by comm.translat.fam:

	if first-of(comm.translat.fam) then do:
		put stream rep unformatted
		"<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0>" skip
			"<td colspan=6>Метроэкспресс- отправленные</td>" skip
		"</tr>" skip.
        end.

	put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
	"<td>Метроэкспресс</td>" skip
	"<td>отправленный</td>" skip
        "<td  align= center>" comm.translat.fam "&nbsp;" comm.translat.name "&nbsp;" comm.translat.otch "</td>" skip
        "<td>" comm.translat.rnn "</td>" skip
        "<td>" comm.translat.summa "</td>" skip
        "<td  align= center>" comm.translat.date format '99.99.9999' "</td>" skip
        "<td>" comm.translat.jh "</td>" skip
        "<td>" comm.translat.bank "</td>" skip
        "</tr>" skip.
end.

/*
put stream rep unformatted
	"<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0>" skip
		"<td colspan=6>Метроэкспресс- полученные</td>" skip
	"</tr>" skip.

*/


if j-info <> '**' then do:

for each comm.r-translat where comm.r-translat.fam matches j-fam AND comm.r-translat.name matches j-name AND comm.r-translat.otch matches j-otch no-lock
break by comm.r-translat.fam:

	if first-of(comm.r-translat.fam) then do:
		put stream rep unformatted
		"<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0>" skip
			"<td colspan=6>Метроэкспресс- полученные</td>" skip
		"</tr>" skip.
        end.

	put stream rep unformatted
        "<tr style=' font-size:x-small'>" skip
	"<td>Метроэкспресс</td>" skip
	"<td>полученный</td>" skip
        "<td  align= center>" comm.r-translat.fam "&nbsp;" comm.r-translat.name "&nbsp;" comm.r-translat.otch "</td>" skip
        "<td> &nbsp; </td>" skip
        "<td>" comm.r-translat.summa "</td>" skip
        "<td  align= center>" comm.r-translat.date format '99.99.9999' "</td>" skip
        "<td>" comm.r-translat.jh "</td>" skip
        "<td>" comm.r-translat.rec-bank "</td>" skip
        "</tr>" skip.
end.

end.



put stream rep unformatted "</table></body></html>".

output stream rep close.
unix silent cptwin myreport.html explorer.