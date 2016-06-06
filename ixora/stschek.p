/* stschek.p
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
        27.11.2012 damir - Убрал проверку на stmset.
*/

/* ======================================================================
=									=
=			Statement Status Checker			=
=	      Function Returning Possible Status of Report 		=
=									=
====================================================================== */

define shared variable g-ofc 	as character.
define shared variable g-today 	as date.

define input 	    parameter 	in_cif           like cif.cif.	/* Customer's CIF	*/
define input 	    parameter	in_account	 like aaa.aaa.  /* Customer's Account 	*/
define input        parameter 	in_date_from     as date.	/* Period's Begin 	*/
define input   	    parameter 	in_date_to       as date.	/* Period's End		*/
define input-output parameter 	stmsts		 as character.	/* Report Status	*/
define output       parameter 	seq		 as decimal.	/* Report Sequence	*/

define buffer b_stgenhi for stgenhi.
define buffer a_hi      for stgenhi.

define variable iseq   as decimal.
define variable ifseq  as decimal.
define variable start_date as date.
define variable f_date as date.
define variable t_date as date.
define variable a_date as date.
define variable end_date as date.
define variable tmp_date as date.

define variable ch_date   as date.     /* New Period Date */
define variable ch_period as integer.  /* New Period */
define variable first_date as date.

{wkdef.i "shared"}
{stnextp.i}


define variable periods as integer.  /* --- Periods:	1  - DAY
							7  - WEEK
							10 - DECADA
							30 - MONTH
							90 - QUARTAL --- */

if in_date_to < in_date_from then do:
    run elog ("STSCHECK", "ERR", "Date to < Date from for :" + in_cif).
    return "1".
end.

find first stmshi where stmshi.cif = in_cif and stmshi.aaa  = in_account no-lock no-error.

if not available stmshi then do:
         run elog ("STSCHECK", "ERR", "Not found history Stattement Setting for :" + in_cif + " " + in_account).
         return "1".
end.

periods  = stmshi.period.
iseq     = stmshi.seq.
ch_date  = stmshi.pstart.
first_date = stmshi.pstart.

if stmsts <> "INF" and in_date_to < g-today then do:

	/* Original / Copy Mode: Original / Copy Status --- */


	find first stgenhi where stgenhi.cif = in_cif and
                         stgenhi.account = in_account and
                         stgenhi.active = yes and
                         stgenhi.sts = "ORG"  and
                         stgenhi.d_from = in_date_from and
                         stgenhi.d_to	= in_date_to  no-lock no-error.

   	if available stgenhi then do:    /* ---- Was created before ---- */
      	   stmsts = "CPY".
           seq = stgenhi.seq.
           return "0".
        end.


 /* ---- Processing According Report Periods ( Not Found Statement ) ---- */

           f_date = ch_date.
           t_date = f_date.
           end_date = g-today - 1.

   	   run nextp.

   	   do while t_date <= end_date :

           {stchk3.i}

     	   {stchk2.i}

     	   if ch_date <> ? and ( ch_date >= f_date and ch_date <= t_date ) then do:
              periods = ch_period.
              a_date  = ch_date - 1.
              t_date  = ch_date.

              tmp_date = ch_date.

              run nextp.

              if f_date = tmp_date then next.
     	   end.

     	      if in_date_from = f_date and ( (periods <> 0 and in_date_to = a_date ) or
     	                                     (periods = 0  and in_date_to >= in_date_from ) ) then do:
     		stmsts = "ORG".
     		seq = iseq.
     		return "0".
   	      end.

     	      iseq = iseq + 1.

   	   end.

end.

   /* --- Information Sequence Output --- */

   find first stmset where stmset.cif = in_cif and stmset.aaa = in_account exclusive-lock no-error.

   /*if not available stmset then do:
         run elog ("STSCHECK", "ERR", "Not found Statement Setting for :" + in_cif + " " + in_account).
         return "1".
   end.*/
   if avail stmset then do:
     stmsts = "INF".
     seq = stmset.iseq.

     stmset.iseq = stmset.iseq + 1.
   end.

 return "0".



