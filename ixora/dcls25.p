/* dcls25.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Автоматическое закрытие срочных депозитных счетов без остатка на 1 уровне
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
        05/01/05 dpuchkov
 * CHANGES
        06/01/05 dpuchkov добавил проверку на cbal = 0.
        26.01.05 dpuchkov добавил проверку на наличие средств на 2 (если на 2 есть деньги то счет не закрываем).
	28.07.06 dpuchkov добавил принудительное проставление дат в sub-cod при закрытии счетов.
	    17.04.2009 galina - не закрывать депозиты с нулевой суммой, которые открыты до 02.11.2009
	    11/11/2009 galina - убрала ссылку на дату 02/11/2009
	    24/06/2010 id00004 - добавил  заморозку сумм на депозитах (кроме МетроСтандарт)
        08/09/2011 evseev - добавил  заморозку сумм на депозитах A22,A23,A24 открытых после 01/08/11
*/

{global.i}

def var fname1 as char.

fname1 = "accclose" + substring(string(g-today),1,2) +
          substring(string(g-today),4,2) + ".txt".

def stream m-out.
output stream m-out to accclose.txt.

     for each lgr where lgr.led = "TDA" no-lock:
       for each aaa where aaa.lgr = lgr.lgr and aaa.sta <> "C" /* and aaa.sta <> "E" */
           and aaa.cbal = 0 and aaa.cr[1] - aaa.dr[1] = 0 and aaa.cr[2] - aaa.dr[2] = 0  exclusive-lock:
            find last cif where cif.cif = aaa.cif and cif.type = "P" no-lock no-error.
            if avail cif then
            do:
                 if aaa.dr[1] = 0 and aaa.cr[1] = 0 and aaa.cdt = ? and aaa.ddt = ? and not can-find(first aal of aaa) and
                    not can-find(first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and (trxbal.dam ne 0 or cam ne 0)) then
                 do:
                    for each sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa.
                        delete sub-cod.
                    end.
                    put stream m-out unformatted aaa.aaa " closed as menu 1.2"  skip.
                     delete aaa.
                 end.

                 else do:
                   aaa.sta = "C".
                   aaa.whn = g-today.

                   find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
                   if avail sub-cod then do:
                      sub-cod.rdt = g-today.
                   end.
                   put stream m-out unformatted aaa.aaa skip.
                 end.
            end.
       end.
     end.


output stream m-out close.
unix silent mv accclose.txt value(fname1).


/**/



find last sysc where sysc.sysc = "OURBNK" no-lock no-error.
for each aaa no-lock:
    find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
    if not avail lgr then next.
    if lgr.led = "TDA" or lgr.led = "CDA" or lgr.led = "DDA" or lgr.led = "SAV" then do:


       find last aadrt where aadrt.idclr = aaa.aaa and aadrt.prim = sysc.chval and aadrt.prim2 = aaa.cif exclusive-lock no-error.
       if avail aadrt then do:
          if aadrt.who = "C"  then next.
          else do:
               if aaa.sta = "C" then do:
                  aadrt.who = "C" .
                  aadrt.whn = g-today.
               end.
          end.
       end.
       else do:
            create aadrt.
                   aadrt.idclr = aaa.aaa.
                   aadrt.prim = sysc.chval.
                   aadrt.prim2 = aaa.cif.
                   aadrt.who = aaa.sta.
                   if aaa.sta = "C" then do:
                      aadrt.whn = g-today.
                   end.
       end.
    end.
end.



/* Автоматическая заморозка сумм на депозитных счетах */
     find last sysc where sysc.sysc = "citi" no-lock no-error.
     def buffer b-aas for aas .
     def var b-summ as decimal.
     for each lgr where lgr.led = "TDA" no-lock:
         for each aaa where aaa.lgr = lgr.lgr and aaa.sta <> "C" and aaa.sta <> "E" exclusive-lock:
             find last aas where aas.aaa = aaa.aaa and aas.ln = 7777777 exclusive-lock no-error.
             if not avail aas then next.
             if aaa.regdt < 08/01/2011 and lookup(aaa.lgr,"A22,A23,A24") <> 0 then next.
             if lookup(aaa.lgr,"A13,A14,A15,A19,A20,A21,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36,A22,A23,A24") <> 0 then do:
                if aaa.cbal <> aas.chkamt then do:
                   aas.chkamt = aaa.cbal.
                   b-summ = 0.
                   for each b-aas where b-aas.aaa = aaa.aaa no-lock:
                       b-summ = b-summ + b-aas.chkamt.
                   end.
                   aaa.hbal = b-summ.
                   run mail("denis@metrobank.kz", "<deposit@metrocombank.kz>", "Доступный остаток", "По депозитному счету: " + aaa.aaa  + " " + sysc.chval + "\n  обнаружен доступный остаток " + string(aaa.cbal - aas.chkamt) + "\n  " , "1", "","").
                   run mail("id00787@metrocombank.kz", "<deposit@metrocombank.kz>", "Доступный остаток", "По депозитному счету: " + aaa.aaa  + " " + sysc.chval + "\n  обнаружен доступный остаток " + string(aaa.cbal - aas.chkamt) + "\n  " , "1", "","").
                end.

             end.
         end.
     end.
