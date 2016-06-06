/* spfbos.p
 * MODULE
          Справка по переводам
 * DESCRIPTION

 * BASES
          BANK COMM TXB
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
          31.03.09 id00363
 * CHANGES
        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/


/* 1 */
def new shared var dt1	as date no-undo.
def new shared var dt2	as date no-undo.
def new shared var if1	as char no-undo.

def var v-path as char no-undo.
def var v-run as char no-undo.

def new shared var j-info   as char.
def new shared var j-perkod   as char.

def var infoperkod as char.
def var j-fam as char.
def var j-name as char.
def var j-otch as char.


if1 = '1'.

form dt1 label ' Укажите период с' format '99/99/9999'
/*update	dt1 label ' Укажите период с' format '99/99/9999'*/
	dt2 label ' по' format '99/99/9999' skip(1)
	if1 label ' Вид отчета'  format '9'  skip(1)

with side-label row 4 width 48 centered frame dat.
/*	skip with side-label row 5 centered frame dat .*/

update dt1 dt2 if1 with frame dat.


def frame fhelp "<Tab> - Переход между окнами " colon 1 "<F1> - Сохранение" colon 40 skip
with side-label with row 18 column 4 frame fhelp.



define stream rep.

output stream rep to myreport.html.


put stream rep unformatted

    "<html>" skip
    "<head>" skip
          "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
          "<title>Отчет по переводам физ.лиц</title>" skip
             "<style type= text/css>" skip
             "TABLE \{ border-collapse: collapse; mso-number-format:\"\\@\"; \}" skip
             "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width= 80% border=1 cellspacing= 0 cellpadding= 0>" skip
    "<tr align= center>" skip
    "<td colspan=7>" skip.
	if if1 = '1' then put stream rep unformatted "Отчет по переводам физ.лиц без открытия счета" skip.
	else  put stream rep unformatted "Отчет по переводам физ.лиц со счета" skip.

put stream rep unformatted

    "</td>" skip
    "</tr>" skip
    "<tr align= center>" skip
    "<td colspan=7>Дата формирования " + string(today, "99/99/99") + " за период с " dt1 " по " dt2 "</td>" skip
    "</tr>" skip
    "<tr style= 'font:bold; font-size:x-small;' bgcolor='#C0C0C0'>" skip
    "<td>Дата</td>" skip
    "<td>Филиал</td>" skip.

	if if1 = '2' then put stream rep unformatted "<td>Счет<br>клиента</td>" skip.

put stream rep unformatted

    "<td>Вид</td>" skip
    "<td>Сумма</td>" skip
    "<td>Валюта</td>" skip
    "<td>Сумма в тыс.тенге</td><td>Детали</td></tr>" skip.


output stream rep close.


if if1 = '1' then if1 = 'perfl-txb.p'.
else if1 = 'perfl-txb2.p'.


/*run txbs(if1).*/

/******************************************************************************/

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run value(if1).
    end.
    if connected ("txb")  then disconnect "txb".
end.
else  do:
    find first comm.txb where comm.txb.consolid and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run value(if1).
    end.
    if connected ("txb")  then disconnect "txb".
end.

/******************************************************************************/


define stream rep.

output stream rep to myreport.html append.





put stream rep unformatted "</table></body></html>".

output stream rep close.

/*unix silent cptwin myreport.html explorer. */
unix silent cptwin myreport.html excel.