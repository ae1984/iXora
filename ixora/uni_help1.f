/* uni_help1.f
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
        19/12/2012 madiyar - v-name as fill-in
*/

form
    codfr.code  label "Code" format "x(10)"
    v-name      label "Code Name" format "x(200)" view-as fill-in size 67 by 1
with 11 down title codific-name overlay centered row 6 frame uni_help1.
