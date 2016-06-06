/* eknptxb2.p
 * MODULE
        СТАТИСТИКА
 * DESCRIPTION
        Отчет о покупке/продаже иностранной валюты банком и его клиентами Раздел 1.
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
        12.06.2006 dpuchkov - перекомпиляция
        07.09.2006 dpuchkov - доработка и оптимизация.
*/


 def shared var vn-dt as date    no-undo.
 def shared var vn-dtbeg as date no-undo.


 def buffer b1 for txb.aaa.
 def buffer b2 for txb.aaa.

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



 def shared temp-table tmp-f2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field usd  as decimal decimals 2
     field eur  as decimal decimals 2
     field rur  as decimal decimals 2.

  for each tmp-f2 break by nom:

      if tmp-f2.kod = 110000 then do:
         for each txb.jl where substring(txb.jl.rem[1],1,5) = "Обмен" and txb.jl.crc <> 1 and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt no-lock:
             find last txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
             find last txb.joudoc where txb.joudoc.docnum = trim(txb.jh.party) no-lock no-error.
             if avail txb.joudoc then do:
                if txb.joudoc.drcur <> 1 then do:
                   if txb.joudoc.drcur = 2  then tmp-f2.usd = tmp-f2.usd + round((txb.joudoc.dramt) / 1000, 0). else
                   if txb.joudoc.drcur = 3  then tmp-f2.eur = tmp-f2.eur + round((txb.joudoc.dramt) / 1000, 0). else
                   if txb.joudoc.drcur = 4  then tmp-f2.rur = tmp-f2.rur + round((txb.joudoc.dramt) / 1000, 0).
                      tmp-f2.summ = tmp-f2.summ + round(crc-crc-date(txb.joudoc.dramt, txb.joudoc.drcur, 1, txb.jl.jdt) / 1000, 0).
                end.
             end.
         end.
      end.

      if tmp-f2.kod = 120000 then do:
         for each txb.jl where substring(txb.jl.rem[1],1,5) = "Обмен" and txb.jl.crc <> 1 and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt no-lock:
             find last txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
             find last txb.joudoc where txb.joudoc.docnum = trim(txb.jh.party) no-lock no-error.
             if avail txb.joudoc then do:
                if txb.joudoc.crcur <> 1 then do:
                   if txb.joudoc.drcur = 2  then tmp-f2.usd = tmp-f2.usd + round((txb.joudoc.cramt) / 1000, 0). else
                   if txb.joudoc.drcur = 3  then tmp-f2.eur = tmp-f2.eur + round((txb.joudoc.cramt) / 1000, 0). else
                   if txb.joudoc.drcur = 4  then tmp-f2.rur = tmp-f2.rur + round((txb.joudoc.cramt) / 1000, 0).
                      tmp-f2.summ = tmp-f2.summ + round(crc-crc-date(txb.joudoc.cramt, txb.joudoc.crcur, 1, txb.jl.jdt) / 1000, 0).
                end.
             end.
         end.
      end.


      if tmp-f2.kod = 110002 then do:
         for each txb.jl where txb.jl.acc = "000076371" and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt no-lock use-index acc by txb.jl.jh:
             if txb.jl.dam = 0 then do:
                tmp-f2.usd = tmp-f2.usd + round(txb.jl.cam / 1000, 0).
                tmp-f2.summ = tmp-f2.summ + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0).
             end.
         end.
      end.


      if tmp-f2.kod = 110001 then do:
 for each txb.dealing_doc where txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock:
     if (txb.dealing_doc.doctype = 3 or txb.dealing_doc.doctype = 4) then do:



         find last b1 where b1.aaa = tclientaccno no-lock no-error.


         find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 and avail b1 then do:
         find last txb.cif where txb.cif.cif = b1.cif and (txb.cif.type = "P" or txb.cif.type = "B" ) no-lock no-error.
            find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 2 and txb.jl.dam = 0 no-lock no-error.
            if avail txb.cif and avail txb.jl then do:
                    if b2.crc = 2  then tmp-f2.usd = tmp-f2.usd + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). else
                    if b2.crc = 3  then tmp-f2.eur = tmp-f2.eur + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). else
                    if b2.crc = 4  then tmp-f2.rur = tmp-f2.rur + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). 
                    tmp-f2.summ = tmp-f2.summ + round(txb.jl.cam / 1000, 0).

            end.
end.



     end.
 end.
      end.


      if tmp-f2.kod = 120001 then do:
        for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
            if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                find last b1 where b1.aaa = tclientaccno no-lock no-error.
                find last b2 where b2.aaa = vclientaccno no-lock no-error.
                if avail b2 and avail b1 then do:
                   find last txb.cif where txb.cif.cif = b1.cif and (txb.cif.type = "P" or txb.cif.type = "B") no-lock no-error.
                   find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                   if avail txb.cif and avail txb.jl then do:
                      if b2.crc = 2  then tmp-f2.usd = tmp-f2.usd + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). else
                      if b2.crc = 3  then tmp-f2.eur = tmp-f2.eur + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). else
                      if b2.crc = 4  then tmp-f2.rur = tmp-f2.rur + round((txb.jl.cam / txb.dealing_doc.rate) / 1000, 0). 
                      tmp-f2.summ = tmp-f2.summ + round(txb.jl.cam / 1000, 0).
                   end.
                end.
            end.
        end.


      end.
  end.



