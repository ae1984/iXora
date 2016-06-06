/* hlpdeb.f
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
        05/06/2006 u00600 добавила debls.sts no-label

*/

define frame hgrp
    debgrp.des no-label
    with title "Выберите из списка, F4 - отмена"
    side-labels centered row 5 overlay 8 down.

define frame hls
    debls.ls no-label
    debls.name no-label
    debls.sts no-label
    with title "Выберите из списка, F4 - отмена" 
    side-labels centered row 2 overlay 18 down.
