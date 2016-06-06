/* astst.p
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

def shared var s-jh like jl.jh.
def var otv as log.
hide message no-pause.
repeat:
 otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет". 
 if  otv then do: 
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvou.  pause 0.
 end.
 else leave.
end.
 otv=true.
 message "  ОПЕРАЦИЮ АКЦЕПТОВАТЬ ?  " UPDATE otv format "да/нет". 
 if  otv then do: run jl-stmp. end.
 find jh where jh.jh=s-jh  no-lock no-error.
 if jh.sts=6 then Message "Операция Nr." + string(jh.jh) + " АКЦЕПТОВАНА " .
             else Message "Операция Nr." + string(jh.jh) + " НЕ АКЦЕПТОВАНА " .
pause 10.
