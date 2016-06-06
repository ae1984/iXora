/* cppssec2-0.p
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

/* cppssec2-0.p
   Љ®ЇЁЮ®ў ­ЁҐ ¤®АБЦЇ®ў ў Џ‘ ®Б ®¤­®ё® Ї®«Л§®ў БҐ«О Є ¤ЮЦё®¬Ц Ї® «®ёЁ­Ц

   05.01.2003 nadejda - ўК¤Ґ«Ґ­ ЄЦА®Є Ё§ cppssec2.p
*/

def input parameter v-ofcexp as char.
def input parameter v-ofcimp as char.

for each pssec where lookup(v-ofcexp, pssec.ofcs) > 0 and lookup(v-ofcimp, pssec.ofcs) = 0 
    exclusive-lock:
  if length(pssec.ofcs) > 0 and substr(pssec.ofcs, length(pssec.ofcs), 1) <> "," then
    pssec.ofcs = pssec.ofcs + ",".
  pssec.ofcs = pssec.ofcs + v-ofcimp + ",".
end.

