/* vc-2his.i
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

/* vc-2his.i  Валютный контроль
   запись в таблицу истории

   06.11.2002 nadejda создан
*/

{global.i}
{comm-txb.i}

def var v-bank as char.

find {&head0} where {&head0}.{&headkey} = v-id no-lock no-error.

if avail {&head0} then do transaction on error undo, retry:
  v-bank = comm-txb().
  create {&head}.
  assign {&head}.{&uplevel} = {&head0}.{&uplevel}
         {&head}.{&headkey} = v-id
         {&head}.whn = today
         {&head}.tim = time
         {&head}.who = g-ofc
         {&head}.fname = g-fname
         {&head}.ourbnk = v-bank
         {&head}.info = v-msghis.
end.




