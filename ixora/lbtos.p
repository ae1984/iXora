/* lbtos.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отправка исходящих платежей по СМЭП
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
        19.08.2013 galina ТЗ1871
* BASES
        BANK
 * CHANGES
*/


def input parameter iddat as date. /* Дата для передачи в lb100g.p*/
def input parameter impid as char.

def shared var g-today as date .
def shared var g-ofc as cha .

def var method-return as logical.
def var j as int .

def new shared var v-text as cha format "x(78)" .
def var i as int .
def new shared var v-filelist as cha .
def var v-dir  as cha .
def shared var ddat as date .
def shared var vnum as int  .
def var n-buf AS CHA .
DEF new shared VAR V-OK AS LOG .
def var v-tmp as cha .
def var exitcod as cha initial "" .
def var v-err as cha format "x(78)" .
def var yn as log .
def var num as cha extent 20 .
def new shared var daynum as cha .
def new shared var f-name as cha .
def new shared var iui as int .
def shared var vvsum as deci.
def shared var nnsum as int.
def new shared var tot-sum like remtrz.amt .
def new shared var n-pap as int .
def new shared var n-sum like remtrz.amt .
def var list-name as cha .
def var v-unidir as cha .
def var v-uniarh as cha .
def var v-eksdir as cha .
def var v-ekscop as cha .
def var v-ekshst as cha .
def var ainum as int .
def var v-n as int .
def button uisend label " SEND " .
def button uiform label " FORM " .
def button errrec label " ErrRCV " .
def button errcor label " ErrCorr " .
DEF NEW SHARED STREAM PROT .
define new shared stream l-out .

def var v-tar as cha view-as selection-list INNER-CHARS 50 INNER-LINES 12 SORT  .
def frame ftar v-tar  with title  f-name  no-label column 10 row 3.
def frame fhelp "<V> -view " uiform " " uisend /* errrec errcor */ with row 18 column 4 no-box .

/* 19.10.2004  tsoy  */

def temp-table t-qarc
	field fname as char.

def new shared temp-table t-qout
	field fname as char.

def query qarc for t-qarc.
def query qout  for t-qout.

def browse barc
	query qarc no-lock
	display
		t-qarc.fname  format "x(35)"
	with 10 down width 38 title "АРХИВ ПЛАТЕЖЕЙ" no-labels.

def browse bout
	query qout no-lock
	display
		t-qout.fname  format "x(35)"
	with 10 down width 34 title "НОВЫЕ ПЛАТЕЖИ" no-labels.

def frame farcch
	barc help ""
	with column 40  no-label  row 2.

def frame fout
	bout help ""
	with column 4  no-label  row 2.

/*-----------------------------------------------*/

find sysc where sysc.sysc = "lbtoSMP" no-lock no-error .
if not avail sysc or sysc.chval = "" then
do:
	v-text = " ERROR !!! There isn't record lbtoSMP in sysc file !! ".
	message v-text view-as alert-box.
	run lgps.
	return .
end.
v-unidir = sysc.chval.

find sysc where sysc.sysc = "lbHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
	message v-text view-as alert-box.
	run lgps.
	return .
end.
v-ekshst = sysc.chval .

find sysc where sysc.sysc = "lbeks" no-lock no-error .
if not avail sysc or sysc.chval = "" then
do:
	v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
	message v-text view-as alert-box.
	run lgps.
	return .
end.

v-text = sysc.chval.
if substr(v-text, length(v-text), 1) <> "\/" then
	v-text = v-text + "/".

v-eksdir = v-text + "IN/" .

v-ekscop = v-text + "TRANSIT/" +
                    substr(string(year(g-today),"9999"),3,2) + "-" +
                    string(month(g-today),"99") + "-" +
                    string(day(g-today),"99") + "/OUT/".

find sysc where sysc.sysc = "lbtoSMPa" no-lock no-error .
if not avail sysc or sysc.chval = "" then
do:
	v-text = " ERROR !!! There isn't record lbtoSMPa in sysc file !! ".
	message v-text view-as alert-box.
	run lgps.
	return .
end.
v-uniarh = sysc.chval .

if v-unidir = v-uniarh then
do :
	v-text = " ERROR !!! Records lbtoSMP and lbtoSMPa are equal !! ".
	message v-text view-as alert-box.
	run lgps.
	return .
end .

