/* vcmsg114.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        МТ114
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
 * BASES
         BANK COMM          
       
 * AUTHOR
        06.05.2008 galina
 * CHANGES
   
*/


{mainhead.i}

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if sysc.chval = 'TXB00' then run vcrep4 ("all", 0, "msg").
else run vcrep4 ("this", 0, "msg").

