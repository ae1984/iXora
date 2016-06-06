/* vcraktpr.p
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
   Акт сверки с таможней за введенный год - сортировка по РНН
   по одному банку!

   24.01.2003 nadejda создан

*/

{vc.i}

{mainhead.i}
{name2sort.i}
{get-dep.i}

def var v-depart as integer.

def temp-table t-cif
  field nmsort like cif.name
  field cif like cif.cif
  field name like cif.name
  field okpo as char format "99999999" init ""
  field rnn  as char format "999999999999" init ""
  index main is primary rnn.

v-depart = get-dep(g-ofc, g-today).

{vcrakt.i 
 &fldsort = "t-cif.rnn"
 &usl = "vccontrs.sts begins 'c'"
 &depart = " (integer(cif.jame) mod 1000 = v-depart) "
}


