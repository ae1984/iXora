/* kasmodul.p
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
        27.01.2004 sasco    - убрал today для cashofc
	28.07.2008 id00024  - добавил явную паузу
*/


/* =============================================================== */
/*         KASOST  -  current status of cash for the cashier       */
/* =============================================================== */
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.

find ofc where ofc.ofc eq g-ofc no-lock no-error.

if avail ofc then do:

displ "Кассир : " ofc.name with no-label no-box.

for each cashofc where 
                   cashofc.ofc eq g-ofc and
                   cashofc.whn eq g-today
                   and cashofc.sts eq 2
                   by cashofc.crc:
                    
find first crc where crc.crc eq cashofc.crc no-lock no-error.
if avail crc then

displ crc.crc crc.code cashofc.amt.

end. /* avail ofc */
end.
pause. /* id00024 28.07.2008 */

