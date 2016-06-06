/* mob2arp.p
 * MODULE
        Коммунальные платежи 
 * DESCRIPTION
        Зачисление оффлайн платежей Kcell и K-Mobile
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        stadsofp.p 
 * AUTHOR
        27/10/2003 kanat
 * CHANGES
        13/11/2003 sasco Переделал поиск commonpl (добавил несколько полей),
                         переместил {mob-u*.i} в блок транзакции
        19/11/2003 sasco внедрил в bcommpl запись brid = rowid (commonpl)
                         и добавил do: end. вокруг {mob-u*.i}
        01.01.2004 nadejda - изменила ставку НДС - брать из sysc
        26.04.2004 kanat - добавил зачисление комиссиий - если они есть - вместе с зачислением основной суммы.
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/

{global.i}
{sysc.i}
{comm-txb.i}

def input parameter vdate as date.
def input parameter v-ofc as char.

def var seltxb as int.
def var ourbank as char.
ourbank = comm-txb().
seltxb  = comm-cod().

def var v-nds as decimal.
find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds = sysc.deval.

{get-dep.i}
{yes-no.i}
{padc.i}
{u-2-d.i}

def var rids as char initial "".
def new shared var s-jh like jh.jh.

def var cret as char init "".
def var temp as char init "" no-undo.
/*define frame sf with side-labels centered view-as dialog-box.*/

def var lcom  as logical init false.
def var cdate as date init today.
def var selgrp  as integer init 4.  /* Определяем номер группы в таблице commonls */
def var seltype as integer init 1.  /* type в таблице commonls */
def var docnum as integer.

def var dlm     as char.
def var l333    as logical init false.

def var cTitle as char init '' no-undo.
def var crlf as char.

def var s_sbank as char.
def var i_clrgrss as integer.

def var i_temp_dep as integer.
def var s_dep_cash as char.
def var s_account_a as char.
def var s_account_b as char.

def var v-amt as decimal.
def var v-comsum as decimal.

define variable v-jou as char.
def var rdes  as char.
def var rcode as integer.

define var cashgl like jl.gl.

def temp-table bcommpl like commonpl
               field brid as rowid.

def var v-rec-sum as decimal init 0.
def var v-tmpjh as integer.

for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 4 and commonpl.joudoc = ? 
                    and commonpl.rmzdoc = ? and commonpl.txb = seltxb and deldate = ? and deluid = ? no-lock:
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.sum.
end.

if v-rec-sum <> 0 then do:

/* касса или касса в пути для кассира */

i_temp_dep = int (get-dep (userid("bank"), g-today)).

find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:

  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

  if lookup (string(depaccnt.depart), s_dep_cash) > 0 then 
     assign s_account_a = ''
            s_account_b = '000061302'. 
  else 
     assign s_account_a = '100100'
            s_account_b = ''. 

end.

if seltxb = 1 then do:
     assign s_account_a = ''
            s_account_b = '150076778'. 
end.

if seltxb = 2 then do: 
     assign s_account_a = ''
            s_account_b = '250076676'. 
end.


for each bcommpl break by bcommpl.dnum:

find first commonls where commonls.txb = bcommpl.txb and 
                          commonls.grp = bcommpl.grp and 
                          commonls.type = bcommpl.type and 
                          commonls.visible = yes 
                          no-lock no-error.

if not avail commonls then do:
 MESSAGE "Не настроена таблица commonls" 
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile" .
 return.
end.

do transaction:

 assign v-amt = bcommpl.sum
        v-comsum = bcommpl.comsum.

 temp =  trim(commonls.npl) + " " + string(bcommpl.counter,"9999999") + ' от ' +  trim( bcommpl.fio ) + 
         '. Cумма ' + trim( string( v-amt, '>>>,>>>,>>9.99' )) + ', в т.ч. НДС ' + 
         trim( string( truncate( v-amt / (1 + v-nds) * v-nds, 2 ), '>>>,>>>,>>9.99' )) + '.'.


                    if seltxb = 0 then do: 

   s-jh = 0.
   v-tmpjh = 0.

if bcommpl.comsum <> 0 then do: 

                         run mobtrx(0, 
                                    v-amt, 
                                    1, 
                                    s_account_a, 
                                    s_account_b, 
                                    '',
                                    string(commonls.iik, "999999999"),
                                    temp,
                                    commonls.kod,commonls.kbe,"856", v-tmpjh).

                        if return-value = '' then do: undo. return. end.
                        v-tmpjh = integer(return-value).
/* Комиссия */

                run mobtrx(0, 
                           v-comsum, 
                           1, 
                           s_account_a, 
                           s_account_b, 
                           commonls.comgl, 
                           '',                            
                           "Комиссия за платежи сотовой связи",
                           commonls.kbe, '14', '840', v-tmpjh).

 
                        if return-value = '' then do: undo. return. end.
                        s-jh = int(return-value).


        run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
            end.


/*---------------------------------------------------------------------------*/   
    find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
    if avail sysc then
    do:
       cashgl = sysc.inval.

       for each jl where jl.jh = s-jh no-lock:
          if jl.sts = 6 and jl.gl = cashgl then  
          do:
              find first cashofc where cashofc.whn eq g-today and
                                       cashofc.sts eq 2 and
                                       cashofc.ofc eq g-ofc and
                                       cashofc.crc eq jl.crc
                                       exclusive-lock no-error.
              if avail cashofc then 
              do:
                  cashofc.amt = cashofc.amt + jl.dam - jl.cam.
              end.
              else do:
                   create cashofc.
                   cashofc.whn = g-today.
                   cashofc.ofc = g-ofc.
                   cashofc.crc = jl.crc.
                   cashofc.sts = 2.
                   cashofc.amt = jl.dam - jl.cam.
                   cashofc.who = g-ofc.
              end.

              release cashofc.
          end. 
      end. 
      
    end.
