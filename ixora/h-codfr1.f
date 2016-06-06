/* h-codfr1.f
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
       18.03.2004 marinav 
 * CHANGES
*/

form 
    t-cods.choice no-label format "x"
    t-cods.code  label "КОД" format "x(3)"
    t-cods.name1  label "НАИМЕНОВАНИЕ" format "x(45)"
    t-cods.name2  no-label format "x(19)"
with 11 down title v-codname overlay centered row 6 frame h-cod.
