/* ibfl_Trx_AccToAcc.p
 * MODULE
        ИБФЛ конвертация Счет -> Счет
 * DESCRIPTION
        Формирование проводок AccToAcc
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
        13/05/2013 k.gitalov
 * BASES
        COMM TXB
 * CHANGES
*/

{xmlParser.i}

define input parameter  Doc AS CLASS ConvDocClassTxb.
define output parameter s-jh as integer.
define output parameter p-err as character no-undo.


define variable amt-tmp as decimal init 0.
def var vbal as deci.
def var vavl as deci.
def var vhbal as deci.
def var vfbal as deci.
def var vcrline as deci.
def var vcrlused as deci.
def var vooo as char.
define variable i_crc_acc_from as int init 0.      /*валюта счета снятия*/
define variable p-acc_from as character.


if Doc:DocType = 1 or Doc:DocType = 6 then
do:
    /* Покупка валюты  и кросс-конвертация*/  
    /* Если счет снятия средств совпадает со счетом снятия комиссии */
    p-acc_from = Doc:tclientaccno. 
    i_crc_acc_from = Doc:CRCC:get-crc(Doc:tclientaccno).      
end.
else do: 
    /* Продажа валюты */  
    /* Если счет снятия средств совпадает со счетом снятия комиссии */
    p-acc_from = Doc:vclientaccno.
    i_crc_acc_from = Doc:CRCC:get-crc(Doc:vclientaccno).
end.
/***********************************************************************************************************************/

run do_exprtrans.

/***********************************************************************************************************************/

