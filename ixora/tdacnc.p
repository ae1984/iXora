/* tdacnc.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tdacnc.p
   08/19/91
   S. CHOI
*/

define var vaaa like aaa.aaa.
define var vamt like aaa.accrued.
define var vans as log init false.

def new shared var s-aaa like aaa.aaa.

{mainhead.i TDCNC}  /* TDA CANCEL */

update {tdacnc.f}

find aaa where aaa.aaa eq vaaa no-error.

if not available aaa then do:
   {mesg.i 0205}.
   undo,  retry.
end.
s-aaa = aaa.aaa.
find lgr where lgr.lgr eq aaa.lgr.
find led of lgr.

if led.led ne "CDA" then do:
  {mesg.i 8209}.
  undo , retry.
end.

if aaa.regdt eq g-today then run tdaextcn.
else  run tdamatcn.
