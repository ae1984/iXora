/* s-aatadd.p
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

/* s-aatadd.p
*/

{global.i}

define shared var s-aaa   like aaa.aaa.
define shared var s-aax   like aat.aax.
define shared var s-amt   like aat.amt.
define shared var s-stn   like aat.stn.
define shared var s-intr  like aat.intr.
define shared var s-force as log.
define shared var s-jh    like aat.jh.
define shared var s-regdt like aat.regdt.
define shared var s-bal   like aat.bal.
define shared var s-aat   like aat.aat.

define new shared var s-line as int.

find aaa where aaa.aaa eq s-aaa.

run aat-num.

find aat where aat.aat eq s-aat.

aat.aaa   = s-aaa.
aat.lgr   = aaa.lgr.
aat.stn   = s-stn.
aat.intr  = s-intr.
aat.regdt = s-regdt.
aat.aax   = s-aax.
aat.amt   = s-amt.
aat.who   = g-ofc.
aat.whn   = g-today.
aat.tim   = time.
aat.jh    = s-jh.

find aax where aax.lgr eq aat.lgr and aax.ln eq aat.aax.

s-line = 1.

if aat.stn ne 9 then run aat-pls.

find aaa where aaa.aaa eq aat.aaa.
if s-stn eq 0
  then do:
    aat.bal = aaa.cr[1] - aaa.dr[1].
  end.
else do:
    aat.bal = s-bal.
end.
