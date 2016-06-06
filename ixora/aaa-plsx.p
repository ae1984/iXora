/* aaa-plsx.p
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

 /* aaa-plsx.p*/

def buffer b-aaa for aaa.
def shared var s-aaa like aaa.aaa.

def shared var s-aah as int.
def shared var s-line as int.
def shared var s-force as log.


def var toavail as dec decimals 2 label "TotAvail" init 0.
def var cravail like aaa.cbal label "Cr-Avail" init 0.
def var vcbal like aaa.cbal.
def var vcashday as int.
def var vinc as int.

find aal where aal.aah eq s-aah and aal.ln = s-line.
find aaa where aaa.aaa eq aal.aaa exclusive-lock.
find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax no-lock.
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
       toavail = vcbal + cravail - aaa.hbal.
       if vcbal - aaa.hbal lt aal.amt and s-force eq false
       then do:
              if toavail lt aal.amt then aal.sta = "RJ".
                                      else aal.sta = "CR".
            end.
       else aal.sta = "".
     end.

if aal.sta eq "RJ" then return.

if aax.dev > 0 then aaa.dr[aax.dev]  = aaa.dr[aax.dev]  + aal.amt.
if aax.cev > 0 then aaa.cr[aax.cev]  = aaa.cr[aax.cev]  + aal.amt.

if aax.cnt > 0 then do:
                      if aal.amt gt 0
                      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + 1.
                      else if aal.amt lt 0
                      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + -1.
                    end.
if aal.fday gt 0
then aaa.fbal[aal.fday] = aaa.fbal[aal.fday] + aal.amt.

/* Depends on customer cash class, the cash balance could be different */
find cif of aaa no-lock.

if led.led ne "ODA" then do:

if led.drcr eq -1 and aal.fday le cif.cashday
then aaa.cbal = aaa.cbal + aal.amt * aax.drcr * -1.
end.
else do:
if aal.fday le cif.cashday
then aaa.cbal = aaa.cbal + aal.amt * aax.drcr * -1.
end.
