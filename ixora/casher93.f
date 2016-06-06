/* casher93.f
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

 form m-aah column-label "Номер операции"
 m-who column-label "Исполн."
 m-ln column-label "Лин"
 m-amtd column-label "Дебет "  format "zzz,zzz,zzz,zzz.99-"
 m-amtk column-label "Кредит " format "zzz,zzz,zzz,zzz.99-"
 jh.sts column-label "СТС"
 m-att column-label "ВНМ"
with width 130 frame c row 6 column 1 4 down no-box .
