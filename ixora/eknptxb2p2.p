/* eknptxb2.p
 * MODULE
        СТАТИСТИКА
 * DESCRIPTION
        Отчет о покупке/продаже иностранной валюты банком и его клиентами Раздел 2.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        eknp_f2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-9-6-5
 * BASES
        BANK COMM TXB
 * AUTHOR
        18/04/2006 dpuchkov
 * CHANGES
        26/05/2006 dpuchkov - изменил порядок вывода данныхв отчете
        09.06.2006 dpuchkov - добавил проверку на наличные деньги
*/


 def shared var vn-dt as date    no-undo.
 def shared var vn-dtbeg as date no-undo.

 def buffer b1 for txb.aaa.
 def buffer b2 for txb.aaa.

 def shared temp-table tmp-f2p2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field tgrez   as decimal decimals 2
     field tgnorez  as decimal decimals 2
     field valrez  as decimal decimals 2
     field valnorez  as decimal decimals 2.

 def shared temp-table tmp-d
     field djh as integer.


 def buffer b-f2p2 for tmp-f2p2.

function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for txb.crchis.
define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then 
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    
end.




 for each tmp-f2p2 break by tmp-f2p2.nom: /* покупка вал физ лицами */
     if tmp-f2p2.kod = 211000 then do:
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "P" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  /*резидент*/
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 2) .
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez.
     end.

     if tmp-f2p2.kod = 211400 then do:
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "P" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  /* резидент */
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez +  round(txb.jl.cam / 1000, 0).
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez.
     end.
     if tmp-f2p2.kod = 212000 then do: /* Покупка валюты юр лицами */
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  /*резидент*/
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez +  round(txb.jl.cam / 1000, 0).
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez  + round(txb.jl.cam / 1000, 0).
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez.
     end.



     if tmp-f2p2.kod = 212409 then do: /* Покупка валюты юр лицами */
/*        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock.
                find last b2 where b2.aaa = vclientaccno no-lock.
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif = "B" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez + (txb.jl.cam).
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + (txb.jl.cam).
                   end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez. */
     end.

     if tmp-f2p2.kod = 212411 then do: /* Покупка валюты юр лицами */
         run jhtagert("Осуществление платежей в пользу резидентов", "Покупка товаров и нематериальных активов").
     end.
     if tmp-f2p2.kod = 212412 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Получение услуг").  end.
     if tmp-f2p2.kod = 212413 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Выдача займов").    end.
     if tmp-f2p2.kod = 212414 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Выполнение обязательств по займам").     end.
     if tmp-f2p2.kod = 212415 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Расчеты по операциям с ценными бумагами").     end.
     if tmp-f2p2.kod = 212416 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Заработная плата").     end.
     if tmp-f2p2.kod = 212417 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Выплата командировочных и представительских расходов").     end.
     if tmp-f2p2.kod = 212418 then do: run jhtagert("Осуществление платежей в пользу резидентов", "Прочее").   end.
     if tmp-f2p2.kod = 212421 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Покупка товаров и нематериальных активов").     end.
     if tmp-f2p2.kod = 212422 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Получение услуг").  end.
     if tmp-f2p2.kod = 212423 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Выдача займов").   end.
     if tmp-f2p2.kod = 212424 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Выполнение обязательств по займам").     end.
     if tmp-f2p2.kod = 212425 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Расчеты по операциям с ценными бумагами").     end.
     if tmp-f2p2.kod = 212426 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Заработная плата").     end.
     if tmp-f2p2.kod = 212427 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Выплата командировочных и представительских расходов").     end.
     if tmp-f2p2.kod = 212428 then do: run jhtagert("Осуществление платежей в пользу нерезидентов", "Прочее").   end.


if tmp-f2p2.kod = 212428 then do:
              for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
                  if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                      find last b1 where b1.aaa = tclientaccno no-lock no-error.
                      find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and  avail b1 then do:
                      find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                         find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
 find last tmp-d where tmp-d.djh = txb.jl.jh no-lock no-error.
 if not avail tmp-d then do:
                         if avail txb.cif and avail txb.jl then do:
                            if substr(txb.cif.geo,3,1) = "1" then do: /*резидент*/
                               tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 0).
                            end.
                            if substr(txb.cif.geo,3,1) = "2" then do: /*резидент*/
                               tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                            end.
                         end.
 end.
end.
                  end.
              end.


/*
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   find last trgt  where trgt.jh = txb.dealing_doc.jh no-lock no-error.
                   if avail trgt and avail txb.cif and avail txb.jl then do:

                      if (lookup(trgt.rem1,"Осуществление платежей в пользу нерезидентов,Осуществление платежей в пользу резидентов") = 0) or (lookup(trgt.rem2,"Покупка товаров и нематериальных активов,Получение услуг,Выдача займов,Выполнение обязательств по займам,Расчеты по операциям с ценными бумагами,Заработная плата,Выплата командировочных и представительских расходов,Прочее" ) = 0) then 
                      do:
                         if substr(txb.cif.geo,3,1) = "1" then  
                            tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 0).
                         else
                            tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                      end.
                   end.
                   else do:
                        if not avail trgt and avail cif and avail txb.jl then do:
                           if substr(txb.cif.geo,3,1) = "1" then 
                              tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 0).
                           else
                              tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                        end.
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez. 
*/

end.













/* Продажа валюты */
     if tmp-f2p2.kod = 221000 then do:
        for each txb.dealing_doc where txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock:
            if (txb.dealing_doc.doctype = 3 or txb.dealing_doc.doctype = 4) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "P" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 2 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  /*резидент*/
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 0).
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez.
     end.

     if tmp-f2p2.kod = 222000 then do:
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock:
            if (txb.dealing_doc.doctype = 3 or txb.dealing_doc.doctype = 4) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 2 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if substr(txb.cif.geo,3,1) = "1" then  /*резидент*/
                         tmp-f2p2.tgrez = tmp-f2p2.tgrez +  round(txb.jl.cam / 1000, 0).
                      else
                         tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez.
     end.

     if tmp-f2p2.kod = 222400 then do:
        find last b-f2p2 where b-f2p2.kod = 222000 no-lock.
        tmp-f2p2.summ     = b-f2p2.summ. 
        tmp-f2p2.tgrez    = b-f2p2.tgrez. 
        tmp-f2p2.tgnorez  = b-f2p2.tgnorez. 
        tmp-f2p2.valrez   = b-f2p2.valrez. 
        tmp-f2p2.valnorez = b-f2p2.valnorez. 
     end.
 end. 










procedure jhtagert.
       def input parameter r1 as char.
       def input parameter r2 as char.

        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
                find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   find last trgt  where trgt.jh = txb.dealing_doc.jh no-lock no-error.
                   if avail trgt and avail txb.cif and avail txb.jl then do:
                      if trgt.rem1 = r1 and trgt.rem2 = r2 then 
                      do:
                         if substr(txb.cif.geo,3,1) = "1" then  /*резидент*/ do:
                            tmp-f2p2.tgrez = tmp-f2p2.tgrez + round(txb.jl.cam / 1000, 0).
create tmp-d.
       tmp-d.djh = txb.jl.jh.
                         end.
                         else do:
                            tmp-f2p2.tgnorez = tmp-f2p2.tgnorez + round(txb.jl.cam / 1000, 0).
create tmp-d.
       tmp-d.djh = txb.jl.jh.
                         end.
                      end.
                   end.
end.
            end.
        end.
        tmp-f2p2.summ = tmp-f2p2.tgrez + tmp-f2p2.tgnorez + tmp-f2p2.valrez + tmp-f2p2.valnorez. 
end.


