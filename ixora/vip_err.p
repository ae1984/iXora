/* vip_err.p
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
*/

/*========================================================================
=                                                                        =
=                Event Journal Registrator Utility                       =
=           Statement Generator by Andrey Popov, April 1998              =
=                                                                        =
========================================================================*/

define shared variable g-ofc as character.

if opsys <> "UNIX" then return. 

define input parameter program   as character format "x(20)".
define input parameter event       as character format "x(20)".
define input parameter des          as character format "x(150)".     

define variable log_path        as character format "x(150)".
define variable zaboy            as character format "x(20)" initial "????".
     
define variable t_date              as date.
define variable t_time              as character format "x(15)".

t_date = today.
t_time = string(time,"hh:mm:ss").

find sysc where sysc.sysc = "VIPLOG" no-lock no-error.
   if available sysc then  
      log_path = trim(sysc.chval) + "/vip.log".
   else 
      log_path = "vip.log".

if event   = ?    then event = zaboy.

output to value(log_path)  append.

put unformatted program space(1) event space(1) t_date space(1) t_time space(1) g-ofc space(1) des skip.
output close.
      