/*---------------------------------------------------------------------------*/   

                        run setcsymb (s-jh, commonls.symb).
                        run jou.

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and               
                                                                           commonpl.grp = 4 and                    
                                                                           commonpl.type = bcommpl.type and        
                                                                           commonpl.uid = bcommpl.uid and          
                                                                           commonpl.counter = bcommpl.counter and  
                                                                           commonpl.service = bcommpl.service and  
                                                                           commonpl.dnum = bcommpl.dnum and        
                                                                           commonpl.sum = bcommpl.sum              
                                                                           no-lock no-error.                       
                        if avail commonpl then assign commonpl.joudoc = return-value
                                                      commonpl.comdoc = string(s-jh).

/*                        assign commonpl.joudoc = return-value
                               commonpl.comdoc = string(s-jh).
*/
                        run vou_import.
end.
else
do:
                           run trx (6, 
                                    v-amt, 
                                    1, 
                                    s_account_a, 
                                    s_account_b, 
                                    '',
                                    string( commonls.iik, "999999999"),
                                    temp,
                                    commonls.kod,commonls.kbe,"856").

                        if return-value = '' then do: undo. return. end.
                        s-jh = int(return-value).
                        run setcsymb (s-jh, commonls.symb).
                        run jou.

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and               
                                                                           commonpl.grp = 4 and                    
                                                                           commonpl.type = bcommpl.type and        
                                                                           commonpl.uid = bcommpl.uid and          
                                                                           commonpl.counter = bcommpl.counter and  
                                                                           commonpl.service = bcommpl.service and  
                                                                           commonpl.dnum = bcommpl.dnum and        
                                                                           commonpl.sum = bcommpl.sum              
                                                                           no-lock no-error.                       

                        if avail commonpl then assign commonpl.joudoc = return-value
                                                      commonpl.comdoc = string(s-jh).

/*
                        assign commonpl.joudoc = return-value.
*/
                        run vou_import.
end.





                     end. /* Алматы */ 
/*-------------------------------------------------------------------------------------------------------------------*/

          /* Если филиал */
           else do:   
                        run trx (       
                        6, 
                        v-amt, 
                        1, 
                        s_account_a, 
                        s_account_b, 
                        '', 
                        commonls.arp, 
                        'Зачисление на транзитный счет ' + temp,
                        commonls.kod,commonls.kbe,'856').
            
                        if return-value = '' then undo, return.
            
                        s-jh = int(return-value).            
                        run setcsymb (s-jh, commonls.symb).
                        run jou.
                        if return-value = "" then undo, return.

                        v-jou = return-value.

                        run vou_import.

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and               
                                                                           commonpl.grp = 4 and                    
                                                                           commonpl.type = bcommpl.type and        
                                                                           commonpl.uid = bcommpl.uid and          
                                                                           commonpl.counter = bcommpl.counter and  
                                                                           commonpl.service = bcommpl.service and  
                                                                           commonpl.dnum = bcommpl.dnum and        
                                                                           commonpl.sum = bcommpl.sum              
                                                                           no-lock no-error.                       

                        if avail commonpl then do: /* available commonpl */
                           
                          assign commonpl.joudoc = v-jou.

                          s_sbank = "TXB00".
                          i_clrgrss = 5.

                          run commpl ( 
                             bcommpl.dnum,
                             v-amt,
                             commonls.arp,
                             s_sbank,
                             commonls.iik,
                             0,                     
                             no,                    
                             trim(commonls.bn),     
                             commonls.rnnbn,        
                             commonls.knp,
                             commonls.kod,
                             commonls.kbe,
                             temp,
                             trim(commonls.que),
                             0,
                             i_clrgrss,
                             "",
                               "",
                              vdate).  

                          find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                          if not available commonpl then find commonpl where commonpl.txb = seltxb and               
                                                                             commonpl.grp = 4 and                    
                                                                             commonpl.type = bcommpl.type and        
                                                                             commonpl.uid = bcommpl.uid and          
                                                                             commonpl.counter = bcommpl.counter and  
                                                                             commonpl.service = bcommpl.service and  
                                                                             commonpl.dnum = bcommpl.dnum and        
                                                                             commonpl.sum = bcommpl.sum              
                                                                             no-lock no-error.                       

                          if avail commonpl then assign commonpl.rmzdoc = return-value no-error.

                        end. /* available commonpl */

          end. /* если филиал */

find commonpl where rowid (commonpl) = bcommpl.brid no-lock no-error.
if not available commonpl then find commonpl where commonpl.txb = seltxb and               
                                                   commonpl.grp = 4 and                    
                                                   commonpl.type = bcommpl.type and        
                                                   commonpl.uid = bcommpl.uid and          
                                                   commonpl.counter = bcommpl.counter and  
                                                   commonpl.service = bcommpl.service and  
                                                   commonpl.dnum = bcommpl.dnum and        
                                                   commonpl.sum = bcommpl.sum and
                                                   commonpl.deluid = ?
                                                   no-lock no-error.                       

if available commonpl then do:

   if commonpl.service = "300" or commonpl.type = 1 then 
   do:
        message "Отправка платежа в K-Cell".
        {mob-u300.i} 
   end.

   if commonpl.service = "333" or commonpl.type = 2 then 
   do:
        message "Отправка платежа в KMobile".
        {mob-u333.i} 
   end.

end. /* available commonpl */

end. /* do transaction */

end. /* for each bcommpl */
end. /* сумма <> 0 */

