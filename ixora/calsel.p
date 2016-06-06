/* calsel.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Выбор типа формирования графика погашения Excel/word.
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
        BANK COMM
 * CHANGES
        01/09/2011 madiyar - добавил группы
        14/09/2011 dmitriy - добавил 3-й пункт "Уведомление" и дописал группы 70,80 в list1
        28/06/2012 kapar - добавил группы (95,96,13,23,53,63)
*/

{global.i}

def var v-select as integer no-undo.
def var list1 as char initial "14,15,16,24,25,26,54,55,56,64,65,66,70,80,81,82,95,96,13,23,53,63".

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.

  if lookup (string(lon.grp), list1) > 0 then do:
    v-select = 0.
    run sel2 (" Отчеты ", " 1. Excel| 2. Word| 3. Уведомление| ВЫХОД ", output v-select).
    if v-select = 0 then return.
    if v-select = 1 then run calxls.
    if v-select = 2 then run calword.
    if v-select = 3 then run uvedword.
  end.
  else do:
    run calxls.
  end.