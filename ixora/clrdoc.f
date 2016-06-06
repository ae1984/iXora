/* clrdoc.f
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

def {1} shared frame clrdoc ree.npk  label "Nr." 
     ree.bank label "Бнк" 
     ree.quo  label "Кол-во" format "zzzzz9"
     ree.kopa label "Сумма             "
with no-label column 1 overlay row 6 10 down .
form "  Итого:" nnsum format "zzzzz9" at 10 
                  vvsum format "zzz,zzz,zzz.99" at 21 
 with color input no-label no-box row 21 column 1 frame kopp.
