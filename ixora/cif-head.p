/* cif-head.p
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

/* checked */
/* cif-head.p
*/

{global.i}

def shared var s-cif like cif.cif.
find cif where cif.cif = s-cif.

      update  skip(1)
              cif.headoff[1] label  "Счет N   " skip(1)
              with row 8 centered  side-label frame opt title "Введите номер лицевого счета клиента для учета ЦБ".
      hide frame  opt.


 
