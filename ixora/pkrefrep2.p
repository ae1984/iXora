/* pkrefrep2.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчет по рефинансированию
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
        22/05/2006 madiyar
 * CHANGES
*/

define var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

function get-dep returns int (usr as char, dat as date).
    find last txb.ofchis where txb.ofchis.ofc = usr and txb.ofchis.regdt <= dat use-index ofchis no-lock no-error.
    if not avail txb.ofchis then
    find first txb.ofchis where txb.ofchis.ofc = usr and txb.ofchis.regdt >= dat use-index ofchis no-lock no-error.
    if avail txb.ofchis then return txb.ofchis.depart.
    else return -1.
end.

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field dpt as integer
  field dptname as char
  field num as integer
  field sum as decimal
  field sumod as decimal
  field sumold as decimal
  index idx is primary bank dpt.

def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.

def buffer b-lon for txb.lon.
def var v-dpt as integer no-undo.
def var v-dptname as char no-undo.

find first txb.cmp no-lock no-error.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and pkanketa.docdt >= dt1 and pkanketa.docdt <= dt2 no-lock:
  
  if pkanketa.lon = '' then next.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'rnn' no-lock no-error.
  if avail pkanketh then do:
    if pkanketh.rescha[1] <> '' then do:
      find first b-lon where b-lon.lon = entry(1,pkanketh.rescha[1]) no-lock no-error.
      if not avail b-lon then next.
    end.
    else next.
  end.
  else next.
  
  find first txb.lon where txb.lon.lon = pkanketa.lon no-lock no-error.
  if not avail txb.lon then next.
  
  if s-ourbank = "txb00" then do:
    v-dpt = get-dep(txb.lon.who,txb.lon.rdt).
    find first txb.ppoint where txb.ppoint.depart = v-dpt no-lock no-error.
    if avail txb.ppoint then v-dptname = txb.ppoint.name.
  end.
  else do: v-dpt = 0. v-dptname = txb.cmp.name. end.
  
  find first wrk where wrk.bank = s-ourbank and wrk.dpt = v-dpt no-lock no-error.
  if not avail wrk then do:
    create wrk.
    assign wrk.bank = s-ourbank
           wrk.bankn = txb.cmp.name
           wrk.dpt = v-dpt
           wrk.dptname = v-dptname.
  end.
  wrk.num = wrk.num + 1.
  wrk.sum = wrk.sum + txb.lon.opnamt.
  wrk.sumold = wrk.sumold + b-lon.opnamt.
  find last txb.lnsch where txb.lnsch.lnn = b-lon.lon and txb.lnsch.f0 = 0 and txb.lnsch.stdat = txb.lon.rdt no-lock no-error.
  if avail txb.lnsch then wrk.sumod = wrk.sumod + txb.lnsch.paid.
  
  displ s-ourbank label "Банк"
        v-dpt label "Деп"
        txb.lon.cif
        txb.lon.lon
        txb.lon.opnamt label "ВыдСумРеф" format ">,>>>,>>9.99"
        b-lon.opnamt label "ВыдСумСтар" format ">,>>>,>>9.99"
        txb.lnsch.paid label "ПогашОД" format ">,>>>,>>9.99".
  
end. /* for each pkanketa */

