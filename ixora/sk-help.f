/* sk-help.f
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

define frame hgrp
    grp.grp at 6 no-label
    grp.des no-label
    with title "Выберите из списка, F4 - отмена"
    side-labels centered row 3 overlay 17 down.

define frame hitem
    item.item at 6 no-label
    item.des no-label
    with title "Выберите из списка, F4 - отмена" 
    side-labels centered row 3 overlay 17 down.

