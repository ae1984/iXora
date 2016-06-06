/* ibfl_Trx_CardToCard.p
 * MODULE
        ИБФЛ конвертация Карт-Счет -> Счет 
 * DESCRIPTION
        Формирование проводок CardToAcc
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


/*define variable amt-tmp as decimal init 0.*/
def var vbal as deci.
def var vavl as deci.
def var vhbal as deci.
def var vfbal as deci.
def var vcrline as deci.
def var vcrlused as deci.
def var vooo as char.
define variable i_crc_acc_from as int init 0.      /*валюта счета снятия*/
define variable p-acc_from as character.
define variable p-acc_to as character.


define variable vrem as character no-undo.
define variable v-out as log.
define variable v-des as char.


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
       define variable IdFreeze as character no-undo.
       define variable p-amount as decimal.
       define variable v-amount as decimal.
       /*define variable p-acc_to as character.*/
       def var MsgCode as class MessageCodeClass.
       MsgCode = NEW MessageCodeClass().
       
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
       
       /**********************************************************************************************************/
       v-amount = 0.
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
         p-acc_from = Doc:tclientaccno.
         p-acc_to = Doc:vclientaccno. 
         i_crc_acc_from = Doc:CRCC:get-crc(Doc:tclientaccno).
         MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:tclientaccno),"PAYMFIB"). 
              
                         vparam = string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                                 "arp" + dlm +
                 /*Doc:tclientaccno*/ MsgCode:GetAcc() + dlm +
                                      Doc:ACC:arpacc() + dlm +
                     "Конвертация собственных средств" + dlm +
                                                 "213" + dlm +
                                  string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                              Doc:ACC:valacc(Doc:crc)  + dlm +
                                                 "arp" + dlm.
MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:vclientaccno),"PAYMTOIB").
                /*Doc:vclientaccno*/   vparam = vparam + MsgCode:GetAcc() + dlm +                             
                         "Зачисление на валютный счет" + dlm +
                                  string(Doc:t_amount) + dlm +
                                  string(Doc:v_amount).
                                  note = "Срочная покупка валюты".
            v-amount = Doc:v_amount.                  
            /*trxcode = "dil0066".*/
            trxcode = "dil0073".
            /*p-acc_to = Doc:vclientaccno.*/
            p-amount = Doc:t_amount.
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
         p-acc_from = Doc:vclientaccno.
         p-acc_to = Doc:tclientaccno.
         i_crc_acc_from = Doc:CRCC:get-crc(Doc:vclientaccno).
         MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:vclientaccno),"PAYMFIB").
         
                         vparam = string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                                                 "arp" + dlm +
                 /*Doc:vclientaccno*/ MsgCode:GetAcc() + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                     "Конвертация собственных средств" + dlm +
                                                 "223" + dlm +
                                  string(Doc:t_amount) + dlm +
                                                   "1" + dlm +                                                    
                                      Doc:ACC:arpacc() + dlm +
                                                 "arp" + dlm.
 MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:tclientaccno),"PAYMTOIB").
/*Doc:tclientaccno*/ vparam = vparam + MsgCode:GetAcc() + dlm +
                   "Зачисление тенге на счет клиента " + dlm +
                                  string(Doc:v_amount) + dlm +
                                  string(/*avg_tamount*/ Doc:t_amount).
                                  note = "Срочная продажа валюты".
          v-amount = Doc:t_amount.           
          /* knp 223*/             
          trxcode = "dil0073". /* было trxcode = "dil0070".*/
          /*p-acc_to = Doc:tclientaccno.*/
          p-amount = Doc:v_amount.
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
         p-acc_from = Doc:tclientaccno.
         p-acc_to = Doc:vclientaccno. 
         i_crc_acc_from = Doc:CRCC:get-crc(Doc:tclientaccno).
         MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:tclientaccno),"PAYMFIB").
         /* ввод суммы на конвертацию 'начальная', значит берем учетный курс первой валюты sb = 1 */
        
        if Doc:input_crc = i_crc_acc_from then do:
          vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                                 "arp" + dlm +
                 /*Doc:tclientaccno*/ MsgCode:GetAcc() + dlm + /*счет клиента начальный*/
                     "Конвертация собственных средств" + dlm + /**/
                                 string( avg_tamount ) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                string( avg_tamount /*avg_tamount2*/ ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                                 "arp" + dlm.
         MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:vclientaccno),"PAYMTOIB").                                                 
/*Doc:vclientaccno*/ vparam = vparam + MsgCode:GetAcc() + dlm + /*счет клиента конечный*/
                         "Зачисление на валютный счет".        /**/
         
         /* ввод суммы на конвертацию 'конечная', значит берем учетный курс второй валюты sb = 2 */
         end.
         else  do:
           vparam = string(Doc:t_amount) + dlm + /*сумма в начальной валюте*/
            string(Doc:CRCC:get-crc(Doc:tclientaccno)) + dlm + /*валюта начальная*/
                                                 "arp" + dlm +
                 /*Doc:tclientaccno*/ MsgCode:GetAcc() + dlm + /*счет клиента начальный*/
                     "Конвертация собственных средств" + dlm + /**/
                                 string( avg_tamount2) + dlm + /*Сумма в тенге начальной валюты по учетному курсу*/
                                      Doc:ACC:arpacc() + dlm + /*тенговый арп счет*/
                                 string(avg_tamount2 ) + dlm + /*Сумма в тенге конечной валюты по учетному курсу*/
                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                               Doc:ACC:valacc(Doc:crc) + dlm + /*транзитный валютный счет*/

                                  string(Doc:v_amount) + dlm + /*сумма в конечной валюте*/
                                       string(Doc:crc) + dlm + /*валюта конечная*/
                                                 "arp" + dlm.
 MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:vclientaccno),"PAYMTOIB").                                                 
