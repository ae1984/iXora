/* sign_main.p
 * MODULE
        Потребительские кредиты - замена подписей
 * DESCRIPTION
        Стартовая программа
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        11/06/2008 madiyar
 * BASES
        BANK
 * CHANGES
*/

{mainhead.i}

def var v-sel as integer no-undo.
repeat:
    run sel2 (" ВЫБЕРИТЕ: ", " 1. Копирование данных в активные | 2. Редактирование данных | 3. Выход ", output v-sel).
    
    if v-sel = 1 then run sign_cp.
    else
    if v-sel = 2 then run sign_ed.
    else return.
end.
