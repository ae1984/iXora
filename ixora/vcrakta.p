﻿/* vcrakta.p
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

/* vcraktpa.p - Валютный контроль 
   Акт сверки с таможней за введенный год - по одному банку!

   30.10.2002 nadejda создан

*/

{vc.i}

{mainhead.i}
{name2sort.i}

def temp-table t-cif
  field nmsort like cif.name
  field cif like cif.cif
  field name like cif.name
  field okpo as char format "99999999" init ""
  field rnn  as char format "999999999999" init ""
  index main is primary nmsort cif.

{vcrakt.i 
 &fldsort = "t-cif.nmsort"
 &usl = "vccontrs.sts begins 'c'"
 &depart = " true "
}
