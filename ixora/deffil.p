/* deffil.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Определение филиала по логину менеджера
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
        03/11/2006 madiyar
 * BASES
        bank, txb
 * CHANGES
        07/11/2006 madiyar - игнорируем наличие юзера в ЦО
        20/11/2006 madiyar - некорректно работало, исправил
*/

def shared var g-ofc as char.
def shared var s-ubnk as char no-undo.

find first txb.ofc where txb.ofc.ofc = g-ofc no-lock no-error.
if avail txb.ofc then do:
  find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
  if avail txb.sysc and trim(sysc.chval) <> "txb00" then s-ubnk = trim(sysc.chval).
end.


