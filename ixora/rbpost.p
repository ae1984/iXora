/* rbpost.p
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
     BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* rbpost.p
*/

{global.i}

def var vcod as char.
def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def var vln as int initial 1.

/* find sysc where sysc.sysc eq "RMPYGL". */

for each crc where crc.sts ne 9:

run x-jhnew.
pause 0.
find jh where jh.jh = s-jh.
jh.party = "RETAIL TRANSACTION POST".
jh.crc = crc.crc.
pause 0.

for each aal where aal.regdt eq g-today
              and  aal.stn ne 9
              and  aal.sta ne "RJ"
   ,each aaa of aal where aaa.crc eq crc.crc:

  find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax.

if aal.aax = 1 or aal.aax = 51 then vcod = "csh".
if aal.aax = 11 or aal.aax = 14 then vcod = "chg".
if aal.aax = 66 or aal.aax = 17 or aal.aax = 12 then vcod = "tax".
if aal.aax = 85 then vcod = "tax".

  if aax.dgl gt 0
    then do:
          find gl where gl.gl eq aax.dgl.
          create jl.
          jl.jh = jh.jh.
          jl.ln = vln.
          jl.who = aal.who.

          jl.point = aal.point.
          jl.depart = aal.depart.

          jl.jdt = jh.jdt.
          jl.whn = jh.whn.
          jl.dc = "D".
          jl.gl = aax.dgl.
          jl.crc = crc.crc.
          if gl.subled eq "cif"
          then jl.acc = aal.aaa.
          jl.dam = aal.amt.
          if aal.rem[1] ne "" then jl.rem[1] = aal.rem[1].
          else do:
          if gl.subled eq "cif"
            then jl.rem[1] = aax.des.
            else jl.rem[1] = aal.aaa + "/" + aax.des.
          end.
           jl.rem[2] = aal.rem[2].
           jl.rem[3] = aal.rem[3].
           jl.rem[4] = aal.rem[4].
           jl.rem[5] = aal.rem[5].
          jl.aah = aal.aah.
          create trxcods.
          trxcods.trxh = jl.jh.
          trxcods.trxln = jl.ln.
          trxcods.codfr = "stmt".
          trxcods.code = vcod.
          vln = vln + 1.
        end.

  if aax.cgl gt 0
    then do:
          find gl where gl.gl eq aax.cgl.
          create jl.
          jl.jh = jh.jh.
          jl.ln = vln.
          jl.who = aal.who.

          jl.point = aal.point.
          jl.depart = aal.depart.

          jl.jdt = jh.jdt.
          jl.whn = jh.whn.
          jl.dc = "C".
          jl.gl = aax.cgl.
          jl.crc = crc.crc.
          if gl.subled eq "cif"
          then jl.acc = aal.aaa.
          else if gl.subled eq "dfb"
          then jl.acc = "".  /* sysc.chval. */
          jl.cam = aal.amt.
          if aal.rem[1] ne "" then jl.rem[1] = aal.rem[1].
          else do:
          if gl.subled eq "cif"
            then jl.rem[1] = aax.des.
            else jl.rem[1] = aal.aaa + "/" + aax.des.
          end.
           jl.rem[2] = aal.rem[2].
           jl.rem[3] = aal.rem[3].
           jl.rem[4] = aal.rem[4].
           jl.rem[5] = aal.rem[5].
          vln = vln + 1.
          jl.aah = aal.aah.
          create trxcods.
          trxcods.trxh = jl.jh.
          trxcods.trxln = jl.ln.
          trxcods.codfr = "stmt".
          trxcods.code = vcod.
          vln = vln + 1.
           
        end.
        pause 0.
  aal.stn = 9.
  aal.jh = jh.jh.
pause 0.
end.
pause 0.
end.
pause 0.
