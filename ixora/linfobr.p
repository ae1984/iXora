/* linfobr.p
 * MODULE
        Информация о логине пользователя
 * DESCRIPTION
        Поиск логина в филиале
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
        {r-branch.i &proc ="linfobr (input v-ofc)"}
 * CALLER
        Список процедур, вызывающих этот файл
        linfo.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        06.07.06 - u00121
 * CHANGES
 	23.10.06 u00121 - добавил field  в "for each txb.ofc"
*/

def input  param i-ofc like txb.ofc.ofc.
define shared variable v-res as log no-undo.

def shared temp-table t-temp no-undo
	field profitname as char 
	field branch as char
	field name as char.

for each txb.ofc field (txb.ofc.name txb.ofc.titcd ) where txb.ofc.ofc = i-ofc no-lock.
 	create t-temp.
 	assign
		t-temp.name  = txb.ofc.name.

	v-res = true.
	find last txb.codfr where txb.codfr.codfr = "sproftcn" and txb.codfr.code = txb.ofc.titcd  no-lock no-error.
	if avail txb.codfr then 
		t-temp.profitname = txb.codfr.name[1].
        else 
        	t-temp.profitname = "Не определен".

        find last txb.cmp no-lock no-error.
        if avail txb.cmp then
        	t-temp.branch = txb.cmp.name.
        else
        	t-temp.branch = 'Не определен'.
end.

