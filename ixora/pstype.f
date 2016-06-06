/* pstype.f
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
        06.10.2003 nadejda  - изменила формат вывода (побольше символов для кода процесса)
*/

form route.ptype column-label "Тип"  format "x(2)"
   route.pid column-label "Код проц." format "x(8)"
   v-name column-label "Описание" format "x(30)"
   route.rcod column-label "Код заверш."  format "x(5)"
   npc column-label "След. процесс" format 'x(8)'
    with centered row 3 down frame ptype.
