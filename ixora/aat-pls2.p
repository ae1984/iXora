/* aat-pls2.p
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

/* aaa-pls.p
   aat-pls.p
*/

def buffer b-aaa for aaa.
def shared var s-aat like aat.aat.

def var toavail as dec decimals 2 label "TotAvail" init 0.
def var cravail like aaa.cbal label "Cr-Avail" init 0.
def var vcbal like aaa.cbal.
def var vcashday as int.
def var vinc as int.

find aat where aat.aat eq s-aat .
find aaa where aaa.aaa eq aat.aaa.
find aax where aax.lgr eq aaa.lgr and aax.ln eq aat.aax.
find lgr where lgr.lgr eq aaa.lgr no-lock.
find led where led.led eq lgr.led no-lock.

if led.drcr eq -1 and aax.drcr eq 1
then do:
       vcbal = aaa.cbal.
       if aaa.loa ne ""
       then do:
	      find b-aaa where b-aaa.aaa = aaa.loa no-lock.
	      cravail = (b-aaa.dr[5] - b-aaa.cr[5])
		      - (b-aaa.dr[1] - b-aaa.cr[1]).
	    end.

       if aaa.cr[1] - aaa.dr[1] ge 0 then
       toavail = vcbal + cravail - aaa.hbal.
       else toavail = cravail - aaa.hbal.

       if vcbal - aaa.hbal lt aat.amt /* and s-force eq false   */
       then do:
	      if toavail lt aat.amt then aat.sta = "RJ".
				      else aat.sta = "CR".
	    end.
       else aat.sta = "".
end.

/* if aat.sta eq "RJ" then return. */

if aax.dev > 0 then aaa.dr[aax.dev]  = aaa.dr[aax.dev]  + aat.amt.
if aax.cev > 0 then aaa.cr[aax.cev]  = aaa.cr[aax.cev]  + aat.amt.
if aax.cnt > 0 then do:
		      if aat.amt gt 0
		      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + 1.
		      else if aat.amt lt 0
		      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + -1.
	      end.
/* if aal.fday gt 0
then aaa.fbal[aal.fday] = aaa.fbal[aal.fday] + aal.amt.
*/

/* Depends on customer cash class, the cash balance could be different */

/* find cif of aaa no-lock. */

if led.drcr eq -1 and (aat.amt - aat.famt) gt 0
then aaa.cbal = aaa.cbal + (aat.amt - aat.famt) * aax.drcr * -1.