/*Doc:vclientaccno*/ vparam = vparam + MsgCode:GetAcc() + dlm + /*счет клиента конечный*/                                                 
                         "Зачисление на валютный счет".        /**/
          
        end.
          v-amount = Doc:v_amount.
          note = "Кросс конвертация".  /**/
          trxcode = "dil0074". /*Было "dil0069*/
          /*p-acc_to = Doc:vclientaccno.*/
          p-amount = Doc:t_amount.
       end. 
       /**********************************************************************************************************/
 
            
        run ow_send("Freeze","",p-acc_from,"","","PAYMFIB",Doc:CRCC:get-code(p-acc_from),string(p-amount),"Блокирование средств для операции конвертации","",output v-des,output v-out).
        if not v-out then do:
           p-err = "Ошибка блокирования средств для операции конвертации транзакции OW - " + v-des.
           message "Freeze OW - " + p-err.
           return.
        end.  
        else message "Freeze OW - OK.".
        IdFreeze = GetParamValueOne(v-des,"FrID").
        message "Freeze OW № " + IdFreeze. 
                  
        run txb_trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then  
        do:
          /*Unfreeze*/
          run ow_send("UnFreeze","",p-acc_from,"","","PAYMFIB","","","",IdFreeze,output v-des,output v-out).
          if not v-out then do:
            /* Транзакция OW не удалась*/  
            p-err = "Ошибка разблокирования транзакции OW - " + v-des.
            message "UnFreeze OW - " + p-err.
            end. 
          else message "UnFreeze OW - OK.".
          p-err = "Ошибка проводки " + trxcode +  " rcode = " +  string(rcode) +  ":" +  rdes +  " " + string( s-jh ).
          message p-err.
          return.
        end.
        else do:
          
          vrem = "Конвертация собственных средств №" + string(s-jh).
          run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB",Doc:CRCC:get-code(p-acc_from),string(p-amount),vrem,IdFreeze,output v-des,output v-out).
          if not v-out then do:
             /* Транзакция OW не удалась*/  
             p-err = "Ошибка формирования транзакции OW - " + v-des.
             message p-err.
             return.
          end.
          
          vrem = "Зачисление средств конвертации №" + string(s-jh).
          run ow_send("DoTransaction","",p-acc_to,"","","PAYMTOIB",Doc:CRCC:get-code(p-acc_to),string(v-amount),vrem,"0",output v-des,output v-out).
          if not v-out then do:
             /* Транзакция OW не удалась*/  
             p-err = "Ошибка формирования транзакции OW - " + v-des.
             message p-err.
             return.
          end.
                      
          message "Start снятие комиссии...".
          
          if Doc:com_conv > 0 then do:
                  rcode = 0.
                  MsgCode:SetMessageCode(Doc:CRCC:get-crc(Doc:com_accno),"PAYMFIB"). 
                  run ow_send("Freeze","",Doc:com_accno,"","","PAYMFIB",Doc:CRCC:get-code(Doc:com_accno),string(Doc:com_conv),"Блокирование средств для операции конвертации","",output v-des,output v-out).
                  if not v-out then do:
                    p-err = "Ошибка блокирования средств для операции конвертации транзакции OW - " + v-des.
                    message "Freeze OW - " + p-err.
                    return.
                  end.  
                  else message "Freeze OW - OK.".
                  IdFreeze = GetParamValueOne(v-des,"FrID").
                  message "Freeze OW № " + IdFreeze.
                  
                  if Doc:CRCC:get-code(Doc:com_accno) <> "KZT" then do:
                          trxcode = "dil0076".
                          vparam = string(Doc:com_conv) + dlm + 
                                                  "arp" + dlm + 
                                       MsgCode:GetAcc() + dlm + 
                                           Doc:acc_com.
                          run txb_trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
                          if rcode ne 0 then
                          do:
                             p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                             message p-err.
                          end.
                  end.
                  else do:
                          trxcode = "dil0075".
                          vparam = string(Doc:com_conv) + dlm +
                                         "arp"  + dlm +
                               MsgCode:GetAcc() + dlm +
                                   Doc:acc_com  + dlm +
                            "Комиссия за конвертацию".
                          run txb_trxgen (trxcode, dlm, vparam, "arp", MsgCode:GetAcc(),0, output rcode, output rdes, input-output s-jh).
                          if rcode <> 0 then do:
                             p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                             message p-err.
                          end.
                  end.
                  
                  if rcode <> 0 then do:
                     run ow_send("UnFreeze","",Doc:com_accno,"","","PAYMFIB","","","",IdFreeze,output v-des,output v-out).
                     if not v-out then do:
                       /* Транзакция OW не удалась*/  
                       p-err = "Ошибка разблокирования транзакции OW - " + v-des.
                       message "UnFreeze OW - " + p-err.
                     end.
                     else message "UnFreeze OW - OK". 
                     return.
                  end.
             
                  vrem = "Комиссия за конвертацию №" + string(s-jh).
                  run ow_send("DoTransaction","",Doc:com_accno,"","","PAYMFIB",Doc:CRCC:get-code(Doc:com_accno),string(Doc:com_conv),vrem,IdFreeze,output v-des,output v-out).
                  if not v-out then do:
                    /* Транзакция OW не удалась*/  
                    p-err = "Ошибка формирования транзакции OW - " + v-des.
                    message "DoTransaction OW - " + p-err.
                    return.
                  end. 
                  else message "DoTransaction OW - OK.".                
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
        if VALID-OBJECT(MsgCode)  then DELETE OBJECT MsgCode NO-ERROR.
      /* end. */ /*transaction*/
   end.
   else message "Нет активного документа!" view-as alert-box.

end procedure.
/***********************************************************************************************************************/    
 

