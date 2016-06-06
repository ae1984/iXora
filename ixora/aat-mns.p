/* aat-mns.p
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

/* aaa-mns.p
   aat-mns.p
*/

/*
def shared var s-toavail as dec decimals 2 label "TotAvail" init 0.
def shared var s-aaa like aaa.aaa.
def shared var s-lgr like lgr.lgr.
def shared var s-aax like aat.aax.
*/

def shared var s-aat like aat.aat.

def var toavail as dec decimals 2 label "TotAvail" init 0.
def var cravail like aaa.cbal label "Cr-Avail" init 0.
def var vcashday as int.
def var vinc as int.

find aat where aat.aat eq s-aat.
find aaa where aaa.aaa eq aat.aaa.
find aax where aax.lgr eq aaa.lgr and aax.ln eq aat.aax.
find lgr where lgr.lgr eq aaa.lgr no-lock.
find led where led.led eq lgr.led no-lock.
find cif of aaa no-lock.

if aat.sta eq "RJ" then return.

if aax.dev > 0 then aaa.dr[aax.dev]  = aaa.dr[aax.dev]  - aat.amt.
if aax.cev > 0 then aaa.cr[aax.cev]  = aaa.cr[aax.cev]  - aat.amt.
if aax.cnt > 0 then do:
		      if aat.amt gt 0
		      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] - 1.
		      else if aat.amt lt 0
		      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] - -1.
		    end.

if led.drcr eq -1 and (aat.amt - aat.famt) gt 0
then aaa.cbal = aaa.cbal - (aat.amt - aat.famt) * aax.drcr * -1.
