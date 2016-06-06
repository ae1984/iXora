/* pkpog2.p
 * MODULE
         Потребит кредитование
 * DESCRIPTION
        Список погашенных кредитов
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
        21/10/2009 marinav 
 * CHANGES
*/

def shared var datums as date no-undo format '99/99/9999' label 'С'.
def shared var datums2 as date no-undo format '99/99/9999' label 'по'.
def new shared var v-sel as char.


def shared temp-table wrk no-undo
    field name     like bank.cif.name
    field fu       as   char
    field fil      as   char
    field lon      like bank.lon.lon
    field crc      like bank.crc.code
    field opnamt   like bank.lon.opnamt
    field opnamtKZ like bank.lon.opnamt
    field prem     like bank.lon.prem
    field rdt      like bank.lon.rdt
    field duedt    like bank.lon.rdt
    field dtcls    like bank.lnsch.stdat
    field amtdue   like bank.lon.opnamt
    field amtprov  like bank.lon.opnamt
    field pr_ref   as   char
    field gl       like bank.lon.gl.

def var bilance as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var bilance0 as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-str as char no-undo.
def var v-delim as char no-undo init "^".


define var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
s-ourbank = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.


for each txb.lon where txb.lon.rdt <= datums2 no-lock .
  if txb.lon.opnamt <= 0 then next.
  
  run lonbalcrc_txb('lon',txb.lon.lon,datums2,"1,2,7,9,13,14",yes,txb.lon.crc,output bilance).
  
  if bilance ne 0 then next.
  
  if txb.lon.rdt < datums then do:
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,2,7,9,13,14",no,txb.lon.crc,output bilance0).
    if bilance0 <= 0 then next.
  end.
  
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
  find txb.crc where txb.crc.crc = txb.lon.crc no-lock.
  find first txb.sub-cod where txb.sub-cod.sub = 'lon' and  txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'pkpur' no-lock no-error.
  find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= txb.lon.rdt no-lock no-error.

  create wrk.
        wrk.name = txb.cif.name.
        if txb.cif.type = 'B' then wrk.fu = 'Ю/Л'. else wrk.fu = 'Ф/Л'.
        wrk.fil = entry(1,txb.cmp.addr[1],",").
        wrk.lon = txb.lon.lon.
        wrk.crc = txb.crc.code.
        wrk.opnamt = txb.lon.opnamt.
        wrk.opnamtKZ = txb.lon.opnamt * txb.crchis.rate[1].
        wrk.prem = txb.lon.prem.
        wrk.rdt = txb.lon.rdt.
        wrk.duedt = txb.lon.duedt.

        find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 no-lock no-error.
        if avail txb.lnsch then do:
          wrk.dtcls = txb.lnsch.stdat.
        end.

        find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 no-lock no-error.
        if avail txb.lnsci and  txb.lnsci.idat > wrk.dtcls then do:
          wrk.dtcls = txb.lnsci.idat.
        end.

        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= wrk.dtcls no-lock no-error.
        run lonbalcrc_txb('lon',txb.lon.lon,wrk.dtcls,"1,7",no,txb.lon.crc,output bilance).
        wrk.amtdue = bilance * txb.crchis.rate[1].

        run lonbalcrc_txb('lon',txb.lon.lon,wrk.dtcls,"6",no,txb.lon.crc,output bilance).
        wrk.amtprov = -(bilance * txb.crchis.rate[1]).

        wrk.gl = txb.lon.gl.
        if avail txb.sub-cod and txb.sub-cod.ccode = '10' then wrk.pr_ref = 'РЕФ'.


end. /* for each lon */
