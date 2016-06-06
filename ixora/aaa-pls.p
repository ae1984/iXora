/* aaa-pls.p
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
*/

def buffer b-aaa for aaa.
/*
def shared var s-toavail as dec decimals 2 label "TotAvail" init 0.
def shared var s-aaa like aaa.aaa.
def shared var s-lgr like lgr.lgr.
def shared var s-aax like aal.aax.
*/
/*
def shared var s-aaa like aaa.aaa.
*/

def shared var s-aah as int.
def shared var s-line as int.
def shared var s-force as log.

def var toavail as dec decimals 2 label "TotAvail" init 0.
def var cravail like aaa.cbal label "Cr-Avail" init 0.
def var vcbal like aaa.cbal.
def var vcashday as int.
def var vinc as int.

/* module for O/D */
def var xmt like jl.dam.
def new shared var saaa like aaa.aaa.
def new shared var raaa like aaa.aaa.
def new shared var damt like jl.dam.
def new shared var srem as char format "x(50)" extent 2.
def var ymt like jl.dam. /* O/D LINE */
def buffer xaaa for aaa.
def var kaaa like aaa.aaa.
def var kaax like aal.aax.
def var klgr like lgr.lgr.

def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.

find aal where aal.aah eq s-aah and aal.ln = s-line exclusive-lock.
find aaa where aaa.aaa eq aal.aaa exclusive-lock.
find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax no-lock.
find lgr where lgr.lgr eq aaa.lgr no-lock.

run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal, output
vfbal,                output vcrline, output vcrlused, output vooo).


aal.sta = "RJ".

    if aax.drcr = 1 then if vavl < aal.amt and s-force = false then return.

if lgr.led = "DDA" then do:

if aax.drcr = 1 then do:
              damt = aal.amt - vbal + (vcrline - vcrlused).
   if damt > 0 then do:
              saaa = vooo.
              raaa = aaa.aaa.
              srem[1] = "O/D PROTECT FOR CHECK " + string(aal.chk).
              srem[2] = "FROM " + saaa + " TO " + raaa.
              run s-oda22.
              aal.sta = " ".
   end.
end.
else do:
    if vcrlused > 0 then do: 
          saaa = aaa.aaa.
          raaa = vooo.
          if aal.amt > vcrlused then damt = vcrlused.
          else damt = aal.amt.
          srem[1] = "O/D PAYMENT ".
          srem[2] = "FROM " + saaa + " TO " + raaa.
          run s-oda21.
    end.
end.

end. /*if dda*/

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

if lgr.led ne "ODA" then do:
if aal.fday = 0 then aaa.cbal = aaa.cbal + aal.amt * aax.drcr * -1.
end.

aal.sta = "".
