/* hwr.p
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

/* ==============================================================
=								=
=		Statement Generator History Creating		=
=			      Utility				=
=								=
============================================================== */

define shared variable g-ofc as character.

{header-t.i "shared"}

define input parameter in_cif 		like cif.cif.
define input parameter in_account	like aaa.aaa.
define input parameter in_seq 		as decimal.
define input parameter in_sts		as character.
define input parameter in_date_from	as date.
define input parameter in_date_to 	as date.
define input parameter in_mode		as character.

do transaction:

   create stgenhi.
     stgenhi.cif = in_cif.
     stgenhi.account = in_account.
     stgenhi.gen_date = today.
     stgenhi.seq = in_seq.
     stgenhi.sts = in_sts.
     stgenhi.who = g-ofc.
     stgenhi.tm  = time.
     stgenhi.d_from = in_date_from.
     stgenhi.d_to   = in_date_to.
     stgenhi.mode = in_mode.	

   create s-hi.
     s-hi.rec_id = recid(stgenhi).

end.


return "0".
