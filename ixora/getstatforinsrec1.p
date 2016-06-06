/* getstatforinsrec1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        12/05/2011 evseev - возврат статуса для отзывов РПРО
 * BASES
        COMM TXB
 * CHANGES
        17.05.2011 evseev - добавил propath v-propath
        19.05.2011 evseev - исправил ошибку. txb.cif.jss = insin.clrnn на txb.cif.jss <> insin.clrnn
        08/06/2011 evseev - переход на ИИН/БИН
*/
{chbin_txb.i}
def input parameter i-ref like insin.ref no-undo.
def shared var s-stat  like insrec.stat no-undo.

def buffer b-cif for txb.cif.
def var k as integer no-undo.

def var v-propath as char no-undo.
v-propath = propath.
propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.

find first insin where insin.ref = i-ref no-lock no-error.

s-stat = '12'. /*Документ не принят. Счет плательщика не найден*/
k = 1.
aa:
repeat:
  find first txb.aaa where txb.aaa.aaa = entry(k,insin.blkaaa) no-lock no-error.
  if avail txb.aaa then do:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then do:
      if v-bin then find first b-cif where b-cif.bin = insin.clbin no-lock no-error.
      else find first b-cif where b-cif.jss = insin.clrnn no-lock no-error.
      if avail b-cif then s-stat = '16'. /*Документ не принят. Неверный код плательщика*/
      else s-stat = '11'. /*Документ не принят. Клиент-плательщик не найден*/
    end.
    else do:
      if v-bin then do:
          if txb.cif.bin <> insin.clbin then s-stat = '16'. /*Документ не принят. Неверный код плательщика*/
          else do:
            if (txb.aaa.sta ne "C") and (txb.aaa.sta ne "E") then do:
              find last txb.aas where txb.aas.aaa = entry(k,insin.blkaaa) and txb.aas.docnum = insin.numr no-lock no-error.
              find last txb.aas_his where txb.aas_his.aaa = entry(k,insin.blkaaa) and txb.aas_his.docnum = insin.numr no-lock no-error.
              if avail txb.aas or avail txb.aas_his then do:
                 s-stat = '01'. /*Документ принят банком*/
                 leave.
              end.
              else s-stat = "err".
            end.
            else s-stat = '13'. /*Документ не принят. Счет плательщика закрыт*/
          end.
      end. else do:
          if txb.cif.jss <> insin.clrnn then s-stat = '16'. /*Документ не принят. Неверный код плательщика*/
          else do:
            if (txb.aaa.sta ne "C") and (txb.aaa.sta ne "E") then do:
              find last txb.aas where txb.aas.aaa = entry(k,insin.blkaaa) and txb.aas.docnum = insin.numr no-lock no-error.
              find last txb.aas_his where txb.aas_his.aaa = entry(k,insin.blkaaa) and txb.aas_his.docnum = insin.numr no-lock no-error.
              if avail txb.aas or avail txb.aas_his then do:
                 s-stat = '01'. /*Документ принят банком*/
                 leave.
              end.
              else s-stat = "err".
            end.
            else s-stat = '13'. /*Документ не принят. Счет плательщика закрыт*/
          end.
      end.
    end.
  end. /*avail aaa*/

  if k = num-entries(insin.iik) then leave.
  else do:
    k = k + 1.
    next aa.
  end.

end. /*repeat*/
propath = v-propath no-error.