/* checmek.p
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
 * BASES
        BANK
 * CHANGES
        07/10/2009 galina - забросила в библиотеку 
*/

/* checmek.p - Klientu meklё+ana pёc -eka numura
*/

define new shared var s-aaa like aaa.aaa.
def var chnu as int format "9999999".
def var c-cif like checks.cif.
def var c-reg like checks.regdt.
def var c-who like checks.who.


{mainhead.i}

repeat:
   message "Введите номер чека".
   update chnu label "НОМЕР ЧЕКА"
   with side-labels  frame vasa.
   find first checks where checks.nono le chnu and
                     checks.lidzno ge chnu no-lock no-error.
   if not available checks then do:
    message
    "Чековая книжка с таким номером не продана".
/*   leave.    */
   end.
   else do:
   c-cif = checks.cif.
   c-reg = checks.regdt.
   c-who = checks.who.
   disp
   c-cif label "КОД КЛИЕНТА"
   with no-label frame kola.
   find cif where cif.cif =c-cif no-lock no-error.
   if not available cif then do:
    message
    "Клиента с таким кодом нет в системе. ВВедите код клиента корректно".
   end.
   else do:
     disp trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname label ""
     c-reg label "ДАТА РЕГИСТРАЦИИ"
     c-who label "ИСПОЛНИТЕЛЬ"
     with frame kola.
   end.
end.
end.
