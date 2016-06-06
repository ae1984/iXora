/* cls-day.p
 * MODULE
        АДМИНИСТРИРОВАНИЕ ИБФЛ
 * DESCRIPTION
        Выставление флага блокировки пользователей ИБФЛ на проведение операций
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
        04-11-2013 k.gitalov
 * BASES
        BANK COMM        
 * CHANGES
 
*/

def var soob as char format "x(26)".
def var filelog as char init "DayCloseAccess".
find first comm.pksysc where comm.pksysc.sysc = "DAYCLOSE" exclusive-lock no-error. 
if avail comm.pksysc then do:
   comm.pksysc.loval = not comm.pksysc.loval.
   if comm.pksysc.loval then
      soob = " Режим [ЗАКРЫТИЕ]! ".
   else
      soob = " Режим [РАБОТА]! ".
   end.
else soob = " Изменение доступа к системе невозможно! ".
display soob no-label with centered row 10. 
run savelog(filelog, soob). /*29.09.2005 u00121*/
pause 2. 
