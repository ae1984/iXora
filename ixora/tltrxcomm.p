/* tltrxcomm.p
 * MODULE
        Касса
 * DESCRIPTION
        Отчет кассира по принятым коммунальным платежам - статистика
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
        09.10.2003 sasco
 * CHANGES
        15.10.2003 sasco Разбивка пенсионных и прочих платежей
        15.10.2003 sasco Разбивка налоговых по КБК и отдельно по квитанциям
        17.10.2003 sasco Переделал налоговые
        21.10.2003 sasco Добавил ФИО в шапку отчета
        23.10.2003 sasco Добавил проверку на то, чтобы логин офицера = логин удалявшего
	23.10.2003 igor  Добавил печать комиссии
	22.12.2003 kanat Добавил печать реквизитов квитанций распечатанных более 1 раза и удаленных квитанций
	20.10.2005 sasco исправил поиск коммуналок в commonls из-за социальных у которых visible = no
	08.11.2005 u00121 описал формат вывода чисел format "zzz,zzz,zz9.99-"
*/

{comm-txb.i}

define input parameter fname as char.
define input parameter dt as date.
define input parameter g-ofc as char.
define input parameter v-com as logical.

define shared variable g-comp like cmp.name.

define variable ckv as int.
define variable ldnum as int.
define variable ltime as int.
define variable tmpstr as char init ''.
 
def var seltxb as integer.
seltxb = comm-cod().

define variable t-numall as integer.
define variable t-numkvi as integer.
define variable t-numdel as integer.
define variable t-numprt as integer.

define variable t-sumall as decimal.
define variable t-sumkvi as decimal.
define variable t-sumdel as decimal.
define variable t-sumprt as decimal.

/*суммы по комиссиям*/
define variable t-comall as decimal. 
define variable t-comkvi as decimal. 
define variable t-comdel as decimal. 
define variable t-comprt as decimal. 

/*итоговые суммы с комиссией*/
define variable i-comall as decimal. 
define variable i-comkvi as decimal. 
define variable i-comdel as decimal. 
define variable i-comprt as decimal. 

define temp-table tmp
            field sub     as character 
            field name    as character 

            field numall  as integer 
            field numkvi  as integer 
            field numdel  as integer
            field numprt  as integer
            
            field sumall  as decimal format "zzz,zzz,zz9.99-"
            field sumkvi  as decimal format "zzz,zzz,zz9.99-"
            field sumdel  as decimal format "zzz,zzz,zz9.99-"
            field sumprt  as decimal format "zzz,zzz,zz9.99-"

            field comall  as decimal
            field comkvi  as decimal
            field comdel  as decimal
            field comprt  as decimal

            field sitogo  as decimal

            index idx_tmp is primary sub.

/* ---------------------------------------------------------------------------- */

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date = dt and 
                        commonpl.uid = g-ofc
                        no-lock:

   if commonpl.grp <> 15 then 
   find commonls where commonls.txb = seltxb and 
                       commonls.grp = commonpl.grp and 
                       commonls.type = commonpl.type and 
                       commonls.visible
                       no-lock no-error.
   else
   find commonls where commonls.txb = seltxb and 
                       commonls.grp = commonpl.grp and 
                       commonls.type = commonpl.type
                       no-lock no-error.

   if not avail commonls then do:
      message "Нет записи commonls для grp = " commonpl.grp " и type = " commonpl.type view-as alert-box.
      next.
   end.

   if commonpl.deluid <> ? then 
              if commonpl.deluid <> commonpl.uid then next.

   find tmp where tmp.sub = "COM" and tmp.name = commonls.bn no-error.
   if not available tmp then do:
   
      create tmp.
      tmp.sub = "COM".
      tmp.name = commonls.bn.

   end.

   ckv = ?.
   ckv = integer (commonpl.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + commonpl.sum.
   tmp.comall = tmp.comall + commonpl.comsum.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * commonpl.sum).
   tmp.comprt = tmp.comprt + (ckv * commonpl.comsum).

   if commonpl.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + commonpl.sum.
          tmp.comkvi = tmp.comkvi + commonpl.comsum.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + commonpl.sum.
          tmp.comdel = tmp.comdel + commonpl.comsum.
   end.

end.

/* ---------------------------------------------------------------------------- */

ltime = 0.
ldnum = 0.

