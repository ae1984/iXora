/* rmzprn.p
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
        07/06/2007 madiyar - исходник завершался некорректно, исправил
*/

def new shared var s-remtrz like remtrz.remtrz.
update s-remtrz label "Платежный документ" with centered frame qfrm.
hide frame qfrm.
find first remtrz where remtrz = s-remtrz no-lock no-error.
if not avail remtrz then do:
    message "Платеж не найден".
    return.
end.    
if fcrc <> 1 or tcrc <> 1 then do:
message "Платеж не в нац валюте".
    return.
end.
run payprn.
