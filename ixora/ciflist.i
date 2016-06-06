/* ciflist.i
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

/* ======================================================================
=                                                                        =
=                Statement Generator's History Checker                        =
=                                                                        =
====================================================================== */


for each stml. 
      delete stml. 
  end. 

for each aaa where aaa.cif = in_cif and aaa.sta <> "C" no-lock: 
find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
if lgr.led eq "ODA" then next. 

in_account = aaa.aaa.

find first stmshi where stmshi.cif = in_cif and stmshi.aaa = in_account no-lock no-error.

if not available stmshi then do:
   run elog("STMLIST","ERR", "Statement Settings History not found for CIF:" + in_cif + " " + in_account + " . Terminated.").
   return "1".
end.


periods = stmshi.period.
iseq    = stmshi.seq.
ch_date = stmshi.pstart.
first_date = stmshi.pstart.


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


     find first stgenhi where stgenhi.cif     = in_cif     and
                              stgenhi.account = in_account and
                              stgenhi.sts     = "ORG"     and
                              stgenhi.active  = yes        and
                              stgenhi.d_from  = f_date     and
                              stgenhi.d_to    = a_date no-lock no-error.
 
       if a_date < g-today  then do transaction:
        if f_date >= a_start then do: /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11 */
         
          if not available stgenhi then do: 
           create stml.
           stml.aaa = in_account.
              stml.seq = iseq.
              stml.d_from = f_date.
              stml.d_to   = a_date.
           stml.sts = "ORG". 
           stml.active = "*". 
          end.
        end.
          
         iseq = iseq + 1.                           

       end.

  end. /* do while ... */ 
end. /* for each aaa ... */

