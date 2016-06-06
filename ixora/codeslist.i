/* codeslist.i
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
        03/11/04 sasco Добавил исполнителя, сформировавшего выписку
     
*/

/* ================================================================
=                                                                  =
=                Codes List for Default Format (defor)                  =
=                                                                  =
================================================================ */ 

find first acc_list no-lock no-error.

if available acc_list then do:

put "-------- Пояснения использованных кодов операций ---------" at 2 skip(1).

for each trx_codes:

  put trx_codes.code format "x(10)" at 3. 
  put trx_codes.name format "x(30)" at 15 skip(0).

end.

put skip(1).
put "----------------------------------------------------------" at 2 skip(1).
put skip(2).

end.

/* define shared variable g-ofc as character. */
find ofc where ofc.ofc = g-ofc no-lock no-error.

put unformatted "Исполнитель: " + trim (ofc.name) skip(2).

