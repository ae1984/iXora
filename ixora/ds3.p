/* ds2.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/




{global.i}

  def var v_num   as char.
  def var v_rnn   as char.
  def var v_pass  as char.
  def var v_pass2 as char.
  def var i-ind as integer.

  def var v_spf as char.
  def var v_spf1 as integer.
  def var str_p as char.
  def var v_pass3 as char.

  define frame frame1  skip(2)
   v_spf label   "Наименование СПФ              "  format "x(30)" skip
   v_pass3 label  "Пароль налогового инспектора  "  format "x(25)" blank skip(2)
  with side-labels centered row 9.


  define frame frame2
   v_spf label   "Наименование СПФ              "  format "x(30)" skip
    v_num label   "Регистрационный номер системы "  format "x(25)" skip
    v_rnn label   "Номер налогоплательщика       "  format "x(25)" skip(2)

    v_pass label  "Пароль налогового инспектора  "  format "x(25)" blank skip
    v_pass2 label "Подтверждение пароля          "  format "x(25)" blank skip
  with side-labels centered row 9.


on help of v_spf in frame frame1 do:
   str_p = "".

       for each ppoint  no-lock :
         str_p = str_p + string (ppoint.name) + "|".
       end.


       run sel ("Выберите подразделение", str_p).
       i-ind = 0.
       for each ppoint   no-lock :
          i-ind = i-ind + 1.
          if i-ind = int(return-value) then do:
             v_spf = ppoint.name.
             v_spf1 = ppoint.depart.
             displ v_spf with frame frame1.     
             leave.
          end.
       end.
end.

on help of v_spf in frame frame2 do:
   str_p = "".

       for each ppoint  no-lock :
         str_p = str_p + string (ppoint.name) + "|".
       end.


       run sel ("Выберите подразделение", str_p).
       i-ind = 0.
       for each ppoint   no-lock :
          i-ind = i-ind + 1.
          if i-ind = int(return-value) then do:
             v_spf = ppoint.name.
             v_spf1 = ppoint.depart.
             displ v_spf with frame frame2.     
             leave.
          end.
       end.
end.

        

 /*  find last sysc where sysc.sysc = "ipass" exclusive-lock no-error. */

  update v_spf v_pass3 with frame frame1.

  find last insp where insp.point = v_spf1 exclusive-lock no-error.
  if avail insp then do:
   if encode(v_pass3) <> insp.pass then do:
      message "Неверный пароль" view-as alert-box question buttons ok title "" .
      return.
   end.
   else
   do:
   message "Вы действительно хотите войти в режим налогового инспектора?" view-as alert-box question buttons yes-no title "" update r as logical.
   if r then do:
        displ  v_spf with frame frame2.
        update v_num v_rnn v_pass v_pass2 with frame frame2.
        if v_pass <> v_pass2 then do:
           message "Пароли не совпадают" view-as alert-box question buttons ok title "" .
        end.
        else
        do:

           if not avail insp then
           create insp.

           insp.point = v_spf1. 
           insp.name  = v_spf .
           insp.bks   = v_num .
           insp.pass  = encode(v_pass).
           insp.rnn   = v_rnn.
find last  depaccnt where depaccnt.depart = v_spf1 exclusive-lock no-error.
if avail depaccnt then do:
   entry(1,depaccnt.rem,'$') = v_num.
end.

           message "Перерегистрация выполнена" view-as alert-box question buttons ok title "" .
        end.
   end.
   end.
  end.
  else do:
     message "Неверный пароль" view-as alert-box question buttons ok title "" .      
  end.





