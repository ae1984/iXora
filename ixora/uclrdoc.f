/* uclrdoc.f
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

def {1} shared frame uclrdoc 
     oree.npk  label "Nr." 
     oree.cwho label "Контролер" 
     oree.quo  label "Кол-во" format "zzzzz9"
     oree.kopa label "Сумма             "
with no-label column 1 overlay row 6 11 down .
form "  Итого:" nsum format "zzzzz9" at 10 
                  vsum format "zzz,zzz,zzz.99" at 21 
 with color input no-label no-box row 21 column 1 frame ukopp.
