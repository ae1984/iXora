/* vcmsg106.p
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
   09.04.2008 galina - консолидированный отчет только для ЦО
*/

/* vcmsg104.p - Валютный контроль 
   Приложение 16 - сообщение МТ-106

   18.03.2003 nadejda создан
*/

{mainhead.i}

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if sysc.chval = 'TXB00' then run vcrep1718 ("e,i", "msg", "all", 0).
else run vcrep1718 ("e,i", "msg", "", 0).

