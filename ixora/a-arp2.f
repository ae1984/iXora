/* a-arp2.f
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

/* a-arp.f
*/

form /*varp label "СЧЕТ "*/
     v-asof    label "ДАТА " colon 25 skip
     v-zerobal label "СЧЕТА С ОСТАТКОМ >0 ? " colon 25 
     with centered overlay row 8 no-box side-label frame f-opt.


