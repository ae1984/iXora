/* 150cifs.p
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
 * CHANGES
*/

/* KOVAL Формирование общего перечня клиентов и счетов перечня */


def input parameter ourcode as integer.

def shared temp-table clients
field ourcode as integer format "9"
field cif 	like ast.cif.cif
field ownform	as char format "x(10)"
field name 	like ast.cif.name
field sname 	like ast.cif.sname
field point 	like ast.cif.point
field depart 	like ast.cif.depart
index ourcode is primary ourcode
index cif cif.

def shared temp-table accounts
field t 	as char format "x(3)"
field cif 	like ast.cif.cif
field aaa 	like ast.aaa.aaa
field ourbik  as char format "x(9)"
index cif cif
index aaa aaa
index ourbik ourbik
.

def var tmp as char.
def var ourbik as char.

find first ast.sysc where ast.sysc.sysc = "CLECOD" no-lock no-error.
ourbik=trim(ast.sysc.chval).

for each ast.cif no-lock.
        tmp="".

        /* выберем юридические... 
        find first ast.sub-cod where 
                   ast.sub-cod.d-cod = 'clnsts' and ast.sub-cod.ccode = '0' and 
                   ast.sub-cod.sub = 'cln'      and ast.sub-cod.acc   = string( ast.cif.cif ) 
                   no-lock no-error.

        if avail ast.sub-cod then do:*/

 	 create clients.

	 assign
	 clients.ourcode = ourcode
	 clients.cif 	 = ast.cif.cif
	 clients.ownform = trim(ast.cif.prefix)
	 clients.name 	 = trim(ast.cif.name)
	 clients.sname 	 = trim(ast.cif.sname)
	 clients.point 	 = ast.cif.point
	 clients.depart  = ast.cif.depart.
	
 	 for each ast.aaa where ast.aaa.cif=ast.cif.cif and ast.aaa.sta<>"C" no-lock.
 		create accounts.
		assign accounts.cif = ast.aaa.cif
		       accounts.aaa = ast.aaa.aaa
		       accounts.ourbik = ourbik
		       accounts.t = "aaa"
		       .
	 end.
/*	end. */
end.

/* Соберем и другие счета */

 	 for each ast.arp where no-lock.
 		create accounts.
		assign accounts.cif = ast.arp.cif
		       accounts.aaa = ast.arp.arp
		       accounts.ourbik = ourbik
		       accounts.t = "arp"
		       .
	 end.

 	 for each ast.fun where no-lock.
 		create accounts.
		assign accounts.cif = ?
		       accounts.aaa = ast.fun.fun
		       accounts.ourbik = ourbik
		       accounts.t = "fun"
		       .
	 end.
