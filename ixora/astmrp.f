/* astmrp.f
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
astmrp.r-year FORMAT "x(4)" LABEL "ГОД " 
astmrp.r-kvart FORMAT "x(1)" LABEL "КВАРТАЛ "
astmrp.r-sum /*FORMAT "x(4)"*/ LABEL "ПОКАЗАТЕЛЬ "
 WITH FRAME astmrp row 4 centered title " МЕСЯЧНЫЙ РАСЧЕТНЫЙ ПОКАЗАТЕЛЬ " scroll 1 12 down overlay.
