/* setglob.p
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

/* setglob.p
*/

{global.i}

define var vdbname as cha.
define var vpoint  as int.
define var backinc as int.
define var fildel  as cha.

input through echo $PLANG no-echo.
set g-lang.
g-lang = caps(g-lang).
input close.
if g-lang eq "" then g-lang = "US".

find last cls no-lock no-error.
if available cls then g-today = cls.cls + 1.
		 else do transaction:
			create cls.
			cls.cls = today - 1.
			g-today = today.
		      end.
g-bra = 0.
g-ofc   = caps(userid('bank')).
g-proc  = "".
find first cmp no-lock.
g-comp  = cmp.name.
g-permit = 1.
vdbname = dbname.
vpoint  = 0.
if opsys eq "msdos" then fildel = "~\".
else if opsys eq "unix"  then fildel = "/".
repeat backinc = length(vdbname) to 1 by -1:
  if substring(vdbname,backinc,1) eq fildel
  then do:
	 vpoint = backinc.
	 leave.
       end.
end.
if vpoint eq 0
then do:
       g-dbdir = "".
       g-dbname = vdbname.
     end.
else do:
       g-dbdir  = substring(vdbname, 1, vpoint - 1).
       g-dbname = substring(vdbname, vpoint + 1).
     end.
find sysc where sysc.sysc eq "cdlib"  no-lock. g-cdlib  = sysc.loval.
find sysc where sysc.sysc eq "browse" no-lock. g-browse = sysc.chval.
find sysc where sysc.sysc eq "editor" no-lock. g-editor = sysc.chval.
find sysc where sysc.sysc eq "pfdir"  no-lock. g-pfdir  = sysc.chval.
/* find sysc where sysc.sysc eq "dcrc"   no-lock. g-crc    = sysc.chval. */
find sysc where sysc.sysc eq "lprpt"  no-lock. g-lprpt  = sysc.chval.
find sysc where sysc.sysc eq "lplab"  no-lock. g-lplab  = sysc.chval.
find sysc where sysc.sysc eq "lplet"  no-lock. g-lplet  = sysc.chval.
find sysc where sysc.sysc eq "lpstmt" no-lock. g-lpstmt = sysc.chval.
find sysc where sysc.sysc eq "lpvou"  no-lock. g-lpvou  = sysc.chval.

find sysc where sysc.sysc eq "labfmk" no-lock. g-labfmk = sysc.chval.
find sysc where sysc.sysc eq "letfmk" no-lock. g-letfmk = sysc.chval.
find sysc where sysc.sysc eq "stmtmk" no-lock. g-stmtmk = sysc.chval.

find ofc where ofc.ofc = userid('bank') no-lock no-error.
if available ofc then  g-bra = ofc.bra.
		 else  g-bra = 999.

find sysc where sysc.sysc = "basedy" no-lock. g-basedy = sysc.inval.
find sysc where sysc.sysc = "defdfb" no-lock. g-defdfb = sysc.chval.
/*
find sysc where sysc.sysc = "prnvou" no-lock. g-prnvou = sysc.chval.
find sysc where sysc.sysc = "prnrpt" no-lock. g-prnrpt = sysc.chval.
find sysc where sysc.sysc = "lprhdr" no-lock. g-lprhdr = sysc.chval.
find sysc where sysc.sysc = "lprtrr" no-lock. g-lprtrr = sysc.chval.
*/
