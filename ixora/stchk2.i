/* stchk2.i
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

case periods:

     when 0 then do:     /* === Without Period === */
       
       find first a_hi where a_hi.cif = in_cif and
                            a_hi.account = in_account and
                            a_hi.sts = "ORG" and
                            a_hi.active = yes and
                            a_hi.d_from >= f_date no-lock no-error.
       
       if available a_hi then do:
          f_date = a_hi.d_from.  
          t_date = a_hi.d_to.
          a_date = t_date.
       end.
       else do:
             t_date = g-today.
             a_date = t_date - 1. 
       end.
     end.

     when 1 then do: /* === DAY === */

       t_date = f_date + periods .
       a_date = t_date - 1.
       
          do while ( weekday(t_date) = (wkend + 1 ) or
                     weekday(t_date) = (wkstrt - 1) or   
                     can-find ( hol where hol.hol = t_date ) ) and
                     month(f_date) = month(t_date) :
           
            t_date = t_date + 1.
            a_date = t_date - 1. 
          end.

     end. 

     when 7 then do: /* === WEEK === */

       /* === From Date Tuning === */

       tmp_date = f_date.

       do while weekday(tmp_date) <> 2:
          tmp_date = tmp_date - 1.
       end.    

       /* ======================== */

       
       t_date = tmp_date + periods .
       a_date = t_date - 1.

       do while month(a_date) > month(f_date) :
          t_date = t_date - 1.
          a_date = t_date - 1.
       end. 
     end. 

     when 10 then do: /* === 10 DAYS === */

       /* === From Date Tuning === */
       
       tmp_date = f_date.

       do while day(tmp_date) <> 1 and day(tmp_date) <> 11 and day(tmp_date) <> 21 :
          tmp_date = tmp_date - 1.
       end.    

       /* ========================= */ 

       t_date = tmp_date + periods .

       if day(t_date) > 21 then do:
          if month(tmp_date) + 1 = 13 then
            t_date = date(01 , 1, year(tmp_date) + 1). 
          else 
            t_date = date(month(tmp_date) + 1, 1, year(tmp_date)). 
       end.
       else do:
          if day(t_date) > 1 and day(t_date) < 10 then 
              t_date = date(month(tmp_date) + 1, 1, year(tmp_date)). 
       end. 
   
       a_date = t_date - 1.
       
       if year(tmp_date) <> year(a_date) then next.
     end. 
     
     when 30 then do: /* === MONTH === */

       if month(f_date) + 1 = 13 then
       	t_date = date(01, day(f_date), year(f_date) + 1).
       else
       	t_date = date(month(f_date) + 1, day(f_date), year(f_date)) .
       a_date = t_date - 1.       
     end. 
     
     when 90 then do: /* === QUARTAL === */

       if month(f_date) + 3 = 13 then 
       	t_date = date(01, day(f_date), year(f_date) + 1) .
       else 
       	t_date = date(month(f_date) + 3, day(f_date), year(f_date)) .
       a_date = t_date - 1.
     end. 
     
end. /* case ... */ 
