/* astotv.f
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

/* 22/04/96 FORM LIKE file astotv */

FORM
astotv.kotv FORMAT "x(3)" LABEL "КОД " 
astotv.otvp FORMAT "x(30)" LABEL "МЕСТО РАСПОЛОЖЕНИЯ    "
 WITH FRAME astotv row 4 centered title " СПИСОК МЕСТ РАСПОЛОЖЕНИЯ " scroll 1 12 down overlay.
