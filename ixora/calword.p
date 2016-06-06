/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Выбор типа формирования графика погашения по группам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08.02.2011 ruslan
 * BASES
        BANK
 * CHANGES
*/


{global.i}

def var list1 as char initial "81,82".

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

  if lookup (string(lon.grp), list1) > 0 then do:
    run calword2.
  end.
  else do:
    run calword1.
  end.