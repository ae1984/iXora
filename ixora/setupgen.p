/* setupgen.p
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

/* setupgen.p
   General Sysetm Setup
*/

{proghead.i "GENERAL SYSTEM SETUP"}

define buffer nxtcif for nmbr.
define buffer wkday for sysc.
define buffer nxtjh for sysc.
define buffer dayacr for sysc.
define buffer aicoll for sysc.

find nxtcif where nxtcif.code eq "CIF" no-error.
if not available nxtcif
  then do:
    create nxtcif.
    nxtcif.code = "CIF".
    nxtcif.des  = "CIF NUMBER".
  end.

find wkday where wkday.sysc eq "wkday" no-error.
if not available wkday
  then do:
    create wkday.
    wkday.sysc = "WKDAY".
    wkday.des  = "WORKING DAY IN WEEKDAY".
  end.

find nxtjh where nxtjh.sysc eq "nxtjh" no-error.
if not available nxtjh
  then do:
    create nxtjh.
    nxtjh.sysc = "NXTJH".
    nxtjh.des  = "NEXT JOURNAL TRX NUMBER".
  end.

find dayacr where dayacr.sysc eq "dayacr" no-error.
if not available dayacr
  then do:
    create dayacr.
    dayacr.sysc = "DAYACR".
    dayacr.des  = "DAILY ACCRUAL SYSTEM".
  end.

find aicoll where aicoll.sysc eq "aicoll" no-error.
if not available aicoll
  then do:
    create aicoll.
    aicoll.sysc = "AICOLL".
    aicoll.des  = "ACCRUAL ON COLLECTABLE B/S".
  end.


{setupgen.f}

display nxtcif.des wkday.des nxtjh.des dayacr.des aicoll.des
	with frame setup.

update nxtcif.prefix nxtcif.nmbr nxtcif.fmt nxtcif.sufix
       wkday.inval wkday.deval
       nxtjh.inval
       dayacr.loval aicoll.loval
       with frame setup.
