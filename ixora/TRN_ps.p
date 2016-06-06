/* receive-file.p
 * MODULE
        Переводы 
 * DESCRIPTION
        Переводы (загрузка из файла)
 * RUN
        .
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        19/06/05 Ilchuk
 * CHANGES

*/

{lgps.i} 

if not connected("comm") then 
 run comm-con.
if not connected("comm") 
then do:
 v-text = " База COMM  не соединена! ." .  run lgps .           
 return .
end.
/*----------------- Оброботка полученных переводов -------------------- */
run TRNper_ps.


if connected("comm") then
 disconnect "comm" .


