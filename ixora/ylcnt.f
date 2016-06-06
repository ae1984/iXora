/* ylcnt.f
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

form lcnt.lcnt   label "LЁgums....."
     lcnt.cif    label "Klients...."
     cif.name    label "V–rds......"
     lcnt.rdt    label "Datums....."
     lcnt.duedt  label "Termi‡Ѕ...."
     lcnt.crc    label "Val­ta....."
     lcnt.orgamt label "Summa......"
     lcnt.bal    label "Atlikums..."
     lcnt.base   label "B–ze......."
     lcnt.prem   label "% likme...." format 'zz9.99'
     lcnt.basedy label "Dienas gad–"
     lcnt.grp    label "Grupa......"format "zz9"
     lcnt.rem    label "PiezЁmes..." with row 3 centered 1 col frame lcnt.
