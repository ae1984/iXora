/* fold1.p
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

/*connect /usr2/pnp/rigabank -ld tbank no-error.*/
def var v-acc like newdb.acc.
repeat:
 update v-acc with frame bbb.
 if trim(v-acc)<>"" then do:
   find first newdb use-index acc where newdb.acc = v-acc no-error.
   if not available newdb then
    display " No account ".
   else
    repeat:
     display acc placc name cif with frame aaa down.
     find next newdb use-index acc where newdb.acc = v-acc no-error.
     if not available newdb then leave.
    end.
  end.
 end.
