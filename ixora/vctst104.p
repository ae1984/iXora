/* vcmsg104.p
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

/* vcmsg104.p - Валютный контроль 
   Приложение 14 - сводная информация за месяц о результатах - по банку

   14.01.2003 nadejda создан
*/

{mainhead.i}
{vc.i}

def var v-bank as char.
def var v-dep as integer.

run sel2 (" РЕЖИМ ОТЧЕТА", " 1. По департаменту офицера | 2. По банку офицера | 3. Консолидированный | ВЫХОД", output v-dep).

if v-dep = 0 then return.

case v-dep:
  when 1 then do: v-bank = "this". v-dep = 1. end.
  when 2 then do: v-bank = "this". v-dep = 0. end.
  when 3 then do: v-bank = "all". v-dep = 0. end.
end.

run vctst14 ("msg", v-bank, v-dep).
