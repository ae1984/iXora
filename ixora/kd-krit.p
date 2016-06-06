/* kd-krit.p
 * MODULE
        Кредитный модуль, кредитное досье
 * DESCRIPTION
        Помощь при классификации кредита, досье
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3,  4-1-4 
 * AUTHOR
        26.12.03 marinav
 * CHANGES
*/
{global.i}
{kd.i}


def input parameter p-kritcod as char.
def output parameter p-cod as char.

p-cod = "".

find first kdklass where kdklass.kod = p-kritcod no-lock no-error.
if not avail kdklass then do:
  message " Не найдено описание критерия" p-kritcod.
  pause 5.
  return.
end.

if kdklass.sprav = "" then do:
  hide message no-pause.
  message 'Помощь не работает'.
end.
else do:
  find bookref where bookref.bookcod = kdklass.sprav no-lock no-error.
  if avail bookref then run uni_book (kdklass.sprav, "", output p-cod).
                   else  message " Нет такого справочника ".
end.



