/* chk_inkins1.p
 * MODULE
        Проверка в aas ИР РПРО
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
        28/06/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        28/06/2011 evseev - для отзыва РПРО добавил время ожидания 2000
        07/07/2011 evseev - добавил if lookup (inc100.stat, "14") > 0 then next.
        07/07/2011 evseev - поправил на if lookup (string(inc100.stat), "14") > 0 then next.
        25/07/2011 evseev - добавил if lookup (string(inc100.stas), "13,14") > 0 then next.
        28/09/2011 evseev - добавил inkor1.stat <> "20"
        27/10/2011 evseev - добавил  if lookup (string(insrec.stat), "13") > 0 then next.
        13.06.2012 evseev - поправил алгоритм
        24.12.2012 evseev

*/


def input parameter bank as char no-undo.
def var v-mailmessage as char.

v-mailmessage = ''.
for each inc100 where inc100.bank = bank and inc100.rdt >= today - 7 no-lock :
   if (inc100.rdt = today) and ((time - inc100.rtm) <= 2000) then next.
   if lookup (string(inc100.stat), "13,14,15") > 0 then next.
   find first txb.aas_hist where txb.aas_hist.aaa = inc100.iik and txb.aas_hist.fnum = string(inc100.num) no-lock no-error.
   if not avail txb.aas_hist then do:
     if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
     v-mailmessage = v-mailmessage + " ref = " + inc100.ref + "; stat = " + string(inc100.stat) + "; mnu = " + inc100.mnu + "; num = " + string (inc100.num).
   end.
end.

if v-mailmessage <> "" then do:
       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: ИР не посажены в аресты " + bank,
                    v-mailmessage, "1", "", "").
end.


v-mailmessage = ''.
for each insin where insin.bank = bank and insin.rdt > today - 7 no-lock:
   if (insin.rdt = today) and ((time - insin.rtm) <= 2000) then next.
   if lookup (string(insin.stat), "13,14") > 0 then next.
   find first txb.aas_hist where (lookup(txb.aas_hist.aaa, insin.blkaaa) > 0) and txb.aas_hist.docnum = insin.numr no-lock no-error.
   if not avail txb.aas_hist then do:
     if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
     v-mailmessage = v-mailmessage + " ref = " + insin.ref + "; stat = " + string(insin.stat) + "; mnu = " + insin.mnu + "; numr = " + insin.numr.
   end.
end.

if v-mailmessage <> "" then do:
       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: РПРО не посажены в аресты " + bank,
                    v-mailmessage, "1", "", "").
end.

v-mailmessage = ''.
for each inkor1 where inkor1.rdt >= today - 7 and inkor1.stat <> "20" no-lock :
   if (inkor1.rdt = today) and ((time - inkor1.rtm) <= 2000) then next.
   find first inc100 where inc100.ref = inkor1.inkref no-lock no-error.
   if avail inc100 then  do:
      if inc100.bank <> bank then next.
   end. else  do:
      run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: На отзыв не найдено ИР " + bank,"ref = " + inkor1.ref, "1", "", "").
      next.
   end.
   find first txb.aas where txb.aas.aaa = inc100.iik and txb.aas.fnum = string(inkor1.inknum) no-lock no-error.
   if avail txb.aas then do:
     if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
     v-mailmessage = v-mailmessage + " ref = " + inkor1.ref + "; inkref = " + inc100.ref.
   end.
end.

if v-mailmessage <> "" then do:
       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: ИР не снято с ареста " + bank,
                    v-mailmessage, "1", "", "").
end.

v-mailmessage = ''.
for each insrec where insrec.rdt >= today - 7 no-lock:
   if (insrec.rdt = today) and ((time - insrec.rtm) <= 2000) then next.
   if lookup (string(insrec.stat), "13") > 0 then next.
   find first insin where insin.ref = insrec.insref no-lock no-error.
   if avail insin then do:
      if insin.bank <> bank then next.
   end. else  do:
      run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: На отзыв не найдено РПРО " + bank,"ref = " + insrec.ref, "1", "", "").
      next.
   end.

   find first txb.aas where  (lookup(txb.aas.aaa, insin.blkaaa) > 0) and (txb.aas.docnum = insrec.insnum) no-lock no-error.
   if avail txb.aas then do:
     if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
     v-mailmessage = v-mailmessage + " ref = " + insrec.ref + "; insref = " + insrec.insref.
   end.
end.

if v-mailmessage <> "" then do:
   run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: РПРО не снято с ареста " + bank,v-mailmessage, "1", "", "").
end.
