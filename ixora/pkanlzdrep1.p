/* pkanlzdrep1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Анализ портфеля потреб. кредитов в динамике для управленческой отчетности
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
        18/05/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}



def var dat as date no-undo.
find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc then return.
if sysc.chval <> "txb00" then do:
  message "Данный пунк только для ЦО!" view-as alert-box title "ВНИМАНИЕ".
  return.
end.

dat = g-today.
update dat label ' Укажите дату ' format '99/99/9999'
validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
with side-label row 5 centered frame frdat.


for each txb where txb.consolid no-lock:
 message "Формируется отчет...".
 run pkanlzd1(txb.bank,dat).
 pause 0.
 hide message no-pause.

end. 
