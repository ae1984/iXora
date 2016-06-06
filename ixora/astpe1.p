/* astpe1.p
 * MODULE
        OC
 * DESCRIPTION
        Перенос ОС между подразделениями
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
        BANK COMM TXB
 * AUTHOR
        03/09/2010 marinav
 * CHANGES
        09.12.10 marinav - счет первым параметром в sysc
        21/05/2012 Luiza - если остаточная стоимость равна нулю при передаче ОС копируем все поля табл ast
*/


def shared var v-ast like bank.ast.ast format "x(8)".
def shared var v-arp like bank.arp.arp.
def shared var v-rnn as char.
def shared var v-bname as char.
def shared var v-qty like bank.ast.qty format "zzz,zz9".
def shared var txb-ast like bank.ast.ast format "x(8)".
def shared var v-atl  like bank.ast.icost format "zzzzzzzz,zz9.99".
def shared var g-today as date.
def shared var g-ofc as char.

  find first txb.cmp no-lock no-error.
  v-rnn = txb.cmp.addr[2].
  v-bname = txb.cmp.name.

  find first txb.sysc where txb.sysc.sysc = 'tros' no-lock no-error.
  v-arp = entry(1,txb.sysc.chval).


  find bank.ast where bank.ast.ast = v-ast no-lock.
  find txb.fagn where txb.fagn.fag = bank.ast.fag exclusive-lock no-error.
  txb-ast = txb.fagn.fag + string(txb.fagn.pednr, "99999").
  txb.fagn.pednr = txb.fagn.pednr + 1.
  create txb.ast.
      txb.ast.ast = txb-ast.
      txb.ast.qty = v-qty.
      if v-atl  = 0 then do:
        buffer-copy bank.ast except bank.ast.ast bank.ast.attn bank.ast.icost bank.ast.qty bank.ast.dam bank.ast.cam to txb.ast.
        txb.ast.updt = g-today.
        txb.ast.ofc = g-ofc.
       /* txb.ast.dam[1] = bank.ast.dam[1].
        txb.ast.dam[2] = bank.ast.dam[2].
        txb.ast.dam[3] = bank.ast.dam[3].
        txb.ast.dam[4] = bank.ast.dam[4].
        txb.ast.dam[5] = bank.ast.dam[5].

        txb.ast.cam[1] = bank.ast.cam[1].
        txb.ast.cam[2] = bank.ast.cam[2].
        txb.ast.cam[3] = bank.ast.cam[3].
        txb.ast.cam[4] = bank.ast.cam[4].
        txb.ast.cam[5] = bank.ast.cam[5].*/

        txb.ast.amt[1] = bank.ast.amt[1].
        txb.ast.amt[2] = bank.ast.amt[2].
        txb.ast.amt[3] = bank.ast.amt[3].
        txb.ast.amt[4] = bank.ast.amt[4].
        txb.ast.amt[5] = bank.ast.amt[5].

        txb.ast.mdam[1] = bank.ast.mdam[1].
        txb.ast.mdam[2] = bank.ast.mdam[2].
        txb.ast.mdam[3] = bank.ast.mdam[3].
        txb.ast.mdam[4] = bank.ast.mdam[4].
        txb.ast.mdam[5] = bank.ast.mdam[5].

        txb.ast.mcam[1] = bank.ast.mcam[1].
        txb.ast.mcam[2] = bank.ast.mcam[2].
        txb.ast.mcam[3] = bank.ast.mcam[3].
        txb.ast.mcam[4] = bank.ast.mcam[4].
        txb.ast.mcam[5] = bank.ast.mcam[5].

        txb.ast.ddt[1] = bank.ast.ddt[1].
        txb.ast.cdt[1] = bank.ast.cdt[1].
        txb.ast.rdt = bank.ast.rdt.
        txb.ast.gl = bank.ast.gl.
        txb.ast.fag = bank.ast.fag.
        txb.ast.cont = bank.ast.cont.
        txb.ast.crc = bank.ast.crc.
        txb.ast.meth = bank.ast.meth.
      end.
      else buffer-copy bank.ast except bank.ast.ast bank.ast.attn bank.ast.icost bank.ast.qty bank.ast.dam bank.ast.cam  to txb.ast.
      txb.ast.addr[1] = ''.







