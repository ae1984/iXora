/* k-kbk.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Контроль кода КБК
 * RUN
        run k-kbk(output v-pr).
 * CALLER
        ispognt.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-3 
 * AUTHOR
        12/04/05 saltanat
 * CHANGES
*/

def output parameter v-pr as char init '0'.
def shared var s-remtrz like remtrz.remtrz .
def var v-kbk as char init ''.

find first remtrz where remtrz.remtrz  = s-remtrz  no-lock no-error.
if not avail remtrz then do:
   message "Не найден платеж!".
   return.
end.   

if index(remtrz.rcvinfo[1],"/TAX/") = 0 then return.

v-kbk = trim(remtrz.ba) .
if substr(v-kbk,1,1) = "/" then v-kbk = trim(substr(v-kbk,2)).
if index(v-kbk,"/") ne 0 then v-kbk = substr(v-kbk,index(v-kbk,"/") + 1,6) .

if v-kbk = '' then v-pr = '1'.
else do:
 	find budcodes where string(budcodes.code) = v-kbk no-lock no-error.
   	if not avail budcodes then v-pr = '2'. 
end.

if v-pr ne '0' then 
do:
	if v-pr = '1' then 
			message "Нет кода БК!".
	else 
		if v-pr = '2' then 
				message "Не найден код БК в справочнике!".
	pause.
end.
return.