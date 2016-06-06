/* aatpost.p
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

/* aatpost.p
*/

{global.i}

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def var vln as int initial 1.

find sysc where sysc.sysc eq "DEFDFB".

for each crc:

  run x-jhnew.
  find jh where jh.jh = s-jh.
  jh.party = "RETAIL TRANSACTION POST".
  jh.crc = crc.crc.
  pause 0.

  for each aat where aat.regdt eq g-today
	      and  aat.stn ne 9 and  aat.sta ne "RJ"
    ,each aaa of aat where aaa.crc eq crc.crc
      break by aaa.crc by aaa.lgr by aat.aax by aaa.aaa:

    find aax where aax.lgr eq aaa.lgr and aax.ln eq aat.aax.

   /*
    if aax.dgl gt 0
    then do:
      find gl where gl.gl eq aax.dgl.
      create jl.
      jl.jh = jh.jh.
      jl.ln = vln.
      jl.who = aat.who.
      jl.jdt = jh.jdt.
      jl.whn = jh.whn.
      jl.dc = "D".
      jl.gl = aax.dgl.
      jl.crc = crc.crc.
      if gl.subled eq "cif"
	then jl.acc = aat.aaa.
      jl.dam = aat.amt.
      if gl.subled eq "cif" then jl.rem[1] = aax.des.
      else jl.rem[1] = aat.aaa + "/" + aax.des.
      jl.aah = aat.aat. /* jl.aat = aat.aat */
      vln = vln + 1.
    end. /* if aax.dgl gt 0 */

    if aax.cgl gt 0 and aat.camt eq 0 and aat.famt eq 0
    then do:
      find gl where gl.gl eq aax.cgl.
      create jl.
      jl.jh = jh.jh.
      jl.ln = vln.
      jl.who = aat.who.
      jl.jdt = jh.jdt.
      jl.whn = jh.whn.
      jl.dc = "C".
      jl.gl = aax.cgl.
      jl.crc = crc.crc.
      if gl.subled eq "cif"
	 then jl.acc = aat.aaa.
      else if gl.subled eq "dfb"
	 then jl.acc = sysc.chval.
      jl.cam = aat.amt.
      if gl.subled eq "cif"
	 then jl.rem[1] = aax.des.
      else jl.rem[1] = aat.aaa + "/" + aax.des.
      vln = vln + 1.
      jl.aah = aat.aat.  /* jl.aat = aat.aat */
    end. /* if aax.cgl  gt 0 */

    if aax.cgl gt 0 and aat.camt ne 0
    then do:
      find gl where gl.gl eq aax.cgl.
      create jl.
      jl.jh = jh.jh.
      jl.ln = vln.
      jl.who = aat.who.
      jl.jdt = jh.jdt.
      jl.whn = jh.whn.
      jl.dc = "C".
      jl.gl = aax.cgl.
      jl.crc = crc.crc.
      if gl.subled eq "cif"
	 then jl.acc = aat.aaa.
      else if gl.subled eq "dfb"
	 then jl.acc = sysc.chval.
      jl.cam = aat.camt.
      if gl.subled eq "cif"
	 then jl.rem[1] = aax.des.
      else jl.rem[1] = aat.aaa + "/" + aax.des.
      vln = vln + 1.
      jl.aah = aat.aat.  /* jl.aat = aat.aat */
    end. /* if aax.cgl  gt 0  and aat.camt ne 0 */

    if aax.cgl gt 0 and aat.famt ne 0
    then do:
      find gl where gl.gl eq aax.cgl.
      create jl.
      jl.jh = jh.jh.
      jl.ln = vln.
      jl.who = aat.who.
      jl.jdt = jh.jdt.
      jl.whn = jh.whn.
      jl.dc = "C".
      jl.gl = aax.ccgl.
      jl.crc = crc.crc.
      if gl.subled eq "cif"
	 then jl.acc = aat.aaa.
      else if gl.subled eq "dfb"
	 then jl.acc = sysc.chval.
      jl.cam = aat.famt.
      if gl.subled eq "cif"
	 then jl.rem[1] = aax.des.
      else jl.rem[1] = aat.aaa + "/" + aax.des.
      vln = vln + 1.
      jl.aah = aat.aat.  /* jl.aat = aat.aat */
    end. /* if aax.cgl  gt 0  and aat.famt ne 0 */
    aat.stn = 9.
    aat.jh = jh.jh.   */
  end. /* for each aat */
end.  /* for each crc */
