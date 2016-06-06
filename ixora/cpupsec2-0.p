/* cpupsec2-0.p
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

/* cpupsec2-0.p
   Љ®ЇЁЮ®ў ­ЁҐ ¤®АБЦЇ®ў Є ЇЦ­ЄБ ¬ ўҐЮЕ­Ґё® ¬Ґ­Н ®Б ®¤­®ё® Ї®«Л§®ў БҐ«О Є ¤ЮЦё®¬Ц Ї® «®ёЁ­Ц

   05.01.2003 nadejda - ўК¤Ґ«Ґ­ ЄЦА®Є Ё§ cpupsec2.p
*/

def input parameter v-ofcexp as char.
def input parameter v-ofcimp as char.

for each optitsec where lookup(v-ofcexp, optitsec.ofcs) > 0 and lookup(v-ofcimp, optitsec.ofcs) = 0
     exclusive-lock:
  if length(optitsec.ofcs) > 0 and substr(optitsec.ofcs, length(optitsec.ofcs), 1) <> "," then
    optitsec.ofcs = optitsec.ofcs + ",".
  optitsec.ofcs = optitsec.ofcs + v-ofcimp + ",".
end.

