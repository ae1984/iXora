/* inktrx.p
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
        03/08/05 dpuchkov
 * CHANGES
        08.08.05 dpuchkov перекомпиляция
        17.11.2008 alex - Инкассовые, постановка на картотеку
        27.11.2008 alex - Исправления.
        08/04/2010 galina - снимаем приостновление по СО aas.sta = 17
        28/10/2010 madiyar - перекомпиляция
        06/06/2011 evseev - переход на ИИН/БИН
        28/04/2012 evseev - логирование значения aaa.hbal
        21.06.2012 evseev - добавил mn.
        27.06.2012 evseev - ТЗ-1233
        17.09.2012 evseev - ТЗ-1445
*/

{global.i}
{comm-txb.i}
{get-dep.i}

def input parameter v-rmz as char.               /* RMZ      */
def input parameter irnum as char.               /* номер ИР */
def input parameter v-sum as decimal decimals 2. /* сумма оплаты из rmz */
def input parameter v-acc as char.               /* счет  */


def buffer b-aas for aas.

def var op_kod as char format "x(1)".
def var d-SumOfPlat as decimal.
def var vdel as char initial "^".
def var rcode as inte.
def var rdes as char.
def var v-jhink like jh.jh.
def var s-vcourbank as char.
def var v-usrglacc as char.
def var v-ofc1 as char.
def var v-knaaa like aaa.aaa.
def var v-fsum   like aas.fsum.
def var v-docdat like aas.docdat.
def var v-knp    like aas.knp.
def var v-kbk    like aas.kbk.
def var v-who    like aas.who.
def var v-whn    like aas.whn.
def var s-aaa like aaa.aaa no-undo.
def var vparam2 as char.

def var t-sum as decimal.
def var v-rgref as char.

{aas2his.i &db = "bank"}

run savelog( "inkps", "test_inktrx: 1... v-rmz=" + v-rmz + " irnum=" + irnum + " v-sum=" + string(v-sum) + " v-acc=" + v-acc).


