/* stmclist.i
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
=           Statement Generator's History Checker                        =
=                                                                        =
====================================================================== */

in_account = s-hacc.


find first stmshi where stmshi.cif = in_cif and stmshi.aaa = in_account no-lock no-error.

if not available stmshi then do:
   run elog("STMLIST","ERR", "Statement Settings History not found for CIF:" + in_cif + " " + in_account + " . Terminated.").
   return "1".
end.
st-today = g-today.
periods    = stmshi.period.
iseq       = stmshi.seq.
ch_date    = stmshi.pstart.
first_date = stmshi.pstart.


for each stml. delete stml. end. 

  f_date = ch_date.
  t_date = f_date.
  end_date = g-today - 1. 

  if clo_date ne ? and end_date > clo_date then end_date = clo_date.
  st-today = end_date + 1.

  run nextp.


  do while t_date <= end_date :
     
     {stchk3.i} 

     {stchk2.i}

     /*message "ch_date: " ch_date skip 
              "f_date: " f_date skip 
               "t_date:" t_date view-as alert-box title "CH-DATE". */

     if ch_date <> ? and (ch_date >= f_date and ch_date <= t_date) then do:
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

 
       if a_date < g-today then do transaction:
         if f_date >= a_start then do: /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11 */

           create stml.
           stml.aaa = in_account.
              stml.seq = iseq.
              stml.d_from = f_date.
              stml.d_to   = a_date.
          
           if available stgenhi then do:
               stml.sts = "CPY". 
               stml.who = stgenhi.who.
               stml.whn = stgenhi.gen_date.
           end.
         else stml.sts = "ORG".      
         end.
          
         iseq = iseq + 1.                           

       end.

  end. /* do while ... */ 

{stchk0.i}
/* {stchkcls.i} */
find first stml no-error.

if not available stml then j_stmsts = 'INF'. else run stmla.


procedure stmla:

{jabro.i

&start     = " "
&head      = "stml"
&headkey   = "stml"
&index     = "intrf_idx"
&formname  = "f_stgen"
&framename = "f_stgen"
&where     = " "
&addcon    = "false"
&deletecon = "false"
&predelete = " " 
&precreate = " "
&postadd    = " " 
&prechoose = " "
&predisplay = " "
&display   = "
             /* stml.active  format 'x(1)' */
               	stml.seq     format 'zzzzz9'
               	stml.d_from  format '99/99/99'
               	stml.d_to    format '99/99/99'
               	stml.sts     format 'x(3)'
               	stml.who     format 'x(8)'
               	stml.whn     format '99/99/99'
             "
&highlight = "stml.seq"
&postkey   = " 
                 /* -------------------------------------------------------------
                 else
                 if keyfunction(lastkey) = 'go' then do:
                    find stml where recid(stml) = crec exclusive-lock no-error.
                    
                    if stml.active  = '*' then 
                        stml.active = ''.
                    else
                        stml.active = '*'. 

                    display stml.active with frame f_stgen.
                    release stml. 
                 end.
                 ------------------------------------------------------------------ */
                 else 
                 if keyfunction(lastkey) = 'return' then do:
                    define buffer b-stml for stml.

                    find b-stml where recid(b-stml) = crec exclusive-lock no-error.
                    df = b-stml.d_from.
                    dt = b-stml.d_to.
                    j_stmsts = b-stml.sts.

                    /* ----------------------------------------------------------------
                    find first b-stml where b-stml.active = '*' no-lock no-error.
                    if not available b-stml then do:
                       find b-stml where recid(b-stml) = crec exclusive-lock no-error.
                       b-stml.active = '*'.
                       df = b-stml.d_from.
                       dt = b-stml.d_to.
                       j_stmsts = b-stml.sts.
                    end.
                    
                    for each stml where stml.active <> '*'.
                        delete stml.
                    end.
                    ----------------------------------------------------------------- */

                    hide frame f_stgen.
                    leave upper.
                 end.
             "
&end =       " hide frame f_stgen."
}

end.


