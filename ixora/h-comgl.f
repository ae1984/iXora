/* h-comgl.f
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

form vgl.vgl label "Knt.Nr" format "999999"
     vgldes  label "Konta apraksts" format "x(30)"
     with row 7 centered 5 down title "Komisijas naudas kontu saraksts"
     overlay frame h-comgl.
