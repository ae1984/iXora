/* trsprt.p
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


def shared var s-remtrz like remtrz.remtrz .
def var tra as char.

find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.

if available remtrz and remtrz.t_sqn ne "" and remtrz.source = 'IBH' then do :
  tra = trim(remtrz.t_sqn).
  display "Ж Д И Т Е !" with centered frame www . pause 0 .
/* if remtrz.source = "H" then 
  unix silent value("larc -s " + tra + " -F f > tmpqq_ps.img ").
 else 
  if remtrz.source = "SW" then
  unix silent value("swiarc " + tra + " | swtrans -1 >  tmpqq_ps.img ").
     if remtrz.source = "IBH" then do :*/

       find sysc where sysc.sysc = "IBHOST" no-lock no-error .
       if not avail sysc or sysc.chval = "" then do :
         message "Отсутствует запись UNIARH в таблице SYSC!" .
         pause .
         return .
       end .
       if not connected("ib") then connect value(sysc.chval) no-error .
       if not connected("ib") then do :
          message "Отсутствует соединение с базой данных Интернет Оффиса!" .
          pause .
       end .
       else do :
	   run prtppp.
/*         run IBHprit_ps(integer(remtrz.t_sqn)) .*/
       end .
/*     end .*/
  
  
  
  hide frame www.
/*  unix prit tmpqq_ps.img.  */
end.
else
 do:
/*  Message  " Транспортная ссылка пуста! " .  pause . */
       find sysc where sysc.sysc = "IBHOST" no-lock no-error .
       if not avail sysc or sysc.chval = "" then do :
         message "Отсутствует запись UNIARH в таблице SYSC!" .
         pause .
         return .
       end .
       if not connected("ib") then connect value(sysc.chval) no-error .
       if not connected("ib") then do :
          message "Отсутствует соединение с базой данных Интернет Оффиса!" .
          pause .
       end .

       run prtppp.

 end .