form "  Итого:" nnsum format "zzzzz9" at 10
        	vvsum format "zzz,zzz,zzz.99" at 21
	with color input no-label no-box row 20 column 1 frame kopp.

daynum = string(g-today - date(12,31,year(g-today) - 1),"999") .

on tab next-frame .

on any-printable of barc in frame farcch
do:
	do j = barc:NUM-SELECTED-ROWS TO 1 by -1 transaction:
		method-return = barc:FETCH-SELECTED-ROW(j).
		GET CURRENT qarc NO-LOCK.
		find current t-qarc.
	end.


	if keylabel(lastkey) = "v" then
	do:
		v-dir = v-uniarh .
		f-name = entry(1,t-qarc.fname," ").
		if substr(f-name,index(f-name,".") + 1) ne "tar.Z" then
			unix value("joe -rdonly  " + v-dir + f-name ) .
		else
		do:
			num = "" .
			list-name = "" .
			input through value("arcview " + v-uniarh + f-name ) .
			repeat :
				import num .
				list-name = list-name +  num[7] + " " + num[8] + " "
						      + STRING(num[3],"XXXXXXXXXXX") + " " + num[4] + " "
						      + num[5] + " "
						      + num[6] +  ","  .
			end.
			input close .

			v-tar:list-items in frame ftar = substr(list-name,1,length(list-name) - 1) .
			v-tar:screen-value = entry(1,v-tar:list-items).
			v-tar:help = " <ENTER> - view <F4> - leave " .
			enable v-tar with frame ftar  .
			wait-for close of this-procedure or leave of frame ftar  .
			disable v-tar .
		end.
	end.
end. /*on any-printable of barc*/

on default-action of v-tar in frame ftar
do:
	n-buf = v-tar:screen-value .
	unix value("uttview " + v-dir + f-name + " " + entry(1,n-buf," ")).
	v-tar:screen-value = n-buf .
	v-tar:help = " <ENTER> - view <F4> - leave " .
end. /*on default-action*/

on any-printable of bout in frame fout
do:
	do j = bout:NUM-SELECTED-ROWS TO 1 by -1 transaction:
		method-return = bout:FETCH-SELECTED-ROW(j).
		GET CURRENT qout NO-LOCK.
		find current t-qout.
	end.

	if keylabel(lastkey) = "v" then
	do:
		v-dir = v-unidir .
		f-name = entry(1,t-qout.fname," ").
		if substr(f-name,index(f-name,".") + 1) ne "gz" then
			unix value("joe -rdonly  " + v-unidir + entry(1,t-qout.fname," ")) .
		else
		do:
			num = "" .
			list-name = "" .
			input through value("gzip -cd " + v-uniarh + f-name + "| gtar tvf") .
			repeat :
				import num .
				list-name = list-name + num[8] + " "
						      + STRING(num[3],"XXXXXXXXXXX") + " " + num[4] + " "
						      + num[5] + " "
						      + num[6] + " "
						      + num[7] + " "
						      +  ","  .
			end.
			input close .
				v-tar:list-items in frame ftar = substr(list-name,1,length(list-name) - 1) .
				v-tar:screen-value = entry(1,v-tar:list-items).
				v-tar:help = " <ENTER> - view <F4> - leave " .
				enable v-tar with frame ftar  .
				wait-for close of this-procedure or leave of frame ftar  .
				disable v-tar .
		end.
	end.
end . /*on any-printable of bout*/

on choose of uiform in frame fhelp
do:


    yn = false .
	Message "Are you sure ? " update yn .
	if yn then
	do:


        n-buf = string(day(g-today),"99") + string(month(g-today),"99")
						  + substr(string(year(g-today)),3) + "_" + string(vnum).
		for each t-qarc.
			if  index(t-qarc.fname,n-buf) gt 0 then
			do:
				yn = false .
				Message " SMEP " + string(vnum) + " archive has been already done. Continue  ?  " update yn .
				if not yn then
					leave .
			end.
		end.
		if not yn then
			leave .

		Message " W a i t ... " .

		run lb100s(iddat).
		if return-value = "1" then
			message "Обратитесть к Администраторам АБПК!" skip
				"Пачка  SMEP # " vnum " выгрузилась не корректно!" view-as alert-box title "Произошла ошибка выгрузки!".
	end.
end. /*on choose of uiform*/

