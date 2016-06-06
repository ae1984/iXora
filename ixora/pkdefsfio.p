/* pkdefsfio.p
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

/* pkdefsfio.p ПотребКредиты
   Определение короткого имени клиента по данным анкеты

   28.05.2003 nadejda создан
*/

{global.i}
{pk.i}

define input parameter p-ln like pkanketa.ln.
define output parameter p-nameshort as char.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = p-ln no-lock no-error.

if not avail pkanketa then return.

def var v-namefull as char init "fname,mname".
def var n as integer.

p-nameshort = "".

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lname" no-lock no-error.
if avail pkanketh then p-nameshort = pkanketh.value1 + " ".

do n = 1 to num-entries(v-namefull):
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
       pkanketh.ln = pkanketa.ln and pkanketh.kritcod = entry(n, v-namefull) no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then 
    p-nameshort = p-nameshort + substr(pkanketh.value1, 1, 1) + ".".
end.

run pkdeffio (input-output p-nameshort).

