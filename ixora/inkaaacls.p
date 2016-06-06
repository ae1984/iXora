/*inkaaacls.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Возврат ИР при закрытии счета
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
        11/06/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        28/10/2010 madiyar - перекомпиляция
        06/06/2011 evseev - переход на ИИН/БИН
        28/04/2012 evseev - логирование значения aaa.hbal
        20.06.2012 evseev - добавил mn.
*/


{global.i}
{comm-txb.i}
{get-dep.i}
def input parameter p-aaa like aaa.aaa.
def var op_kod as char format "x(1)".
def buffer b-inc100 for inc100.
def buffer b-aas for aas.
def var vparam2 as char.
def var d-SumOfPlat as decimal.
def var vdel as char initial "^".
def var rcode as inte.
def var rdes as char.
def var v-sum as decimal.
def var v-jhink like jh.jh.
def var s-vcourbank as char.
def var v-usrglacc as char.
def var v-ofc1 as char.
def var v-knaaa like aaa.aaa.
def var t-sum as decimal.
def var s-aaa as char.

{aas2his.i &db = "bank"}

for each inc100 where inc100.iik = p-aaa and (inc100.mnu = 'blk' or inc100.mnu = 'pay' or inc100.mnu = 'K2_sent') exclusive-lock:
  if inc100.mnu = 'pay' and inc100.stat <> 1 then next.
  find first aaa where aaa.aaa = p-aaa no-lock no-error.
  if not avail aaa then next.
  find first cif where cif.cif = aaa.cif no-lock no-error.
  if not avail cif then next.
  find last aas where aas.aaa = p-aaa and aas.fnum = string(inc100.num) no-lock no-error.
  if not avail aas then next.
  /*удаление блокировок и снятие с внебаланса*/
  find current aas exclusive-lock.
  find current aaa exclusive-lock.
  run savelog("aaahbal", "inkaaacls ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
  aaa.hbal = aaa.hbal - aas.chkamt.
  op_kod= 'D'.
  aas.sta = 4.
  aas.mn = substr(aas.mn,1,4) + "2".
  aas.tim = time + 1.
  aas.whn = g-today.
  aas.who = g-ofc.
  s-aaa = aaa.aaa.
  RUN aas2his.
  v-sum = decimal(aas.docprim).
  delete aas.
  /* с внебаланса */
  t-sum = 0.
  for each b-aas where b-aas.aaa = aaa.aaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16") <> 0 no-lock.
     t-sum = t-sum + b-aas.chkamt.
  end.
  run savelog("aaahbal", "inkaaacls ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
  aaa.hbal = aaa.hbal - t-sum.
  d-SumOfPlat = v-sum.
  {vnebal.i}
  run savelog("aaahbal", "inkaaacls ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
  aaa.hbal = aaa.hbal + t-sum.
  find current aaa no-lock.

  inc100.stat2 = "01". /*возврат в связи с закрытием счета*/
  inc100.mnu = "returned".
  run inkst01(inc100.iik,inc100.num).
end.