do transaction:
  run savelog( "inkps", "test_inktrx: 2... v-rmz=" + v-rmz + " irnum=" + irnum + " v-sum=" + string(v-sum) + " v-acc=" + v-acc).
  find last aas where aas.aaa = v-acc and aas.fnum = irnum exclusive-lock no-error.
  find last aaa where aaa.aaa = v-acc exclusive-lock no-error.
  if avail aaa then find last cif where cif.cif = aaa.cif no-lock no-error.
  if avail aas and avail aaa and avail cif then do:
     run savelog( "inkps", "test_inktrx: 3... v-acc=" + v-acc + " v-sum=" + string(v-sum) + " aas.docprim=" + aas.docprim).
     /*полностью*/
     if v-sum = decimal(aas.docprim) then do:
        run savelog( "inkps", "test_inktrx: 4... v-acc=" + v-acc).
        aas.sta = 6.
        aas.irsts = "полностью".
        run savelog("aaahbal", "inktrx 79; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
        aaa.hbal = aaa.hbal - aas.chkamt.
        aas.chkamt = 0.
        aas.tim = time.
        op_kod = 'P'.
        aas.whn = g-today.
        aas.who = g-ofc.
        aas.mn = substr(aas.mn,1,4) + "3".
        s-aaa = aaa.aaa.
        RUN aas2his.
        op_kod= 'D'.
        aas.sta = 4.
        aas.tim = time + 1.
        aas.who = g-ofc.
        aas.whn = g-today.
        aas.mn = substr(aas.mn,1,4) + "4".
        RUN aas2his.
        v-fsum  =  aas.fsum.
        v-docdat = aas.docdat.
        v-knp = aas.knp.
        v-kbk = aas.kbk.
        /* помечаем как оплаченный (inc100.mnu) */
        run savelog( "inkps", "test_inktrx: 5... aas.aaa=" + aas.aaa + " aas.fnum=" + aas.fnum).
        find first inc100 where inc100.iik eq aas.aaa and inc100.num eq integer(aas.fnum) and inc100.rgref = aas.rgref exclusive-lock no-error.
        if avail inc100 then do:
           run savelog( "inktrx", "106. " + inc100.ref + " inc100.iik=" + aas.aaa + " inc100.num=" + aas.fnum + " inc100.rgref=" + inc100.rgref).
           v-rgref = inc100.rgref.
           inc100.mnu = "paid".
           find current inc100 no-lock.
           run savelog( "inkps", "test_inktrx: 6... inc100.ref=" + inc100.ref + " inc100.mnu=" + inc100.mnu).
        end. else do:
           v-rgref = "".
           run savelog( "inktrx", "113. Нет данных в inc100 inc100.iik=" + aas.aaa + " inc100.num=" + aas.fnum).
        end.
        /* помечаем как оплаченный (inc100.mnu) */
        delete aas.
        /*с внебаланса*/
        t-sum = 0.
        for each b-aas where b-aas.aaa = v-acc and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16,17") <> 0 or
                             b-aas.aaa = v-acc and b-aas.mn = "30037" no-lock.
            t-sum = t-sum + b-aas.chkamt.
        end.
        run savelog( "inkps", "test_inktrx: 7... v-acc=" + v-acc).
        run savelog("aaahbal", "inktrx 116; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
        aaa.hbal = aaa.hbal - t-sum.
        d-SumOfPlat = v-sum.
        {vnebal.i}
        run savelog("aaahbal", "inktrx 120; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
        aaa.hbal = aaa.hbal + t-sum.
        v-knaaa = aaa.aaa.
        /* снятие специнструкций с валютных счетов */
        run savelog( "inkps", "test_inktrx: 8... v-acc=" + v-acc).
        if aaa.crc = 1 then  do:
           run savelog( "inkps", "test_inktrx: crc1 1... v-acc=" + v-acc).
           for each aaa where aaa.cif = cif.cif and aaa.aaa <> v-knaaa /*aaa.crc <> 1*/ exclusive-lock:
               for each aas where aas.aaa = aaa.aaa and trim(aas.rgref) <> "" and aas.rgref = v-rgref
                  /*aas.fsum = v-fsum and aas.docdat = v-docdat and aas.knp = v-knp and aas.kbk = v-kbk*/ exclusive-lock:
                   run savelog( "inkps", "test_inktrx: crc1 2... aaa.aaa=" + aaa.aaa + " aas.fsum=" + string(aas.fsum)).
                   /* с внебаланса */
                   run savelog("aaahbal", "inktrx 131; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
                   aaa.hbal = aaa.hbal - aas.chkamt.
                   op_kod= 'D'.
                   aas.sta = 4.
                   aas.tim = time + 1.
                   aas.whn = g-today.
                   aas.who = g-ofc.
                   aas.docprim = string(decimal(aas.docprim) - v-sum).
                   aas.mn = substr(aas.mn,1,4) + "5".
                   s-aaa = aaa.aaa.
                   RUN aas2his.
                   run savelog( "inkps", "test_inktrx: crc1 3... aaa.aaa=" + aaa.aaa + " aas.fsum=" + string(aas.fsum)).
                   run inkst02(aas.aaa, aas.fnum, aas.rgref).
                   delete aas.
                   t-sum = 0.
                   for each b-aas where b-aas.aaa = aaa.aaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,8,16,17") <> 0 or
                                        b-aas.aaa = aaa.aaa and b-aas.mn = "30037" no-lock.
                       t-sum = t-sum + b-aas.chkamt.
                   end.
                   run savelog( "inkps", "test_inktrx: crc1 4... aaa.aaa=" + aaa.aaa).
                   run savelog("aaahbal", "inktrx 150; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
                   aaa.hbal = aaa.hbal - t-sum.
                   d-SumOfPlat = v-sum.
                   {vnebal.i}
                   run savelog("aaahbal", "inktrx 154; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
                   aaa.hbal = aaa.hbal + t-sum.
                   run savelog( "inkps", "test_inktrx: crc1 5... aaa.aaa=" + aaa.aaa).
               end.
           end.
        end.
     end. else do: /* частично */
        if avail aas and v-sum < decimal(aas.docprim) then do:
           if aas.sta = 9 or aas.sta = 15 then aas.sta = 15. else aas.sta = 5.
           aas.irsts = "частично".
           op_kod = 'L'.
           aas.tim = time.
           v-who = aas.who.
           v-whn = aas.whn.
           aas.whn = g-today.
           aas.who = g-ofc.
           aas.docprim = string( decimal(aas.docprim) - v-sum).
           aas.mn = substr(aas.mn,1,4) + "6".
           s-aaa = aaa.aaa.
           RUN aas2his.
           aas.whn = v-whn.
           aas.who = v-who.
           /* с внебаланса */
           t-sum = 0.
           for each b-aas where b-aas.aaa = aaa.aaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16,17") <> 0 or
                                b-aas.aaa = aaa.aaa and b-aas.mn = "30037" no-lock.
               t-sum = t-sum + b-aas.chkamt.
           end.
           run savelog("aaahbal", "inktrx 181; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
           aaa.hbal = aaa.hbal - t-sum.
           d-SumOfPlat = v-sum.
           {vnebal.i}
           run savelog("aaahbal", "inktrx 185; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
           aaa.hbal = aaa.hbal + t-sum.
           v-fsum  =  aas.fsum.
           v-docdat = aas.docdat.
           v-knp = aas.knp.
           v-kbk = aas.kbk.
           v-knaaa = aaa.aaa.
           v-rgref = aas.rgref.
           /* снятие специнструкций с валютных счетов если счет тенговый*/
           if aaa.crc = 1 then  do:
              for each aaa where aaa.cif = cif.cif and aaa.aaa <> v-knaaa exclusive-lock:
                  for each aas where aas.aaa = aaa.aaa and trim(aas.rgref) <> "" and aas.rgref = v-rgref
                      /*and aas.fsum = v-fsum and aas.docdat = v-docdat and aas.knp = v-knp and aas.kbk = v-kbk*/ exclusive-lock:
                      /*с внебаланса*/
                      aas.docprim = string( decimal(aas.docprim) - v-sum).
                      t-sum = 0.
                      for each b-aas where b-aas.aaa = aaa.aaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16,17") <> 0 or
                                           b-aas.aaa = aaa.aaa and b-aas.mn = "30037"  no-lock.
                          t-sum = t-sum + b-aas.chkamt.
                      end.
                      run savelog("aaahbal", "inktrx 202; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
                      aaa.hbal = aaa.hbal - t-sum.
                      d-SumOfPlat = v-sum.
                      {vnebal.i}
                      run savelog("aaahbal", "inktrx 206; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
                      aaa.hbal = aaa.hbal + t-sum.
                  end.
              end.
           end.
        end.
     end.
     find last aaar where aaar.a1 = v-rmz exclusive-lock no-error.
     if avail aaar then do:
        aaar.a4 = "1".  /* первая проводка сделана считаем платеж проплаченным */
     end.
  end.
end.
