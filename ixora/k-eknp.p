/* k-eknp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Контроль на заполнение кода ЕКНП
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
        11/03/04 - suchkov - Добавлена проверка на наличие кода ЕКНП в справочнике
	03.03.2005 - u00121 перекомпиляция
*/

def output parameter v-pr as char init '0'.
def shared var s-remtrz like remtrz.remtrz .
def var v-rez as char.           /* признак резиденства из платежки */
def var v-sec as char.           /* код сектора экономики */
def var v-rezc as char.          /* признак резиденства из справочника  */
def var v-secc as char.          /* код сектора экономики */
find sub-cod where sub-cod.acc = s-remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = 'eknp'and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.

if not avail sub-cod then 
			v-pr = '1'. 
else
	if (entry(1,sub-cod.rcode,',') eq ''
		or entry(2,sub-cod.rcode,',') eq ''
			or entry(3,sub-cod.rcode,',') eq '') then v-pr = '1'.
				else if entry(1,sub-cod.rcode,',') ne '' then 
	do:
		v-rez = substr(sub-cod.rcode,1,1).
		v-sec = substr(sub-cod.rcode,2,1).
		/* suchkov - Проверка на наличие кода ЕКНП в справочнике */
		find codfr where codfr.codfr = "spnpl" and codfr.code = substr(sub-cod.rcode,7,3) no-lock no-error.
		if not available codfr then 
				v-pr = '1'.      

		/* признак резиденства */  
		find first remtrz where remtrz.remtrz  = s-remtrz  no-lock no-error.
		find aaa where aaa.aaa = remtrz.sacc  no-lock no-error.
		if not avail aaa then 
					return.

		find cif where cif.cif = aaa.cif no-lock no-error.
		if avail cif  then 
		do:
			if substr(cif.geo,3,1) eq '1' then 
							v-rezc = '1'.
			else 
							v-rezc = '2'.
			if v-rez ne v-rezc then 
							v-pr = '2'.
		end.
		/* сектор экономики */
		find sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'secek' no-lock no-error.
		if not avail sub-cod then 
					v-pr = '3'.
		else 
			if sub-cod.ccode eq 'msc' or sub-cod.ccode ne v-sec then 
			do: 
				v-secc = sub-cod.ccode.
				v-pr = '3'.
			end.
	end. 

if v-pr ne '0' then 
do:
	if v-pr = '1' then 
			message "Необходимо проставить коды ЕКНП (см.опцию 'Справочник')!".
	else 
		if v-pr = '2' then 
				message "Необходимо сверить признак резиденства в плат.документе (" + v-rez + ") с ГЕО-кодом клиента в системе (" + v-rezc + ")!".
		else 
			if v-pr = '3' then 
					message "Необходимо сверить код сектора экономики в плат.документе (" + 
						v-sec + ")с кодом, проставленным у клиента в системе (" + v-secc + ")!".
	pause.
end.
return.