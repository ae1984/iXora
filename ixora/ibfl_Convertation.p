/* ibfl_Convertation.p
 * MODULE
        ИБФЛ 
 * DESCRIPTION
        конвертация между своими счетами клиента ИБФЛ
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

define input parameter p-cif as character no-undo.
define input parameter p-acc_from as character no-undo.
define input parameter p-acc_to as character no-undo.
define input parameter p-acc_comm as character no-undo.
define input parameter p-amount as character no-undo.
define input parameter p-amount-crc as character no-undo.
define input parameter p-std as class GlobalClass.
define input parameter p-type as character no-undo.
define output parameter p-replyText as character.
define output parameter p-err as character no-undo.


define buffer b-cif for txb.cif.
define buffer b-aaa for txb.aaa.
define buffer b-arp for txb.arp.
define buffer b-crc for txb.crc.
define buffer b-lon for txb.lon.
define buffer b-lgr for txb.lgr.


define variable l_card_acc_from as log init false. /*true если счет снятия карточный*/
define variable l_card_acc_to as log init false.   /*true если счет зачисления карточный*/
define variable i_crc_acc_from as int init 0.      /*валюта счета снятия*/
define variable i_crc_acc_to as int init 0.        /*валюта счета зачисления*/
define variable c_cif_from as character no-undo.   /*cif код владельца счета снятия*/
define variable c_cif_to as character no-undo.     /*cif код владельца счета зачисления*/
define variable crc_acc_from as character no-undo. /*код валюта счета снятия */
define variable crc_acc_to as character no-undo.   /*код валюта счета зачисления*/
define variable cif_geo as character no-undo.      /*признак резидентства*/

define variable v-out as log.
define variable v-des as char.
define variable tmp-char as character no-undo.
define variable tmp-deci as decimal.
define variable TypeOperation as character no-undo init "".

define variable  diff_tamount   as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Курсовая разница*/
define variable  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".         /* Сумма в тенге по курсу нац банка начальная*/
define variable  avg_tamount2   as decimal  format "zzz,zzz,zzz,zzz.99".         /* Сумма в тенге по курсу нац банка конечная*/
define variable  trxcode as char.

define variable Purpose as character no-undo.
define variable DocNo as character no-undo.
define variable dType as integer.
define variable s-jh as integer.
def  var dlm    as char init "^".
def  var rcode  as int.
def  var rdes   as char.
/*************************************************************************************************/
if p-cif = "" then do:
  p-err = "ERR: " + p-type + " -> no cif".
  message p-err.
  return.  
end.
if p-acc_from = "" then do:
  p-err = "ERR: " + p-type + " -> no acc_from".
  message p-err.
  return.  
end.
if p-acc_to = "" then do:
  p-err = "ERR: " + p-type + " -> no acc_to".
  message p-err.
  return.  
end.
if p-acc_comm = "" then do:
  p-err = "ERR: " + p-type + " -> no p-acc_comm".
  message p-err.
  return.  
end.
if p-amount = "" then do:
  p-err = "ERR: " + p-type + " -> no amount".
  message p-err.
  return.  
end.
/*************************************************************************************************/
find first b-cif where b-cif.cif = p-cif no-lock no-error. 
if available b-cif then do:
   if b-cif.geo = "021" then cif_geo = "1".
   else cif_geo = "2".
end. 
else do:
    p-err = "Не найден код клиента " + p-cif. 
    message p-type + " -> " + p-err.
    return.
end.    
/*************************************************************************************************/
find first b-aaa where b-aaa.aaa = p-acc_to no-lock no-error.
if available b-aaa then do:
   if (b-aaa.lgr = "138" or b-aaa.lgr = "139" or b-aaa.lgr = "140") and b-aaa.gl = 220430 then l_card_acc_to = true.
   else l_card_acc_to = false. 
   i_crc_acc_to = b-aaa.crc.
   c_cif_to = b-aaa.cif.
end. 
else do:
  p-err = "Не найден счет для зачисления!". 
  message p-type + " -> " + p-acc_to + "  " + p-err.
  return.