on choose of uisend in frame fhelp
do:
	n-buf = string(day(g-today),"99") + string(month(g-today),"99")
			                  + substr(string(year(g-today)),3) + "_" + string(vnum) .
	yn = true.

	for each t-qarc.
		if  index(t-qarc.fname,n-buf) gt 0 then
		do:
			yn = false .
			Message " SMEP " + string(vnum) + " archive has been already done. Overwrite it ?  " update yn .
			if yn then leave.
		end.
	end.
	if not yn then leave .
	yn = false.
	Message "Are you sure ? " update yn .
	if yn then
	do:
		output to sendtest.
			put "Ok".
		output close .

                Message " Send test ..... " .
                input through value("scp -q sendtest " + v-ekshst + ":" + v-ekscop + ";echo $?" ).
                repeat :
                    import exitcod .
                end .

                if exitcod <> "0" then do :
                    unix silent  value("ssh " + v-ekshst + " mkdir"  +  " c:\\\\capital\\\\TERMINAL_TEST\\\\TRANSIT\\\\" +
                               substr(string(year(g-today),"9999"),3,2) + "-" +
                               string(month(g-today),"99") + "-" +
                               string(day(g-today),"99") + "\\\\OUT").
                end .

                input through value("scp -q sendtest " + v-ekshst + ":" + v-ekscop + ";echo $?" ).
                repeat :
                    import exitcod .
                end .
                if exitcod <> "0" then do :
                   v-text = "Remote EKS DIR " + v-ekshst + ":" + v-ekscop + " wasn't found ".
                   message v-text .
                   pause .
                   leave .
                end .

		v-ok = false .
		iui = 0 .
		tot-sum = 0 .
		do transaction :
			Message " C o p i n g   &   S e n d i n g ..... " .
			input through  value('tolbcop "' + daynum + '*" ' + n-buf + ' "' + v-unidir + '" ' + v-ekshst + " " + v-ekscop + ' ; echo $? ; ' +
					     'tolbarc "' + daynum + '*" ' + n-buf + ' "' + v-unidir + '" ' + v-ekshst + " " + v-eksdir + ' ; echo $? ').
			v-text = "" .
			repeat :
				import unformatted exitcod .
					v-text = v-text + exitcod .
			end .
			pause 0 .
			if exitcod <> "0" then
			do :
				v-text = "Error:" + v-text .
				message v-text .
				pause .
			end .
			else
			do:
				pause 0 .
				v-text = "Electronic messages to NB was sended by " + g-ofc .
				run lgps .
				Message "Electronic messages  to NB was sended" . pause .
			end.
		end.  /* transaction*/
	end. /* yn*/
end.  /*on choose of uisend*/


repeat :
	ainum = 0 .
	for each que where que.pid = "STW" no-lock .
		ainum = ainum + 1 .
	end.
	for each t-qout . delete t-qout . end.
	for each t-qarc . delete t-qarc . end.

	num = "" .
	list-name = "" .
	input through value("/bin/ls -lt " + v-unidir + "*.eks " +  v-unidir + "*.err " + " 2> /dev/null" ) .
	repeat :
		import num .
		create t-qout.
			t-qout.fname  = substr(num[9],length(v-unidir) + 1 ) + " " + num[6] + " " + num[7] + " " + num[8].
	end.
	input close .

	input through value("/bin/ls -lt " + v-uniarh + "*.*" + " 2> /dev/null" ) .
	repeat :
		import num .
		create t-qarc.
			t-qarc.fname  = substr(num[9],length(v-uniarh) + 1 ) + " " +  num[6] + " " + num[7] + " " + num[8] .
	end.
	input close .

	open query qarc for each t-qarc.
	open query qout for each t-qout.
	apply "VALUE-CHANGED" to BROWSE barc.
	apply "VALUE-CHANGED" to BROWSE bout.

	view frame fout .
	view frame farcch .
	view frame fhelp.

	pause 0 .

	enable uisend with frame fhelp  .
	enable uiform with frame fhelp  .

	wait-for close of this-procedure
		or any-printable of bout in frame fout
		or any-printable of barc in frame farcch
		or choose  of uisend  in frame fhelp
		or choose  of uiform  in frame fhelp
		focus uiform.

	disable uisend.
	disable bout with frame fout.
	disable barc with frame farcch.
end. /*repeat : */

hide all  .