for each tax where tax.txb = seltxb and 
                   tax.date = dt and 
                   tax.uid = g-ofc
                   no-lock by tax.dnum by tax.created:

   if tax.duid <> ? then 
          if tax.duid <> tax.uid then next.

   find tmp where tmp.sub = "TAX" no-error.
   if not available tmp then do:
   
      create tmp.
      tmp.sub = "TAX".
      tmp.name = "Налоговые платежи".

   end.

   ckv = ?.
   ckv = integer (tax.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   /* итого платежей */
   tmp.sumall = tmp.sumall + tax.sum.
   tmp.comall = tmp.comall + tax.comsum.

   /* распечатано */
   tmp.sumprt = tmp.sumprt + (ckv * tax.sum).
   tmp.comprt = tmp.comprt + (ckv * tax.comsum).
   
   if tax.duid = ? then do:
      tmp.sumkvi = tmp.sumkvi + tax.sum.
      tmp.comkvi = tmp.comkvi + tax.comsum.
   end.
   else do:
   	tmp.sumdel = tmp.sumdel + tax.sum.
   	tmp.comdel = tmp.comdel + tax.comsum.
   end.

   if tax.dnum <> ldnum or tax.created <> ltime
   then do:
        assign ldnum = tax.dnum
               ltime = tax.created.

        assign tmp.numall = tmp.numall + 1
               tmp.numprt = tmp.numprt + ckv.

        if tax.duid = ? then tmp.numkvi = tmp.numkvi + 1.
                        else tmp.numdel = tmp.numdel + 1.
   end.

end.


/* ---------------------------------------------------------------------------- */

for each almatv where almatv.txb = seltxb and 
                      almatv.dtfk = dt and 
                      almatv.uid = g-ofc
                      no-lock:

   if almatv.deluid <> ? then 
          if almatv.deluid <> almatv.uid then next.

   find tmp where tmp.sub = "ATV" no-error.
   if not available tmp then do:
   
      create tmp.
      tmp.sub = "ATV".
      tmp.name = "Платежи AlmaTV".

   end.

   ckv = ?.
   ckv = integer (almatv.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + almatv.summfk.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * almatv.summfk).

   if almatv.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + almatv.summfk.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + almatv.summfk.
   end.
   /* Комиссия не берется */
end.


/* ---------------------------------------------------------------------------- */

for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date = dt and 
                           p_f_payment.uid = g-ofc and
                           p_f_payment.cod <> 400
                           no-lock:

   if p_f_payment.deluid <> ? then 
          if p_f_payment.deluid <> p_f_payment.uid then next.

   find tmp where tmp.sub = "PEN" no-error.
   if not available tmp then do:
   
      create tmp.
      tmp.sub = "PEN".
      tmp.name = "Пенсионные платежи".

   end.

   ckv = ?.
   ckv = integer (p_f_payment.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + p_f_payment.amt.
   tmp.comall = tmp.comall + p_f_payment.comiss.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * p_f_payment.amt).
   tmp.comprt = tmp.comprt + (ckv * p_f_payment.comiss).

   if p_f_payment.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + p_f_payment.amt.
          tmp.comkvi = tmp.comkvi + p_f_payment.comiss.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + p_f_payment.amt.
          tmp.comdel = tmp.comdel + p_f_payment.comiss.
   end.

end.


/* ---------------------------------------------------------------------------- */

for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date = dt and 
                           p_f_payment.uid = g-ofc  and
                           p_f_payment.cod = 400
                           no-lock:

   if p_f_payment.deluid <> ? then 
          if p_f_payment.deluid <> p_f_payment.uid then next.

   find tmp where tmp.sub = "PENPR" no-error.
   if not available tmp then do:
   
      create tmp.
      tmp.sub = "PENPR".
      tmp.name = "Прочие платежи".

   end.

   ckv = ?.
   ckv = integer (p_f_payment.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + p_f_payment.amt.
   tmp.comall = tmp.comall + p_f_payment.comiss.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * p_f_payment.amt).

   if p_f_payment.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + p_f_payment.amt.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + p_f_payment.amt.
   end.

end.


/* ---------------------------------------------------------------------------- */

output to value (fname) append.

find first tmp no-error.
if not available tmp then do:
   output close.
   return.
end.

put unformatted chr(15).

find ofc where ofc.ofc = g-ofc no-lock no-error.

display g-comp format "x(70)" skip
        "Исполнитель " ofc.name "  (" g-ofc ")  Дата   " dt skip
        "Дата печати  " today string(time,"HH:MM:SS") skip
        "Отчет по коммунальным и прочим платежам" format "x(45)" skip(2)
        with width 132 frame tltrxh1 no-hide no-box no-label no-underline.


put unformatted if v-com then fill("=",71) else fill("=",36) skip.
put unformatted "   Операция  Кол-во            Сумма " if v-com then "        Комиссия             Итого" else "" skip. 
put unformatted if v-com then fill("=",71) else fill("=",36) skip.

for each tmp break by tmp.sub by tmp.name:

    t-numall = t-numall + tmp.numall.
    t-numkvi = t-numkvi + tmp.numkvi.
    t-numdel = t-numdel + tmp.numdel.
    t-numprt = t-numprt + tmp.numprt.

    t-sumall = t-sumall + tmp.sumall.
    t-sumkvi = t-sumkvi + tmp.sumkvi.
    t-sumdel = t-sumdel + tmp.sumdel.
    t-sumprt = t-sumprt + tmp.sumprt.

    t-comall = t-comall + tmp.comall.
    t-comkvi = t-comkvi + tmp.comkvi.
    t-comdel = t-comdel + tmp.comdel.
    t-comprt = t-comprt + tmp.comprt.

    i-comall = tmp.sumall + tmp.comall.
    i-comkvi = tmp.sumkvi + tmp.comkvi.
    i-comdel = tmp.sumdel + tmp.comdel.
    i-comprt = tmp.sumprt + tmp.comprt.

    if first-of (tmp.sub) then do:
       case tmp.sub:
            when "COM"   then put unformatted "Коммунальные платежи" skip if v-com then fill("-",71) else fill("-",36) skip(1).
            when "TAX"   then put unformatted "Налоговые платежи" skip    if v-com then fill("-",71) else fill("-",36) skip(1).
            when "PEN"   then put unformatted "Пенсионные платежи" skip   if v-com then fill("-",71) else fill("-",36) skip(1).
            when "PENPR" then put unformatted "Прочие платежи" skip       if v-com then fill("-",71) else fill("-",36) skip(1).
            when "ATV"   then put unformatted "Платежи Alma TV" skip      if v-com then fill("-",71) else fill("-",36) skip(1).
       end case.
    end.

    if first-of (tmp.name) then do: 
       put unformatted CAPS (tmp.name) SKIP (1).
    end.

    if v-com then tmpstr = string(tmp.comkvi, 'zz,zzz,zzz,zz9.99') + " " + string(tmp.sumkvi + tmp.comkvi,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
    put unformatted "    Принято: " tmp.numkvi format "zzzzz9" tmp.sumkvi format 'zz,zzz,zzz,zz9.99' tmpstr skip.

    if v-com then tmpstr = string(tmp.comdel,'zz,zzz,zzz,zz9.99') + " " + string(tmp.sumdel + tmp.comdel,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
    put unformatted "    Удалено: " tmp.numdel format "zzzzz9" tmp.sumdel format 'zz,zzz,zzz,zz9.99' tmpstr skip.

    if v-com then tmpstr = string(tmp.comall,'zz,zzz,zzz,zz9.99') + " " + string(tmp.sumall + tmp.comall,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
    put unformatted "      ИТОГО: " tmp.numall format "zzzzz9" tmp.sumall format "zz,zzz,zzz,zz9.99" tmpstr skip.

    if v-com then tmpstr = string(tmp.comprt,'zz,zzz,zzz,zz9.99') + " " + string(tmp.sumprt + tmp.comprt,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
    put unformatted "Распечатано: " tmp.numprt format "zzzzz9" tmp.sumprt format "zz,zzz,zzz,zz9.99" tmpstr skip.

    put unformatted skip(1).

end.

put unformatted if v-com then fill("=",71) else fill("=",36) skip.
put unformatted "ИТОГО ПО ВСЕМ ВИДАМ ПЛАТЕЖЕЙ: " skip(1).

put unformatted if v-com then fill("=",71) else fill("=",36) skip.
put unformatted "   Операция  Кол-во            Сумма " if v-com then "        Комиссия             Итого" else "" skip. 

if v-com then tmpstr = string(t-comkvi,'zz,zzz,zzz,zz9.99') + " " + string(t-sumkvi + t-comkvi,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
put unformatted "    Принято: " t-numkvi format "zzzzz9" t-sumkvi format "zz,zzz,zzz,zz9.99" tmpstr skip.

if v-com then tmpstr = string(t-comdel,'zz,zzz,zzz,zz9.99') + " " + string(t-sumdel + t-comdel,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
put unformatted "    Удалено: " t-numdel format "zzzzz9" t-sumdel format 'zz,zzz,zzz,zz9.99' tmpstr skip.

if v-com then tmpstr = string(t-comall,'zz,zzz,zzz,zz9.99') + " " + string(t-sumall + t-comall,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
put unformatted "      ИТОГО: " t-numall format "zzzzz9" t-sumall format 'zz,zzz,zzz,zz9.99' tmpstr skip.

if v-com then tmpstr = string(t-comprt,'zz,zzz,zzz,zz9.99') + " " + string(t-sumprt + t-comprt,'zz,zzz,zzz,zz9.99'). else tmpstr="". 
put unformatted "Распечатано: " t-numprt format "zzzzz9" t-sumprt format 'zz,zzz,zzz,zz9.99' tmpstr skip.
/* if t-numprt < t-numall then put unformatted "   Нет квитанций: " (t-numall - t-numprt) format "zzzzz9" "   на сумму " (t-sumall - t-sumprt) format 'zz,zzz,zzz,zz9.99' skip. */

put unformatted skip (1).
put unformatted if v-com then fill("=",71) else fill("=",36) skip(1).



/* удаленные и распечатанные квитанции */

put unformatted "" skip(2).
put unformatted "Лишние распечатанные квитанции:" skip.
put unformatted fill("=",71) skip(2).
put unformatted "КОММУНАЛЬНЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date = dt and 
                        commonpl.uid = g-ofc and 
                        commonpl.deluid = ? and 
                        integer(commonpl.chval[5]) > 1 no-lock:
put unformatted commonpl.dnum "     " commonpl.sum format ">>>,>>>,>>>,>>9.99" "   " commonpl.date skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "НАЛОГОВЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each tax where tax.txb = seltxb and 
                   tax.date = dt and 
                   tax.uid = g-ofc and 
                   tax.duid = ? and 
                   integer(tax.chval[5]) > 1 no-lock:
put unformatted tax.dnum "     " tax.sum format ">>>,>>>,>>>,>>9.99" "   " tax.date skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "ПЕНСИОННЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date = dt and 
                           p_f_payment.uid = g-ofc and 
                           p_f_payment.deluid = ? and 
                           integer(p_f_payment.chval[5]) > 1 no-lock:
put unformatted p_f_payment.dnum "     " p_f_payment.amt format ">>>,>>>,>>>,>>9.99" "   " p_f_payment.date skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "АЛМА TV" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each almatv where almatv.txb = seltxb and 
                      almatv.dtfk = dt and 
                      almatv.uid = g-ofc and 
                      almatv.deluid = ? and 
                      integer(almatv.chval[5]) > 1 no-lock:
put unformatted almatv.ndoc   "     " almatv.summfk format ">>>,>>>,>>>,>>9.99" "   " almatv.dtfk skip.
end.
put unformatted fill("=",71) skip(2).


put unformatted "Удаленные квитанции:" skip.
put unformatted fill("=",71) skip(2).
put unformatted "КОММУНАЛЬНЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date = dt and 
                        commonpl.uid = g-ofc and 
                        commonpl.deluid <> ? no-lock:
put unformatted commonpl.dnum "     " commonpl.sum format ">>>,>>>,>>>,>>9.99" "   " commonpl.deldate "   " commonpl.deluid " " commonpl.delwhy skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "НАЛОГОВЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each tax where tax.txb = seltxb and 
                   tax.date = dt and 
                   tax.uid = g-ofc and 
                   tax.duid <> ? no-lock:
put unformatted tax.dnum "     " tax.sum format ">>>,>>>,>>>,>>9.99" "   " tax.deldate "   " tax.duid " " tax.delwhy skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "ПЕНСИОННЫЕ ПЛАТЕЖИ" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date = dt and 
                           p_f_payment.uid = g-ofc and 
                           p_f_payment.deluid <> ? no-lock:
put unformatted p_f_payment.dnum "     " p_f_payment.amt format ">>>,>>>,>>>,>>9.99" "   " p_f_payment.deldate "   " p_f_payment.deluid " " p_f_payment.delwhy skip.
end.

put unformatted fill("=",71) skip(2).
put unformatted "АЛМА TV" skip.
put unformatted "Номер квитанции      Сумма    Дата      Кассир" skip.
put unformatted fill("-",71) skip.
for each almatv where almatv.txb = seltxb and 
                      almatv.dtfk = dt and 
                      almatv.uid = g-ofc and 
                      almatv.deluid <> ? no-lock:
put unformatted almatv.ndoc "     " almatv.summfk format ">>>,>>>,>>>,>>9.99" "   " almatv.deldate "   " almatv.deluid " " almatv.delwhy skip.
end.
put unformatted fill("=",71) skip(2).

output close.