end.       
/*************************************************************************************************/
find first b-aaa where b-aaa.aaa = p-acc_from no-lock no-error.
if available b-aaa then do:
   find last b-lgr where b-lgr.lgr = b-aaa.lgr no-lock no-error. 
   if (b-aaa.lgr = "138" or b-aaa.lgr = "139" or b-aaa.lgr = "140") and b-aaa.gl = 220430 then l_card_acc_from = true.
   else l_card_acc_from = false.
   i_crc_acc_from = b-aaa.crc.
   c_cif_from = b-aaa.cif.
   if lookup(b-aaa.lgr,"478,479,480,481,482,483,A38,A39,A40,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") > 0  then do:
      p-err =  "Внимание: Конвертация данного счета запрещена".
      message p-type + " -> " + p-acc_from + "  " + p-err.
      return.
   end.
   
          
    /*************************************************************************************************/
    if i_crc_acc_from = 1 then dType = 1.
    else
    if i_crc_acc_to = 1 then dType = 3.
    else
    if i_crc_acc_from <> 1 and i_crc_acc_to <> 1 then dType = 6.
    /*************************************************************************************************/
   
   if ((b-aaa.gl >= 220300 and b-aaa.gl <= 220399) or (b-aaa.gl >= 220400 and b-aaa.gl <= 220499)) and
           ((cif_geo = "2" and (dType = 3)) or (dType = 1 or dType = 6))  then do:
           /*Доработать формат сообщения на конвертацию из ИБ, для передачи цели покупки!*/
          Purpose ='212417 «Прочее»'.
   end. 
   else Purpose =''.        
end. 
else do:
  p-err = "Не найден счет для списания!". 
  message p-type + " -> " + p-acc_from + "  " + p-err.
  return.
end.
/*************************************************************************************************/
if i_crc_acc_from = i_crc_acc_to then do:
  p-err = "Неверная валюта счета!". 
  message p-type + " -> " + p-err.
  return.  
end.
/*************************************************************************************************/
if c_cif_from <> c_cif_to then do:
  p-err = "Неверный владелец счета!". 
  message p-type + " -> " + p-err.
  return.  
end.
/*************************************************************************************************/
find first b-crc where b-crc.crc = i_crc_acc_from no-lock.
if available b-crc then crc_acc_from = b-crc.code.
find first b-crc where b-crc.crc = i_crc_acc_to no-lock.
if available b-crc then crc_acc_to = b-crc.code.
/*************************************************************************************************/