procedure do_exprtrans:
  /* При срочной покупке-продаже и кросс конвертации */
  def  var rcode  as int.
  def  var rdes   as char.
  def  var dlm    as char init "^".
  def  var vparam as char.
  define variable note as character.
  define variable  diff_tamount   as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Курсовая разница*/
  define variable  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".         /* Сумма в тенге по курсу нац банка начальная*/
  define variable  avg_tamount2   as decimal  format "zzz,zzz,zzz,zzz.99".         /* Сумма в тенге по курсу нац банка конечная*/
  define variable  trxcode as char.
  define buffer b-dealing_doc for txb.dealing_doc.
  
  if VALID-OBJECT(Doc) then
  do:
       vparam = "".
       s-jh = 0.
       rcode = 0.
       rdes = "".
       note = "".
       def var diff_summ as decimal format "zzz,zzz,zzz,zzz.99". /* Сумма в тенге с учетом курсовой разницы (Для снятия с АРП счета)*/
       do transaction:
        find b-dealing_doc where b-dealing_doc.docno = Doc:DocNo exclusive-lock no-error.
         if b-dealing_doc.jh = ? or b-dealing_doc.jh = 0 then
         do:
           find current b-dealing_doc no-lock no-error.
         end.
         else do:
           find current b-dealing_doc no-lock no-error.
           p-err =  "Транзакция уже сделана!  jh = "  + string(b-dealing_doc.jh).
           message p-err.
           return.
         end.
       end. /*do transaction:*/
       
      /* do transaction:*/

       /**********************************************************************************************************/

       amt-tmp = 0.
       /**********************************************************************************************************/
       if Doc:DocType = 1 then do: /* Срочная покупка */
          /* Определение курсовой разницы */
         avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc). /*Сумма в тенге по курсу нацбанка*/
         diff_tamount = avg_tamount - Doc:t_amount. /* Курсовая разница */   /*Doc:CRCC:DifCourse(Doc:t_amount ,Doc:v_amount, Doc:crc).*/

         /***********************/
         if diff_tamount > 0 then
         do:  /* Списание расходов 553010*/
            run txb_trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "285900" ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               p-err =  "Ошибка проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
               message p-err.
               return.
            end.
         end.
         
         /***********************/
                         vparam = string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                                 "cif" + dlm +
                                      Doc:tclientaccno + dlm +
                                      Doc:ACC:arpacc() + dlm +
                     "Конвертация собственных средств" + dlm +
                                                 "213" + dlm +
                                  string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                                                 "cif" + dlm +
                                      Doc:vclientaccno + dlm +
                         "Зачисление на валютный счет" + dlm +
                                  string(/*avg_tamount */ Doc:t_amount) + dlm +
                                  string(Doc:v_amount).
                                  note = "Срочная покупка валюты".
            amt-tmp = Doc:t_amount.
            /* knp 213*/                  
            /*trxcode = "dil0066".*/
            trxcode = "dil0073".
       end.
       /**********************************************************************************************************/

       if Doc:DocType = 3 then do: /* Срочная продажа */
         /* Определение курсовой разницы */
         avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc). /*Сумма в тенге по курсу нацбанка*/
         diff_tamount = avg_tamount - Doc:t_amount. /* Курсовая разница */   /*Doc:CRCC:DifCourse(Doc:t_amount ,Doc:v_amount, Doc:crc).*/

         /***********************/
         if diff_tamount < 0 then
         do:  /* Списание расходов 553010*/
            run txb_trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               p-err =  "Ошибка проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
               message p-err.
               return.
            end.
         end.
         /***********************/

                         vparam = string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                                                 "cif" + dlm +
                                      Doc:vclientaccno + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                     "Конвертация собственных средств" + dlm +
                                                 "223" + dlm +
                                  string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                      Doc:ACC:arpacc() + dlm +
                                                 "cif" + dlm +
                                      Doc:tclientaccno + dlm +
                   "Зачисление тенге на счет клиента " + dlm +
                                  string(Doc:v_amount) + dlm +
                                  string(/*avg_tamount*/ Doc:t_amount).
                                  note = "Срочная продажа валюты".
          amt-tmp = Doc:v_amount.   
          /* knp 223*/                      
          /*trxcode = "dil0070".*/ /* было trxcode = "dil0066".*/
          trxcode = "dil0073".
       end.
       /**********************************************************************************************************/
       if Doc:DocType = 6 then do: /* Кросс конвертация */
          /* Определение курсовой разницы */

          avg_tamount  = Doc:CRCC:NB-sale-rate(Doc:t_amount, Doc:CRCC:get-crc(Doc:tclientaccno)).
          avg_tamount2 = Doc:CRCC:NB-sale-rate(Doc:v_amount, Doc:crc).
          diff_tamount = avg_tamount - avg_tamount2.


         /***********************/
         if diff_tamount < 0 then
         do:  /* Списание расходов 553010*/
            if Doc:input_crc = i_crc_acc_from then run txb_trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
            else run txb_trxgen('dil0045', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
               p-err =  "Ошибка проводки dil0045 rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
               message p-err.
               return.
            end.
         end.

         /***********************/
         /* ввод суммы на конвертацию 'начальная', значит берем учетный курс первой валюты sb = 1 */

        if Doc:input_crc = i_crc_acc_from then  vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                      Doc:tclientaccno + dlm + /*счет клиента начальный*/
                     "Конвертация собственных средств" + dlm + /**/
                                 string( avg_tamount ) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                string( avg_tamount /*avg_tamount2*/ ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                      Doc:vclientaccno + dlm + /*счет клиента конечный*/
                         "Зачисление на валютный счет".        /**/
         
         /* ввод суммы на конвертацию 'конечная', значит берем учетный курс второй валюты sb = 2 */

         else   vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                      Doc:tclientaccno + dlm + /*счет клиента начальный*/
                     "Конвертация собственных средств" + dlm + /**/
                                 string( avg_tamount2) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                 string(avg_tamount2 ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                      Doc:vclientaccno + dlm + /*счет клиента конечный*/
                         "Зачисление на валютный счет".        /**/
          amt-tmp = Doc:t_amount.
          note = "Кросс конвертация".  /**/
          trxcode = "dil0069".
       end.
       /**********************************************************************************************************/
 
        
        if Doc:IsDepoAcc(p-acc_from) then
        do: 
            if not Doc:RemHoldDepo(p-acc_from,amt-tmp) then  
            do: 
              /* Произошла ошибка разморозки депозита */
               p-err = "Ошибка разморозки средств счета " + p-acc_from.
               return.
            end. 
        end.
        
        run txb_trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then  
        do:
          p-err = "Ошибка проводки " + trxcode +  " rcode = " +  string(rcode) +  ":" +  rdes +  " " + string( s-jh ).
          message p-err.
          return.
          
        end.
        else do:

          message "Start снятие комиссии...".
          
          if Doc:com_conv > 0 then do:
            /* снятие комиссии */
            if Doc:IsDepoAcc(Doc:com_accno) then
            do:
                message "Комиссия с депозитного счета " + Doc:com_accno.
                if not Doc:RemHoldDepo(Doc:com_accno,Doc:com_conv) then
                do: 
                   p-err = "Ошибка разморозки средств счета " + Doc:com_accno.
                   return.
                end. 
            end.
            
               if Doc:CRCC:get-code(Doc:com_accno) <> "KZT" then do: /* комиссия с валютного счета, значит используем шаблон с ковертацией */
                      trxcode = "dil0072".
                      run txb_trxgen (trxcode, dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                         message p-err.
                         return.
                      end.
               end.
               else do:
                      trxcode = "dil0022".
                      run txb_trxgen (trxcode, dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                         message p-err.
                         return.
                      end.
               end.
          end.

          message "Зачисление доходов... TRX = " + string( s-jh ).
          
            /* Зачисление доходов при срочной покупке*/
            if Doc:DocType = 1 then do: /* Срочная покупка */
              if diff_tamount < 0 then
              do: /* Зачисление доходов 453010*/
                trxcode = "dil0044".
                run txb_trxgen(trxcode, dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then
                do:
                   p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                   message p-err.
                   return.
                end.
              end.
            end.
            /* Зачисление доходов при срочной продаже*/
            if Doc:DocType = 3 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 trxcode = "dil0044".
                 run txb_trxgen(trxcode, dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                    message p-err.
                    return.
                 end.
               end.
            end.
            /* Зачисление доходов при кроссконвертации*/
            if Doc:DocType = 6 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 trxcode = "dil0044".
                 if Doc:input_crc = i_crc_acc_from then run txb_trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 else run txb_trxgen(trxcode, dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                    message p-err.
                    return.
                 end.
               end.
            end.
           
            message "Штамп...".
            
            run txb_trxgen('7777777', dlm, "Штамп","DIL",Doc:DocNo,6, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then
            do:
              p-err =  "Ошибка штамповки проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
              message p-err.
              return.
            end.
            else do:

                 message "Транзакция сделана" skip  "jh " s-jh .

                /*******************************************************************************************/
                do transaction:
                 if Doc:id_viprate <> 0 then
                 do:
                    find first txb.viprate where txb.viprate.idrate = Doc:id_viprate exclusive-lock no-error.
                    if avail txb.viprate then
                    do:
                      txb.viprate.summ = Doc:summ_vip - Doc:v_amount.
                      txb.viprate.jh = s-jh.
                    end.
                 end.
                end. /*transaction*/
                /*******************************************************************************************/


               do transaction:
                find b-dealing_doc where b-dealing_doc.docno = Doc:DocNo exclusive-lock no-error.
                b-dealing_doc.jh = s-jh.
                find current b-dealing_doc no-lock no-error.
                 create txb.trgt.
                 txb.trgt.jh = s-jh.
                 txb.trgt.rem1 = "Осуществление платежей в пользу резидентов".
                 txb.trgt.rem2 = note.
               end. /*transaction*/
                
            end.
        end.

      /* end. */ /*transaction*/
   end.
   else message "Нет активного документа!" view-as alert-box.

end procedure.
/***********************************************************************************************************************/    
procedure RemHold:
  define input parameter vaaa as character.
  define input parameter vamt as decimal. 
  
  def var vln as inte initial 7777777.
  def var v-propath as char no-undo.
  v-propath = propath.
  message "Start RemHold propath = " + v-propath.
  

    if vamt <= 0 then return.
   /* do transaction:*/
     find txb.aaa where txb.aaa.aaa = vaaa exclusive-lock no-error.
     if not available txb.aaa then return.
     propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.
     find txb.aas where txb.aas.aaa = vaaa and txb.aas.ln = vln exclusive-lock no-error.
     if available txb.aas then do:
        txb.aas.chkdt = Doc:GlobalVar:g-today.
        txb.aas.whn = today.
        txb.aas.who = Doc:GlobalVar:g-ofc.
        txb.aas.tim = time.
        txb.aas.chkamt = aas.chkamt - vamt.
        txb.aaa.hbal = aaa.hbal - vamt.
        if txb.aaa.hbal < 0 then aaa.hbal = 0.
        /*
        if txb.aas.chkamt <= 0 then delete aas.
        
        */
     end.
     find current txb.aas no-lock no-error.
     find current txb.aaa no-lock no-error.
   /* end.*/
    
  propath = v-propath no-error.
  message "End RemHold " + string(txb.aas.chkamt) + " | " + string(txb.aaa.hbal).
end procedure.
/***********************************************************************************************************************/    

