/* ofcsum.f
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

display {1} otl.gl column-label " СЧЕТ  "
        gl.des no-label
        otl.ndam label " #ДЕБ " format "zzzz9" (total)
        otl.dam label  "ДЕБЕТ "                (total)
        otl.cam label  "КРЕДИТ "               (total)
        otl.ncam label " # КР " format "zzzz9" (total)
        with width 132 .
