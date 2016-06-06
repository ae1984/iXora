/* sub_kr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Разбивка всех кредитных счетов по уровням.
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
 * BASES
        BANK COMM
 * AUTHOR
        30.11.2004 id00004
 * CHANGES
*/




{global.i}

  def var d_date as date.
  def var t_time as char.

  define frame frame1
   d_date label "Введите новую дату "  skip
   t_time label "Введите новое время"  /*format "99:99:99" */
  with side-labels centered row 9.

  find last sysc where sysc.sysc = "idate" no-lock no-error.
  if avail sysc then
     d_date = date(sysc.chval).
  else
     d_date = g-today.
 
  find last sysc where sysc.sysc = "itime" no-lock no-error.
  if avail sysc then
    t_time = sysc.chval. 

  else
    t_time = string(time,"hh:mm:ss").
         
  update d_date t_time with frame frame1.
  find last sysc where sysc.sysc = "idate" exclusive-lock no-error.

  if available sysc then do:
     if date(sysc.chval) > d_date then
        message "Новая дата должна быль больше даты в ФП" view-as alert-box question buttons ok title "" .
     else do:
        sysc.chval = string(d_date).
    end.
  end.

  find last sysc where sysc.sysc = "itime" exclusive-lock no-error.
  sysc.chval = t_time. 
                                                                  