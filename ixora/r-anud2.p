/* r-anud2.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам с группировкой по наименованию, валюте и ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	r-anud2-txb.p
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        04/08/2004 sasco
 * CHANGES
        06/04/2005 suchkov 	- 	Изменир расчет. Теперь остатки берутся из histrxbal а не из aab

        09.05.2005 dpuchkov	- 	добавил Актюбинск

        10/04/2006 u00121	-	Изменил принцип конектов к филиалам, теперь это будет происходить через {r-branch.i}.
                        Собирательство вынесенно в отдельную программу - r-anud2-txb.p
                        Алгоритм собирательства данных не менял.
                        Добавил сообщение о завершении формирования отчета и времени формирования отчета.

        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/

{msg-box.i}
{gl-utils.i}

def var datDate as date 				no-undo.
def var sum$ 	as dec format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var col$ 	as int 					no-undo.
def var totcol$ as int 					no-undo.
def var totsum$ as dec format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var fFl 	as log init true			no-undo.

def new shared var v-tm as int no-undo.

def new shared temp-table tfl$ no-undo
	field tgl like txb.aaa.gl
	field tacc like txb.aaa.aaa
	field tlgr like txb.aaa.lgr
	field tsum like txb.aaa.cbal
	field tfil as char
	field crc as integer
	field texp like txb.aaa.expdt
	field des like txb.lgr.des
	index main tgl crc tlgr.

def stream  m-out.
def shared var g-today as date.

{functions-def.i}

v-tm = time.

datDate = g-today.

display datDate label "На какую дату" with row 8 centered side-labels frame opt title "Введите".

update datDate with frame opt.

hide frame opt.

def button cmdFiz label "Физ.лица".
def button cmdUr label "Юр.лица".
def frame frmMain skip(1) cmdFiz cmdUr with centered row 5.

on choose of cmdFiz, cmdUr
do:
	if self:label = "Физ.лица" then
	do:
		fFl = true.
	end.
	else
		if self:label = "Юр.лица" then
		do:
			fFl = false.
		end.
end.

enable all with frame frmMain.
wait-for choose of cmdFiz, cmdUr.
hide frame frmMain.



/******************************************************************************/

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-anud2-txb(datDate, fFl).
    end.
    if connected ("txb")  then disconnect "txb".
end.
else  do:
    find first comm.txb where comm.txb.consolid and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-anud2-txb(datDate, fFl).
    end.
    if connected ("txb")  then disconnect "txb".
end.

/******************************************************************************/

/******************************************************************************/

hide all.

run SHOW-MSG-BOX ("Вывод в файл").

output to rpt.csv.

	put unformatted "Филиал;ГК;Валюта;Группа;Описание;Сумма;Количество" skip.

	for each tfl$ break by tfl$.tfil by tfl$.tgl by tfl$.crc by tfl$.tlgr:
		accumulate tfl$.tsum (total by tfl$.tfil by tfl$.tgl by tfl$.crc by tfl$.tlgr).
		accumulate tfl$.tsum (count by tfl$.tfil by tfl$.tgl by tfl$.crc by tfl$.tlgr).

		totsum$ = totsum$ + tfl$.tsum.
		totcol$ = totcol$ + 1.
		sum$ = sum$ + tfl$.tsum.
		col$ = col$ + 1.

		if last-of(tfl$.tlgr) then
		do:
			put unformatted
				tfl$.tfil ";"
				tfl$.tgl ";"
				tfl$.crc ";"
				tfl$.tlgr ";"
				tfl$.des ";"
				XLS-NUMBER (DECIMAL(accum sub-total by tfl$.tlgr tfl$.tsum)) ";"
				XLS-NUMBER (DECIMAL(accum sub-count by tfl$.tlgr tfl$.tsum))
				skip.
		end.

		if last-of(tfl$.tfil) then
		do:
			sum$ = 0.
			col$ = 0.
		end.
	end.
output close.

unix silent cptwin rpt.csv excel.
/******************************************************************************/

message "Отчет сформирован." skip "Время формирования " string(time - v-tm , "HH:MM:SS") view-as alert-box.




