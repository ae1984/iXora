/* blk.p
 * MODULE
        АДМИНИСТРИРОВАНИЕ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Блокировка доступа пользователей к АБПК
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
	9-8
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	29.09.2005 u00121 - добавил ведение лога 
*/

def var soob as char format "x(26)".
def var filelog as char init "CloseAccessBANK".
find first sysc where sysc.sysc = "SUPUSR" no-error. 
if avail sysc then do:
   sysc.loval = not sysc.loval.
   if sysc.loval then
      soob = " Доступ к Системе зарылся! ".
   else
      soob = " Доступ к Системе отрылся! ".
   end.
else soob = " Изменение доступа к Системе невозможно! ".
display soob no-label with centered row 10. 
run savelog(filelog, soob). /*29.09.2005 u00121*/
pause 2. 
