/* pkh-krit.p
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
        25/10/2006 madiyar - подправил обращение к справочнику
*/

/* pkh-krit.p  ПотребКредит
   Помощь по F2 при наборе анкеты для разных полей

   27.01.2003 nadejda
*/

{global.i}
{pk.i new}


def input parameter p-kritcod as char no-undo.
def output parameter p-cod as char no-undo.

def shared temp-table t-anket like pkanketh.

def var v-mask as char no-undo.
def var v-spr as char no-undo.

p-cod = "".

find pkkrit where pkkrit.kritcod = p-kritcod no-lock no-error.
if not avail pkkrit then do:
  message " Не найдено описание критерия" p-kritcod.
  pause 5.
  return.
end.

v-spr = ''.
if num-entries(pkkrit.kritspr) = 1 then v-spr = pkkrit.kritspr.
else do:
  if num-entries(pkkrit.kritspr) >= integer(s-credtype) then v-spr = entry(integer(s-credtype),pkkrit.kritspr).
end.

if v-spr = "" then do:
  hide message no-pause.
  message pkkrit.res[1].
end.
else do:
  find bookref where bookref.bookcod = v-spr no-lock no-error.
  if avail bookref then run uni_book (v-spr, "", output p-cod).
  else do:
    case p-kritcod :
      when "automod" then do: 
        find t-anket where t-anket.kritcod = "autom" no-lock no-error.
        if avail t-anket then v-mask = t-anket.value1.
        v-mask = v-mask + "|*".
      end.
    end case.
    run uni_help (v-spr, v-mask, output p-cod).
  end.
end.


