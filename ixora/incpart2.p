/* incpart.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Отчет по частичной оплате ИР
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14/05/2009 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        07.07.2009 galina - добавила вид операции
        20/06/2011 evseev - изменение в inkstat.i
        23/06/2011 evseev - изменение в inkstat.i
        28.05.2012 evseev - добавил поле референс

*/

def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.
def input parameter p-acc as char no-undo.

{inkstat.i}
def shared temp-table wrk no-undo
  field ref like inc100.ref
  field num like inc100.num
  field clname like inc100.name
  field iik like inc100.iik
  field sum like inc100.sum
  field ost as deci
  field stat like inc100.stat
  field rdt like inc100.rdt
  field rtm like inc100.rtm
  field mnu like inc100.mnu
  field bank as char
  field bankname as char
  field dtpay as date
  field sumpay as deci
  field vo as char
  index idx is primary bank num.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-bankname as char no-undo.
find first comm.txb where comm.txb.bank = s-ourbank no-lock no-error.
if avail comm.txb then v-bankname = trim(txb.info).
else v-bankname = s-ourbank.

if ((dt1 = ?) or (dt2 = ?)) and p-acc = "" then do:
    for each inc100 where inc100.bank = s-ourbank no-lock:
        run report.
    end.
end.

if ((dt1 = ?) or (dt2 = ?)) and p-acc <> "" then do:
    for each inc100 where inc100.bank = s-ourbank and inc100.iik = p-acc no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and p-acc = "" then do:
    for each inc100 where inc100.bank = s-ourbank and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

if dt1 <> ? and dt2 <> ? and p-acc <> "" then do:
    for each inc100 where inc100.bank = s-ourbank and inc100.iik = p-acc and inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
        run report.
    end.
end.

procedure report.
    def var run1 as logi no-undo init yes.
    def var v-ost as deci no-undo init 0.
    find first txb.aas where txb.aas.aaa = inc100.iik and txb.aas.fnum = string(inc100.num) no-lock no-error.
    if avail txb.aas then v-ost = deci(txb.aas.docprim).
    for each txb.aaar where txb.aaar.a5 = inc100.iik and txb.aaar.a4 = '1' and txb.aaar.a2 = string(inc100.num) no-lock:
        if run1 then do:
            if deci(txb.aaar.a3) < inc100.sum then do:
                create wrk.
                assign wrk.ref = inc100.ref
                       wrk.num = inc100.num
                       wrk.clname = inc100.name
                       wrk.iik = inc100.iik
                       wrk.sum = inc100.sum
                       wrk.ost = v-ost
                       wrk.stat = inc100.stat
                       wrk.rdt = inc100.rdt
                       wrk.rtm = inc100.rtm
                       wrk.mnu = inc100.mnu
                       wrk.bank = s-ourbank
                       wrk.bankname = v-bankname
                       wrk.dtpay = date(txb.aaar.a6)
                       wrk.sumpay = deci(txb.aaar.a3).
            end.
            else leave.
            run1 = no.
        end. /* if run1 */
        else do:
            create wrk.
            assign wrk.ref = inc100.ref
                   wrk.num = inc100.num
                   wrk.clname = inc100.name
                   wrk.iik = inc100.iik
                   wrk.sum = inc100.sum
                   wrk.ost = v-ost
                   wrk.stat = inc100.stat
                   wrk.rdt = inc100.rdt
                   wrk.rtm = inc100.rtm
                   wrk.mnu = inc100.mnu
                   wrk.bank = s-ourbank
                   wrk.bankname = v-bankname
                   wrk.dtpay = date(txb.aaar.a6)
                   wrk.sumpay = deci(txb.aaar.a3).
        end.
        if lookup(inc100.vo, v-vo, "|") <> 0  then wrk.vo = inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|").
    end. /* for each txb.aaar */
end.
