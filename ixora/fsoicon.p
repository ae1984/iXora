/* fsoicon.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Основные источники привлечения денег
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16.04.2004 valery
 * BASES
	BANK, COMM
 * CHANGES
	04.08.2006 u00121 - добавил индекс в t-cif (idx0-t-cif), проставил no-undo.
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def var i as int no-undo.

def var v-file as char init "fsoi2004.html" no-undo.
def new shared var v-dt as date no-undo.

def new shared temp-table t-cif no-undo
	field cif like cif.cif
	field prefix like cif.prefix
	field name like cif.name
	field rnn like cif.jss
	field code as char format "x(3)"
	field DDA as decimal format "zzz,zzz,zzz,zz9.99-"
	field CDATDA as decimal format "zzz,zzz,zzz,zz9.99-"
	field sum as decimal format "zzz,zzz,zzz,zz9.99-"
	index sum is primary sum DESCENDING
	index idx0-t-cif cif.

update v-dt label "Дата отчета".

hide all.


{r-branch.i &proc = "fsoi (comm.txb.bank)"}
/*
if not connected ("comm") then run conncom.


for each comm.txb where comm.txb.consolid = true no-lock:
	if connected ("ast") then disconnect "ast".
	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password).
    	run fsoi (comm.txb.bank).
end.

if connected ("ast")  then disconnect "ast".
*/
output to value(v-file).


{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
  "<P align=""center"" style=""font:bold"">Основные источники привлечения денег</P>" skip
  "<P align=""center"" style=""font:bold"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
	  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
	    "<TD>Номер<br>п/п</TD>" skip
	    "<TD>Наименование депозитора (кредитора)</TD>" skip
	    "<TD>РНН</TD>" skip
	    "<TD>Код<br>отрасли</TD>" skip
	    "<TD>Корреспондентские/<br>текущие<br>счета</TD>" skip
	    "<TD>Срочный<br>вклад</TD>" skip
	    "<TD>ИТОГО</TD>" skip
	  "</TR>" skip.

def var sumtys as decimal no-undo.
def var sumtysdda as decimal no-undo.
def var sumtyscdatda as decimal no-undo.

i = 0.

for each t-cif no-lock. /*вытаскиваем первых 25 клиентов*/
	sumtys = t-cif.sum / 1000.
	sumtysdda = t-cif.DDA / 1000.
	sumtyscdatda = t-cif.CDATDA / 1000.
	if sumtys > 0 then
	do:
		i = i + 1.
		put unformatted
		  "<TR>" skip
		    "<TD>" i "</TD>" skip
		    "<TD>" t-cif.prefix " " t-cif.name "</TD>" skip
		    "<TD>&nbsp;" t-cif.rnn "</TD>" skip
		    "<TD>" t-cif.code "</TD>" skip
		    "<TD>" replace(string(sumtysdda, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
		    "<TD>" replace(string(sumtyscdatda, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
		    "<TD>" replace(string(sumtys, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
		  "</TR>" skip.
	end.
/*
	if i = 25 then do:
	    leave.
	end.
*/
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.
hide all.
unix silent cptwin value(v-file) excel.

pause 0.
