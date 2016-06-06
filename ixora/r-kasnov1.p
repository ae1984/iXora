/* r-kasnov".p
 * MODULE
         ОД отчетность
 * DESCRIPTION
         Счета Касса Нова за период
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
        17/08/10 marina
 * CHANGES
        14.09.10 marinav - добавлены поля валюта и дата закрытия
        15.03.2011 aigul - добавила if AVAIL CRCHIS
*/



find first txb.cmp.

def var v-sum as deci .
def var d-cls as date .
def shared var d1 as date.
def shared var d2 as date.
def shared stream m-out.


for each txb.aaa where txb.aaa.regdt >= d1  and txb.aaa.regdt <= d2 and lookup(txb.aaa.lgr,"247,248,160,161") > 0 no-lock.
  v-sum = 0.
  d-cls = ?.
  find first txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.

  for each txb.joudoc where txb.joudoc.whn >= d1 and txb.joudoc.whn <= d2 and (txb.joudoc.dracc = txb.aaa.aaa or txb.joudoc.cracc = txb.aaa.aaa) and txb.joudoc.jh <> ? no-lock.
      find last txb.crchis where txb.crchis.crc = txb.joudoc.comcur and txb.crchis.rdt <= txb.joudoc.whn no-lock no-error.
      if avail crchis then v-sum = v-sum + (txb.joudoc.comamt + txb.joudoc.nalamt) * txb.crchis.rate[1].
  end.
  find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' and txb.sub-cod.ccode <> 'msc' no-lock no-error.
  if avail txb.sub-cod then d-cls = txb.sub-cod.rdt.

        put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>" txb.aaa.name "</TD>" skip
               	       "<TD>" txb.aaa.aaa "</TD>" skip
               	       "<TD>" txb.crc.code "</TD>" skip
               	       "<TD>" txb.aaa.regdt "</TD>" skip
               	       "<TD>" d-cls "</TD>" skip
                       "<TD>" replace(trim(string(v-sum , "->>>>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               	       "<TD>" txb.cmp.name "</TD>" skip
                     "</TR>" skip.


end.
