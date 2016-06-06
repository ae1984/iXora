/* rmzauto2.f
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

def var druk as logi.
def var dest as char format "x(20)" initial "prit ".


form   
 "Команда печати" at 3 skip 
"””””””””””””””””””””””””" at 1 skip 
 dest at 4 skip
with no-label  row 12 centered frame drk1.

update  dest with frame drk1.

        
