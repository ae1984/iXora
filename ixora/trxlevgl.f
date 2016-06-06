/* trxlevgl.f
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

form trxsublv.level label "Уровень"
     trxsublv.des label "Наименование"
     vglr format "999999" label "Счет Г/К  "
with row 7 centered 10 down overlay title "Г/К: " + string(vgl,"999999") 
                         + "; " + vsub frame trxlevgl. 
