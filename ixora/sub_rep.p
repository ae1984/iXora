/* sub_rep.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        3-outg  
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 dpuchkov
 * CHANGES
        09.09.2004 dpuchkov - сделал отчет консолидированным. 
        10.09.2004 dpuchkov - перекомпиляция
*/

{global.i}
{get-dep.i}
{deparp.i}
define input parameter fil_name as char.
define input parameter v-datetoday as date.
define input parameter v-numfilial as integer.

def var out as char.
def var file1 as char format "x(20)".
def var file2 as char format "x(20)".

def var acctype as logical.
def var v-arp_acc  as integer.
def var v-num as integer.
def var l-value as logical.
def var i-days as integer.
def var s-almatv as char.
def var ourbank as char.
def var ourcode as integer.
def var d_accnt as integer.

def var p_f_sum as decimal.
def var tax_sum as decimal.

def var d-datelst as date.
/* def var d_date as date. */

def var sumfk    as decimal.
def var sumfk1   as decimal.
def var l-index1 as logical.

def var v-bal as dec format "zz,zzz,zzz,zzz.99-".
        
 v-arp_acc = 287052.
 v-num = 1.
 i-days = 7.
 file1 = "file1.htm". 
 file2 = "file2.htm".

/*
for each p_f_payment where txb = v-numfilial and date = v-dat and p_f_payment.deluid = ? and
                           (p_f_payment.cod = 100 or p_f_payment.cod = 200 or p_f_payment.cod = 300)
                           no-lock:

       get-dep(p_f_payment.uid, v-dat).
           find first depaccnt where depaccnt.depart = d_accnt no-lock no-error.
           if avail depaccnt and depaccnt.accnt = txb.arp.arp then 
           do:
           74 - пен
           end.
end.

    for each jl no-lock where jl.gl eq arp.gl and jl.acc eq arp.arp
        and jl.jdt gt v-asof by jl.jdt:

        if gl.type eq "A" or gl.type eq "E" then
            v-bal = v-bal - jl.dam + jl.cam.
        else
            v-bal = v-bal + jl.dam - jl.cam.
        end.


    if gl.type eq "A"
        then v-bal = arp.dam[1] - arp.cam[1].
    else
        v-bal = arp.cam[1] - arp.dam[1].
*/

  output to value(file1).
  {html-title.i}
    put unformatted
         "<P align=""center"" style=""font:bold;font-size:small""><b>" fil_name "</b> </P>" skip.
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Отчет расшифровки остатков по транзитным субсчетам (Г/К "string(v-arp_acc) ") на " + string(v-datetoday) +  "</P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        "<TD>Содержание</TD>" skip
        "<TD>Сумма</TD>" skip
        "</TR>" skip.


     for each txb.arp where txb.arp.gl = v-arp_acc /*and txb.arp.dam[1] - txb.arp.cam[1] <> 0 */ no-lock :
        find gl where gl.gl eq arp.gl no-lock no-error.
        sumfk  = 0.
        sumfk1 = 0.
        v-bal  = 0.

        if gl.type eq "A"
            then v-bal = arp.dam[1] - arp.cam[1].
        else
            v-bal = arp.cam[1] - arp.dam[1].

        for each jl no-lock where jl.gl eq arp.gl and jl.acc eq arp.arp and jl.jdt gt v-datetoday by jl.jdt:
           if gl.type eq "A" or gl.type eq "E" then
              v-bal = v-bal - jl.dam + jl.cam.
           else
              v-bal = v-bal + jl.dam - jl.cam.
        end.



   if v-bal = 0 then next.
   sumfk1 = 0. 
       for each p_f_payment where txb = v-numfilial and date = v-datetoday and p_f_payment.deluid = ?  and
                                (p_f_payment.cod = 100 or p_f_payment.cod = 200 or p_f_payment.cod = 300)  no-lock:

                 if txb.arp.arp = deparp(get-dep(p_f_payment.uid, p_f_payment.date)) then
                 do:
                    sumfk1 = p_f_payment.amt + sumfk1.
                 end.
       end.

   if  sumfk1 <> 0 then
   do:
        put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
        put unformatted
                        "<td><b>" txb.arp.arp "</b></td>" skip
                        "<td><b>" v-bal "</b></td>" skip.
       put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
       put unformatted
                       "<td> Налоговые платежи </td>"                         skip
                       "<td>" v-bal - sumfk1 "</td>"                          skip.

       if sumfk1 <> 0 then do:
         put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
         put unformatted 
                             "<td> Пенсионные платежи </td>"                        skip
                             "<td>" sumfk1 "</td>"        skip.
       end.
   end.
   else
   do:
       put unformatted "<tr valign=top style=""background:"  "white " """>"         skip.
       put unformatted "<td><b>" txb.arp.arp "</b></td>"                            skip
                       "<td><b>" v-bal format "->>,>>>,>>>,>>>,>>9.99"  "</b></td>" skip.

       put unformatted "<tr valign=top style=""background:"  "white " """>"         skip.
       put unformatted "<td>" arp.des "</td>"                                       skip
                       "<td>" v-bal format "->>,>>>,>>>,>>>,>>9.99" "</td>"         skip.
   end.


end.

  put unformatted "</TABLE>" skip.
  {html-end.i " "}
  output close .
  unix silent cptwin value(file1) iexplore.






/*









   for each txb.arp where txb.arp.gl = v-arp_acc and txb.arp.dam[1] - txb.arp.cam[1] <> 0  no-lock :
       sumfk  = 0.
       sumfk1 = 0.
       for each tax  where  tax.taxdoc <> ? and tax.senddoc =  ?  and tax.txb = v-numfilial 
                             and tax.duid = ? and  tax.date  =  v-datetoday  and tax.comdoc = ?  no-lock:

           d_accnt = integer (get-dep (tax.uid, tax.date)).
           find first depaccnt where depaccnt.depart = d_accnt no-lock no-error.
           if avail depaccnt and depaccnt.accnt = txb.arp.arp then 
           do:
               sumfk = tax.sum  + tax.comsum + sumfk.

           end.
       end.

       for each p_f_payment where p_f_payment.stcif > 0 and p_f_payment.txb = v-numfilial and  p_f_payment.date = v-datetoday  
                and p_f_payment.stgl = 0 and p_f_payment.deluid = ?  no-lock :

                d_accnt = int (get-dep (p_f_payment.uid, p_f_payment.date)).
                find first depaccnt where depaccnt.depart = d_accnt no-lock no-error.
                if avail depaccnt and depaccnt.accnt = txb.arp.arp then 
                do:
                    sumfk1 = p_f_payment.amt + p_f_payment.comiss + sumfk1.
                end.
       end.

       if sumfk <> 0 or sumfk1 <> 0 then
       do:
             put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
             put unformatted
                             "<td><b>" txb.arp.arp "</b></td>" skip
                             "<td><b>" sumfk + sumfk1  "</b></td>" skip.


             put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
             put unformatted
                             "<td> Налоговые платежи </td>"                         skip
                             "<td>" sumfk   "</td>"         skip. 


             put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
             put unformatted 
                             "<td> Пенсионные платежи </td>"                        skip
                             "<td>" sumfk1   "</td>"        skip.
       end.
   end.


  put unformatted "</TABLE>" skip.
  {html-end.i " "}
  output close .
  unix silent cptwin value(file1) iexplore.

*/


   
