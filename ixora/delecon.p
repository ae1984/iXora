/* delecon.p
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

{global.i}
def shared var rem5 like rem.rem.
def shared var jh5 like rem.jh.
def shared var vjh5 like rem.vjh.
	find rem where rem = rem5 no-lock.
	    create remdel.
	    remdel.aaa = rem.aaa.
	    remdel.actins[1] = rem.actins[1].
	    remdel.actins[2] = rem.actins[2].
	    remdel.actins[3] = rem.actins[3].
	    remdel.actins[4] = rem.actins[4].
	    remdel.actinsact = rem.actinsact.
	    remdel.amt = rem.amt.
	    remdel.ba = rem.ba.
	    remdel.bank = rem.bank.
	    remdel.bb[1] = rem.bb[1].
	    remdel.bb[2] = rem.bb[2].
	    remdel.bb[3] = rem.bb[3].
	    remdel.ben[1] = rem.ben[1].
	    remdel.ben[2] = rem.ben[2].
	    remdel.ben[3] = rem.ben[3].
	    remdel.ben[4] = rem.ben[4].
	    remdel.bi = rem.bi.
	    remdel.bn[1] = rem.bn[1].
	    remdel.bn[2] = rem.bn[2].
	    remdel.bn[3] = rem.bn[3].
	    remdel.bytim = rem.bytim.
	    remdel.bywhn = rem.bywhn.
	    remdel.bywho = rem.bywho.
	    remdel.chg = rem.chg.
	    remdel.chkamt = rem.chkamt.
	    remdel.comm[1] = rem.comm[1].
	    remdel.comm[2] = rem.comm[2].
	    remdel.comm[3] = rem.comm[3].
	    remdel.cover = rem.cover.
	    remdel.crc = rem.crc.
	    remdel.crc1 = rem.crc1.
	    remdel.crc2 = rem.crc2.
	    remdel.ctim = rem.ctim.
	    remdel.cwhn = rem.cwhn.
	    remdel.cwho = rem.cwho.
	    remdel.del = rem.del.
	    remdel.detpay[1] = rem.detpay[1].
	    remdel.detpay[2] = rem.detpay[2].
	    remdel.detpay[3] = rem.detpay[3].
	    remdel.detpay[4] = rem.detpay[4].
	    remdel.dfb = rem.dfb.
	    remdel.grp = rem.grp.
	    remdel.intmed = rem.intmed.
	    remdel.intmedact = rem.intmedact.
	    remdel.iof = rem.iof.
	    if rem.jh = ? then remdel.jh = jh5.
	    else remdel.jh = rem.jh.
	    remdel.ock = rem.ock.
	    remdel.ord = rem.ord.
	    remdel.ordcst[1] = rem.ordcst[1].
	    remdel.ordcst[2] = rem.ordcst[2].
	    remdel.ordcst[3] = rem.ordcst[3].
	    remdel.ordcst[4] = rem.ordcst[4].
	    remdel.ordins[1] = rem.ordins[1].
	    remdel.ordins[2] = rem.ordins[2].
	    remdel.ordins[3] = rem.ordins[3].
	    remdel.ordins[4] = rem.ordins[4].
	    remdel.ordinsact = rem.ordinsact.
	    remdel.outcode = rem.outcode.
	    remdel.payment = rem.payment.
	    remdel.posit[1] = rem.posit[1].
	    remdel.posit[2] = rem.posit[2].
	    remdel.posit[3] = rem.posit[3].
	    remdel.posit1[1] = rem.posit1[1].
	    remdel.posit1[2] = rem.posit1[2].
	    remdel.posit1[3] = rem.posit1[3].
	    remdel.rcvcor[1] = rem.rcvcor[1].
	    remdel.rcvcor[2] = rem.rcvcor[2].
	    remdel.rcvcor[3] = rem.rcvcor[3].
	    remdel.rcvcor[4] = rem.rcvcor[4].
	    remdel.rcvcoract = rem.rcvcoract.
	    remdel.rcvinfo[1] = rem.rcvinfo[1].
	    remdel.rcvinfo[2] = rem.rcvinfo[2].
	    remdel.rcvinfo[3] = rem.rcvinfo[3].
	    remdel.rcvinfo[4] = rem.rcvinfo[4].
	    remdel.rcvinfo[5] = rem.rcvinfo[5].
	    remdel.rcvinfo[6] = rem.rcvinfo[6].
	    remdel.rdt = rem.rdt.
	    remdel.ref = rem.ref.
	    remdel.regdt = rem.regdt.
	    remdel.regtim = rem.regtim.
	    remdel.regwhn = rem.regwhn.
	    remdel.regwho = rem.regwho.
	    remdel.rem = rem.rem.
	    remdel.sndcor[1] = rem.sndcor[1].
	    remdel.sndcor[2] = rem.sndcor[2].
	    remdel.sndcor[3] = rem.sndcor[3].
	    remdel.sndcor[4] = rem.sndcor[4].
	    remdel.sndcoract = rem.sndcoract.
	    remdel.stn = rem.stn.
	    remdel.svc = rem.svc.
	    remdel.svcaaa = rem.svcaaa.
	    remdel.tby = rem.tby.
	    remdel.tcby = rem.tcby.
	    remdel.tctim = rem.tctim.
	    remdel.tcwhn = rem.tcwhn.
	    remdel.tdfb = rem.tdfb.
	    remdel.tim = rem.tim.
	    remdel.tlx = rem.tlx.
	    remdel.ttim = rem.ttim.
	    remdel.twhn = rem.twhn.
	    remdel.valdt = rem.valdt.
	    if rem.vjh = ? then remdel.vjh = vjh5.
	    else remdel.vjh = rem.vjh.
	    remdel.whn = rem.whn.
	    remdel.who = rem.who.
	    remdel.who1 = g-ofc.
	    remdel.whn1 = g-today.
	    remdel.tim1 = time.
