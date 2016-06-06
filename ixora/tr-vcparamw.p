/* tr-vcparamw.p
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
 * BASES
        BANK COMM 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tr-vcparamw.p Валютный контроль
   Триггер на изменение записи в vcparams

   09.12.2002 nadejda
*/

trigger procedure for write of vcparams old oldvcparams.

{vc.i}

{global.i}

if vcparams.parcode <> oldvcparams.parcode and oldvcparams.parcode = "" then do:
  vcparams.rdt = g-today.
  vcparams.rwho = g-ofc.
end.

vcparams.udt = today.
vcparams.uwho = userid("bank").

