/* stmlist.i
 * MODULE
        ======================================================================
        =                                                                    =
        =                Statement Generator's History Checker               =
        =                                                                    =
        ======================================================================
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
        11/03/2004 - suchkov - Исправлена ошибка "Не найдена история выписок"
*/



in_account = s-hacc.

define variable tmp_date as date.

find first stmshi where stmshi.cif = in_cif and stmshi.aaa = in_account no-lock no-error.   

if not available stmshi then do:
     find aaa where aaa.aaa = in_account no-lock .
     create stmshi.
     assign
     stmshi.cif = aaa.cif
     stmshi.aaa = aaa.aaa
     stmshi.seq = 1
     stmshi.period = 1
     stmshi.pstart = aaa.whn
     stmshi.who    = g-ofc
     stmshi.data   = g-today. 
   /*  suchkov - Убрал, потому что больше не нужно .
   run elog("STMLIST","ERR", "Statement Settings History not found for CIF:" + in_cif + " " + in_account + " . Terminated.").
   message "Не найдена история выписок для клиента:" + in_cif + " счет " + in_account + " . Выполнение прервано.". pause 10.
   return "1".
     */
end.

periods    = stmshi.period.
iseq       = stmshi.seq.
ch_date    = stmshi.pstart.
first_date = stmshi.pstart.


for each stml. 
  delete stml. 
end. 

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
         else do:
               stml.sts = "ORG".      
              end.
         end.
          
         iseq = iseq + 1.                           

       end.

  end. /* do while ... */ 

find first stml no-error.

if not available stml then do:
     j_stmsts = 'INF'.
end.
else do:
   run stmla.
end.




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
                stml.active  format 'x(1)'
                stml.seq     format 'zzzzz9'
                stml.d_from  format '99/99/99'
                stml.d_to    format '99/99/99'
                stml.sts     format 'x(3)'
                stml.who     format 'x(8)'
                stml.whn     format '99/99/99'
             "
&highlight = "stml.seq"
&postkey   = " 
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
                 else 
                 if keyfunction(lastkey) = 'return' then do:
                    define buffer b-stml for stml.

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
                    hide frame f_stgen.
                    leave upper.
                 end.
             "
&end =       " hide frame f_stgen."
}

end.