if not l_card_acc_from and not l_card_acc_to then TypeOperation = "AccToAcc".
else
if l_card_acc_from and l_card_acc_to then TypeOperation = "CardToCard".
else
if l_card_acc_from and not l_card_acc_to then TypeOperation = "CardToAcc".
else
if not l_card_acc_from and l_card_acc_to then TypeOperation = "AccToCard".


             

            DEF VAR Doc AS CLASS ConvDocClassTxb.
            Doc = NEW ConvDocClassTxb(dType,p-std).
            
            Doc:AddData().
            Doc:purpose = Purpose.
            
            if Doc:DocType = 1 or Doc:DocType = 6 then do: 
               Doc:tclientaccno = p-acc_from. 
               Doc:vclientaccno = p-acc_to. 
               if p-amount-crc = '' then Doc:input_crc = Doc:CRCC:get-id-crc( Doc:CRCC:get-code(Doc:tclientaccno) ).
            end.
            if Doc:DocType = 3 then do: 
               Doc:vclientaccno = p-acc_from. 
               Doc:tclientaccno = p-acc_to. 
               if p-amount-crc = '' then Doc:input_crc = Doc:CRCC:get-id-crc( Doc:CRCC:get-code(Doc:vclientaccno) ).
            end.
            
            if Doc:input_crc = 0 then Doc:input_crc = Doc:CRCC:get-id-crc(p-amount-crc ).
            
            Doc:crc = Doc:CRCC:get-crc(Doc:vclientaccno).
            Doc:f_amount = decimal(p-amount).
            Doc:com_accno = p-acc_comm.
            
            
            /*******************************************************************************************/
            
            /*******************************************************************************************/
             message "Doc:dType        = " + string(dType) + "~n" +
                     "TypeOperation    = " + TypeOperation + "~n" +       
                     "Doc:tclientaccno = " + Doc:tclientaccno + "~n" +
                     "Doc:vclientaccno = " + Doc:vclientaccno + "~n" +
                     "Doc:crc          = " + string(Doc:crc) + "~n" +
                     "Doc:input_crc    = " + string(Doc:input_crc) + "~n" +
                     "Doc:f_amount     = " + string(Doc:f_amount) + "~n" +
                     "Doc:com_accno    = " + Doc:com_accno.
       

       /**********************************************************************************************************/
       message "Start CheckDocTxb...".
       if Doc:CheckDocTxb(p-err,TypeOperation) = false then do: message p-err.  end.
       else do:
           message p-type + " -> CheckDocTxb Local ACC =  OK.".
           /****************************************************/
           if(TypeOperation = "CardToCard" or TypeOperation = "CardToAcc") then 
           do:
              run ow_send("GetBalance","",p-acc_from,"","","","","","","",output v-des,output v-out).
              if not v-out then do:
                p-err = "Ошибка проверки остатка OW на счете " + p-acc_from. 
                message p-type + " -> " + v-des.
              end.
              else do: 
                   tmp-char = GetParamValueOne(v-des,"Available").
                   tmp-deci = 0. 
                   
                   if Doc:DocType = 1 or Doc:DocType = 6 then do:
                     if Doc:tclientaccno = Doc:com_accno then tmp-deci = Doc:com_conv + Doc:t_amount. 
                     else  tmp-deci = Doc:t_amount. 
                   end.
                   else do:
                     if Doc:vclientaccno = Doc:com_accno then  tmp-deci = Doc:com_conv + Doc:v_amount. 
                     else  tmp-deci = Doc:v_amount. 
                   end.
                       
                   if decimal(tmp-char) < tmp-deci then do:
                     p-err = "Недостаток средств на счете " + p-acc_from. 
                     message p-type + " -> " + p-err.
                   end. 
              end.
           end.  
           /****************************************************/
           if p-err <> "" then do: if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR. return. end.
           message p-type + " -> CheckDocTxb OW ACC =  OK.".
           
           
            if p-type = "checkConversionOwn" then do:
                 p-replyText = "<Data><Check>OK</Check>".
                 p-replyText = p-replyText + "<Rate>" + trim(string(Doc:cur_rate,"zzzzzz.9999")) + "</Rate>".
                 p-replyText = p-replyText + "<TAmount>" + trim(string(Doc:t_amount,"zzzzzzzzzzzz9.99-")) + "</TAmount>".
                 p-replyText = p-replyText + "<VAmount>" + trim(string(Doc:v_amount,"zzzzzzzzzzzz9.99-")) + "</VAmount>".
                 p-replyText = p-replyText + "<Comission>" + trim(string(Doc:com_conv,"zzzzzzzzzzzz9.99-")) + "</Comission>".
                 p-replyText = p-replyText + "</Data>".
            end.  
            if p-type = "doConversionOwn" then do:
                
                Doc:NewDoc(). /* Сохранение документа */
                if not Doc:FindDoc(Doc:DocNo) then do: p-err = "Ошибка метода FindDoc". message p-type + " -> " + p-err. end.
                else if not Doc:CalcDoc(p-err,TypeOperation) then do: message p-type + " CalcDoc -> " + p-err. end.
                else do:
                  
                     
                    define variable amt-tmp as decimal init 0.
                    define variable hbl-tmp as decimal init 0.
                    /*******************************************************************************/ 
                    /*
                    def var MsgCode as class MessageCodeClass.
                    MsgCode = NEW MessageCodeClass().
                    */        
                    case TypeOperation:
                         when "AccToAcc" then do:
                             run ibfl_Trx_AccToAcc(Doc,output s-jh,output p-err).
                         end.
                         when "CardToCard" then do:
                             run ibfl_Trx_CardToCard(Doc,output s-jh,output p-err).
                         end.
                         when "CardToAcc" then do:
                            run ibfl_Trx_CardToAcc(Doc,output s-jh,output p-err).
                         end.
                         when "AccToCard" then do: 
                             run ibfl_Trx_AccToCard(Doc,output s-jh,output p-err).
                         end.
                         otherwise do:
                          p-err = "Невозможно определить тип операции!". 
                          message p-type + " -> " + p-err.
                          return.
                         end.
                    end case.    
                    /*
                    if VALID-OBJECT(MsgCode)  then DELETE OBJECT MsgCode NO-ERROR.
                    */
                    /*******************************************************************************/
                    
                    message "Convertation Result s-jh = " + string(s-jh) + " p-err = " + p-err.
                    if p-err <> "" and s-jh <> 0 then 
                    do:
                      run txb_trxgen('9999999', dlm , "Удаление","DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                        message "Ошибка удаления проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                        /* run mail*/
                      end.
                      else do:
                       message "Проводка " + string( s-jh ) + " удалена.".   
                       s-jh = 0.
                      end. 
                    end.
                    
                end. /*p-type = "doConversionOwn" */
                
                    
                if s-jh <> 0 then p-replyText = "<Data><Trx>" + string(s-jh) + "</Trx><Time>" + string(time,"HH:MM:SS")+ "</Time></Data>".
            end.
       end. /*Doc:CheckDocTxb*/  
        /**********************************************************************************************************/
        if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
        /**********************************************************************************************************/
 
 message p-type + " -> OK, CIF=" + p-cif + " msgBody=" + p-replyText.
        
/*************************************************************************************************/
/*
procedure do_exprtrans:
  /* При срочной покупке-продаже и кросс конвертации */
  def  var rcode  as int.
  def  var rdes   as char.
  def  var dlm    as char init "^".
  def  var vparam as char.
  define variable note as character.
  define buffer b-dealing_doc for txb.dealing_doc.
  
  if VALID-OBJECT(Doc) then
  do:
       message p-type + " -> TypeOperation  = " + TypeOperation.  
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
       do transaction:

       /**********************************************************************************************************/


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
                                      Doc:tclientaccno + dlm +
                                      Doc:ACC:arpacc() + dlm +
                     "Конвертация собственных средств" + dlm +
                                  string(Doc:v_amount) + dlm +
                                       string(Doc:crc) + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                                      Doc:vclientaccno + dlm +
                         "Зачисление на валютный счет" + dlm +
                                  string(/*avg_tamount */ Doc:t_amount) + dlm +
                                  string(Doc:v_amount).
                                  note = "Срочная покупка валюты".
         
                     case TypeOperation:
                         when "AccToAcc" then do:
                             trxcode = "dil0066".
                         end.
                         when "CardToCard" then do:
                         end.
                         when "CardToAcc" then do:
                             run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB",crc_acc_from,string(Doc:t_amount),"Конвертация собственных средств" ,"0",output v-des,output v-out).
                              if not v-out then do:
                                /* Транзакция OW не удалась*/  
                                p-err = "Ошибка формирования транзакции OW - " + v-des.
                                message p-err.
                                return.
                              end.
                              else message p-type + " -> OW transaction  =  OK.". 
                             trxcode = "dil0073".
                         end.
                         when "AccToCard" then do: 
                         end.
                     end case. 
          
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
                                      Doc:vclientaccno + dlm +
                               Doc:ACC:valacc(Doc:crc) + dlm +
                     "Конвертация собственных средств" + dlm +
                                  string(Doc:t_amount) + dlm +
                                                   "1" + dlm +
                                      Doc:ACC:arpacc() + dlm +
                                      Doc:tclientaccno + dlm +
                   "Зачисление тенге на счет клиента " + dlm +
                                  string(Doc:v_amount) + dlm +
                                  string(/*avg_tamount*/ Doc:t_amount).
                                  note = "Срочная продажа валюты".
          trxcode = "dil0070". /* было trxcode = "dil0066".*/
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

          note = "Кросс конвертация".  /**/
          trxcode = "dil0069".
       end.
       /**********************************************************************************************************/

        run txb_trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then
        do:
          p-err = "Ошибка проводки " + trxcode +  " rcode = " +  string(rcode) +  ":" +  rdes +  " " + string( s-jh ).
          message p-err.
          return.
        end.
        else do:

          if Doc:com_conv > 0 then do:
           /* снятие комиссии */
               if Doc:CRCC:get-code(Doc:com_accno) <> "KZT" then do: /* комиссия с валютного счета, значит используем шаблон с ковертацией */
                             
                      
                      case TypeOperation:
                         when "AccToAcc" then do:
                             vparam = string(Doc:com_conv) + dlm + 
                                             Doc:com_accno + dlm + 
                                             Doc:acc_com.
                             trxcode = "dil0072".
                         end.
                         when "CardToCard" then do:
                         end.
                         when "CardToAcc" then do:
                             
                              run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB",crc_acc_from,string(Doc:com_conv),"Комиссия за конвертацию №" + string( s-jh ),"0",output v-des,output v-out).
                              if not v-out then do:
                                p-err = "Ошибка формирования транзакции OW comission - " + v-des.
                                message p-err.
                                return.
                              end.
                              else message p-type + " -> OW transaction comm  =  OK.". 
                              
                             vparam = string(Doc:CRCC:get-crc(Doc:com_accno)) + dlm +
                                      string(Doc:com_conv) + dlm + 
                                             Doc:com_accno + dlm + 
                                             Doc:acc_com. 
                             trxcode = "dil0074".
                         end.
                         when "AccToCard" then do: 
                         end.
                     end case.
                     
                      run txb_trxgen (trxcode, dlm, vparam ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         p-err =  "Ошибка проводки " + trxcode + " rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                         message p-err.
                         return.
                      end.
               end.
               else do:
                    run txb_trxgen ('dil0022', dlm, string(Doc:com_conv) + dlm + Doc:com_accno + dlm + Doc:acc_com ,"DIL" ,Doc:DocNo,0,  output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                         p-err =  "Ошибка проводки dil0022 rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                         message p-err.
                         return.
                      end.
               end.
          end.

            /* Зачисление доходов при срочной покупке*/
            if Doc:DocType = 1 then do: /* Срочная покупка */
              if diff_tamount < 0 then
              do: /* Зачисление доходов 453010*/
                run txb_trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then
                do:
                   p-err =  "Ошибка проводки dil0044 rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                   message p-err.
                   return.
                end.
              end.
            end.
            /* Зачисление доходов при срочной продаже*/
            if Doc:DocType = 3 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 run txb_trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/ ,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    p-err =  "Ошибка проводки dil0044 rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                    message p-err.
                    return.
                 end.
               end.
            end.
            /* Зачисление доходов при кроссконвертации*/
            if Doc:DocType = 6 then do: /* Срочная продажа */
               if diff_tamount > 0 then
               do: /* Зачисление доходов 453010*/
                 if Doc:input_crc = i_crc_acc_from then run txb_trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "285900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 else run txb_trxgen('dil0044', dlm, string(abs(diff_tamount)) + dlm + "185900" /*Doc:ACC:arpacc()*/,"DIL",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then
                 do:
                    p-err =  "Ошибка проводки dil0044 rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                    message p-err.
                    return.
                 end.
               end.
            end.
           
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
                 if Doc:id_viprate <> 0 then
                 do:
                    find first txb.viprate where txb.viprate.idrate = Doc:id_viprate exclusive-lock no-error.
                    if avail txb.viprate then
                    do:
                      txb.viprate.summ = Doc:summ_vip - Doc:v_amount.
                      txb.viprate.jh = s-jh.
                    end.
                 end.
                /*******************************************************************************************/



                find b-dealing_doc where b-dealing_doc.docno = Doc:DocNo exclusive-lock no-error.
                b-dealing_doc.jh = s-jh.
                find current b-dealing_doc no-lock no-error.
                 create txb.trgt.
                 txb.trgt.jh = s-jh.
                 txb.trgt.rem1 = "Осуществление платежей в пользу резидентов".
                 txb.trgt.rem2 = note.
                 
            end.
        end.

      end. /*transaction*/
   end.
   else message "Нет активного документа!" view-as alert-box.

end procedure.
/***********************************************************************************************************************/    

*/


