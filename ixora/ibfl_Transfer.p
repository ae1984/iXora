/* ibfl_Transfer.p
 * MODULE
        ИБФЛ 
 * DESCRIPTION
        Переводы в одной валюте между своими счетами клиента ИБФЛ
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
        09/10/2013 k.gitalov ТЗ 2123
*/

{xmlParser.i}

define input parameter p-cif as character no-undo.
define input parameter p-acc_from as character no-undo.
define input parameter p-acc_to as character no-undo.
define input parameter p-amount as character no-undo.
define input parameter p-std as class GlobalClass.
define input parameter p-type as character no-undo.
define output parameter p-replyText as character.
define output parameter p-err as character no-undo.



if p-cif = "" then do:
  p-err = "ERR: ibfl_" + p-type + " -> no cif".
  message p-err.
  return.  
end.
if p-acc_from = "" then do:
  p-err = "ERR: ibfl_" + p-type + " -> no acc_from".
  message p-err.
  return.  
end.
if p-acc_to = "" then do:
  p-err = "ERR: ibfl_" + p-type + " -> no acc_to".
  message p-err.
  return.  
end.
if p-amount = "" then do:
  p-err = "ERR: ibfl_" + p-type + " -> no amount".
  message p-err.
  return.  
end.



define buffer b-cif for txb.cif.
define buffer b-aaa for txb.aaa.
define buffer b-arp for txb.arp.
define buffer b-crc for txb.crc.

define variable v-param as character.
define variable vrem as character init "Перевод собственных средств".
define variable vdel as character init "^".
define variable rcode as integer.
define variable rdes as character.
define variable s-jh as integer.

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
define variable TypeOperation as character no-undo init "".

define variable  Client AS CLASS ClientClass_txb.
if NOT VALID-OBJECT(Client) then Client = NEW ClientClass_txb(p-std).
/*************************************************************************************************/
find first b-aaa where b-aaa.aaa = p-acc_from no-lock no-error.
if available b-aaa then do:
   if (b-aaa.lgr = "138" or b-aaa.lgr = "139" or b-aaa.lgr = "140") and b-aaa.gl = 220430 then l_card_acc_from = true.
   else l_card_acc_from = false.
   i_crc_acc_from = b-aaa.crc.
   c_cif_from = b-aaa.cif.
end. 
else do:
  p-err = "Не найден счет для списания!". 
  message "ibfl_" + p-type + " -> " + p-acc_from + "  " + p-err.
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
  message "ibfl_" + p-type + " -> " + p-acc_to + "  " + p-err.
  return.
end.       
/*************************************************************************************************/
if i_crc_acc_from <> i_crc_acc_to then do:
  p-err = "Неверная валюта счета!". 
  message "ibfl_" + p-type + " -> " + p-err.
  return.  
end.
/*************************************************************************************************/
if c_cif_from <> c_cif_to then do:
  p-err = "Неверный владелец счета!". 
  message "ibfl_" + p-type + " -> " + p-err.
  return.  
end.
/*************************************************************************************************/
if not l_card_acc_from then do:
  if Client:check-sum(p-acc_from, decimal(p-amount)) = false then 
  do:
    p-err = "Недостаток средств на счете " + p-acc_from.  
    message "ibfl_" + p-type + " -> " + p-err.
    return.
  end.  
  
end.
else do:
  run ow_send("GetBalance","",p-acc_from,"","","","","","","",output v-des,output v-out).
  if not v-out then do:
    p-err = "Ошибка проверки остатка на счете!". 
    message "ibfl_" + p-type + " -> " + v-des.
    return.
  end.    
  tmp-char = GetParamValueOne(v-des,"Available"). 
  if decimal(tmp-char) < decimal(p-amount) then do:
    p-err = "Недостаток средств на счете " + p-acc_from. 
    message "ibfl_" + p-type + " -> " + p-err.
    return.
  end.  
end.   
/*************************************************************************************************/
find first b-crc where b-crc.crc = i_crc_acc_from no-lock.
if available b-crc then crc_acc_from = b-crc.code.
find first b-crc where b-crc.crc = i_crc_acc_to no-lock.
if available b-crc then crc_acc_to = b-crc.code.
/*************************************************************************************************/
find first b-cif where b-cif.cif = p-cif no-lock no-error. 
if available b-cif then do:
   if b-cif.geo = "021" then cif_geo = "1".
   else cif_geo = "2".
end. 
else do:
    p-err = "Не найден код клиента " + p-cif. 
    message "ibfl_" + p-type + " -> " + p-err.
    return.
end.       
/*************************************************************************************************/
if not l_card_acc_from and not l_card_acc_to then TypeOperation = "AccToAcc".
else
if l_card_acc_from and l_card_acc_to then TypeOperation = "CardToCard".
else
if l_card_acc_from and not l_card_acc_to then TypeOperation = "CardToAcc".
else
if not l_card_acc_from and l_card_acc_to then TypeOperation = "AccToCard".
/*************************************************************************************************/

if p-type = "checkTransferOwn" then 
do:
    p-replyText = "<Data><Check>OK</Check></Data>".
end.    
if p-type = "doTransferOwn" then 
do:
        define variable IdFreeze as character no-undo.
        def var MsgCode as class MessageCodeClass.
        MsgCode = NEW MessageCodeClass().

        case TypeOperation:
          when "AccToAcc" then do:
              v-param = '' + vdel +
              string(p-amount) + vdel +
              string(i_crc_acc_to) + vdel +
              p-acc_from + vdel +
              p-acc_to + vdel + vrem + vdel + "321".
              s-jh = 0.
              
              if Client:IsDepoAcc(p-acc_from) then
              do: 
                if not Client:RemHoldDepo(p-acc_from,decimal(p-amount)) then  
                do: 
                  /* Произошла ошибка разморозки депозита */
                  p-err = "Ошибка разморозки средств счета " + p-acc_from.
                end. 
              end.
        
              if p-err = "" then do:
                  run txb_trxgen ("jou0022", vdel, v-param, "cif", p-acc_to ,6, output rcode, output rdes, input-output s-jh).
                  if rcode <> 0 then do:
                    p-err = rdes. 
                    message "txb_trxgen -> " + p-err.
                  end.
              end.
                  
          end.
          when "CardToCard" then do:
                  /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                  IdFreeze = "".
                  run ow_send("Freeze","",p-acc_from,"","","PAYMFIB",crc_acc_from,string(p-amount),"Блокирование средств для операции перевода","",output v-des,output v-out).
                  if not v-out then do:
                     p-err = "Ошибка блокирования средств для операции перевода транзакции OW - " + v-des.
                     message "Freeze OW - " + p-err.
                  end.  
                  else do:
                      message "Freeze OW - OK.".
                      IdFreeze = GetParamValueOne(v-des,"FrID").
                      message "Freeze OW № " + IdFreeze. 
        
                      run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB",crc_acc_from,p-amount,vrem,IdFreeze,output v-des,output v-out).
                      if not v-out then do:
                        /* Транзакция OW не удалась*/  
                        p-err = "Ошибка формирования транзакции 1_OW - " + v-des.
                        message "ERR: ibfl_" + p-type + " -> " + v-des.
                      end.
                      /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                      if p-err = "" then do:
                          run ow_send("DoTransaction","",p-acc_to,"","","PAYMTOIB",crc_acc_to,p-amount,vrem,"0",output v-des,output v-out).
                          if not v-out then do:
                            /* Транзакция OW не удалась*/  
                            p-err = "Ошибка формирования транзакции 2_OW - " + v-des.
                            message "ERR: ibfl_" + p-type + " -> " + v-des.
                          end.
                      end.
                  end.
                      
                  if p-err = "" then do:
                      MsgCode:SetMessageCode(i_crc_acc_from,"PAYMFIB").            
                                  v-param = '' + vdel +
                                              p-amount + vdel +
                                  string(i_crc_acc_from) + vdel +
                                      MsgCode:GetAcc() + vdel.
                      MsgCode:SetMessageCode(i_crc_acc_to,"PAYMTOIB"). 
                                  v-param = v-param + MsgCode:GetAcc() + vdel +
                                              vrem + vdel +
                                              cif_geo + vdel +
                                              cif_geo + vdel +
                                              "9" + vdel +
                                              "9" + vdel +
                                              "321".
                      s-jh = 0.                        
                      run txb_trxgen ("jou0072", vdel, v-param, "arp",MsgCode:GetAcc(),6, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                        p-err = rdes.  
                        message "txb_trxgen -> " + p-err.
                      end.               
                  end.
                  else do:
                      /*Unfreeze*/
                      if IdFreeze <> "" then do:
                          run ow_send("UnFreeze","",p-acc_from,"","","PAYMFIB","","","",IdFreeze,output v-des,output v-out).
                          if not v-out then do:
                            /* Транзакция OW не удалась*/  
                            p-err = "Ошибка разблокирования транзакции OW - " + v-des.
                            message "UnFreeze OW - " + p-err.
                          end. 
                          else message "UnFreeze OW - OK.".
                      end.    
                  end.        
          end.
          when "CardToAcc" then do:
                  /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                  IdFreeze = "".
                  run ow_send("Freeze","",p-acc_from,"","","PAYMFIB",crc_acc_from,string(p-amount),"Блокирование средств для операции перевода","",output v-des,output v-out).
                  if not v-out then do:
                     p-err = "Ошибка блокирования средств для операции перевода транзакции OW - " + v-des.
                     message "Freeze OW - " + p-err.
                  end.  
                  else do:
                      message "Freeze OW - OK.".
                      IdFreeze = GetParamValueOne(v-des,"FrID").
                      message "Freeze OW № " + IdFreeze. 
                      
                      run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB",crc_acc_from,p-amount,vrem,IdFreeze,output v-des,output v-out).
                      if not v-out then do:
                        /* Транзакция OW не удалась*/  
                        p-err = "Ошибка формирования транзакции OW - " + v-des.
                        message "ERR: ibfl_" + p-type + " -> " + v-des.
                      end.
                  end.   
                  /*Формирование проводки */
                  if p-err = "" then do:
                      MsgCode:SetMessageCode(i_crc_acc_from,"PAYMFIB").
                      v-param = "" + vdel +
                      string(p-amount) + vdel +
                      string(i_crc_acc_from) + vdel + /* валюта */
                      MsgCode:GetAcc() + vdel +
                      p-acc_to + vdel +
                      vrem + vdel +
                      cif_geo + vdel + /*резидент/не резидент*/
                      cif_geo + vdel + 
                      "9" + vdel + 
                      "9" + vdel +
                      "321". /* код назначения платежа */
                      s-jh = 0.
                  
                      run txb_trxgen ("jou0073", vdel, v-param, "cif", MsgCode:GetAcc(),6, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                        p-err = rdes.  
                        message "txb_trxgen -> " + p-err.
                      end.
                  end.
                  else do:
                      /*Unfreeze*/
                      if IdFreeze <> "" then do:
                          run ow_send("UnFreeze","",p-acc_from,"","","PAYMFIB","","","",IdFreeze,output v-des,output v-out).
                          if not v-out then do:
                            /* Транзакция OW не удалась*/  
                            p-err = "Ошибка разблокирования транзакции OW - " + v-des.
                            message "UnFreeze OW - " + p-err.
                          end. 
                          else message "UnFreeze OW - OK.".
                      end.    
                  end.
                  
          end.
          when "AccToCard" then do:
                  
                  if Client:IsDepoAcc(p-acc_from) then
                  do: 
                    if not Client:RemHoldDepo(p-acc_from,decimal(p-amount)) then  
                    do: 
                      /* Произошла ошибка разморозки депозита */
                      p-err = "Ошибка разморозки средств счета " + p-acc_from.
                    end. 
                  end.
              
                  if p-err = "" then do:
                      /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                      run ow_send("DoTransaction","",p-acc_to,"","","PAYMTOIB",crc_acc_to,p-amount,vrem,"0",output v-des,output v-out).
                      if not v-out then do:
                        /* Транзакция OW не удалась*/  
                        p-err = "Ошибка формирования транзакции OW - " + v-des.
                        message "ERR: ibfl_" + p-type + " -> " + v-des.
                      end.
                  end.    
                  /*Формирование проводки */
                  MsgCode:SetMessageCode(i_crc_acc_to,"PAYMTOIB").
                  v-param = "" + vdel +
                  string(p-amount) + vdel +
                  string(i_crc_acc_to) + vdel + /* валюта */
                  p-acc_from + vdel +
                  MsgCode:GetAcc() + vdel +
                  vrem + vdel +
                  cif_geo + vdel + 
                  cif_geo + vdel +
                  "9" + vdel + 
                  "9" + vdel +
                  "321". /* код назначения платежа */
                  s-jh = 0.
                  if p-err = "" then do:
                      run txb_trxgen ("jou0074", vdel, v-param, "cif", MsgCode:GetAcc(),6, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                        p-err = rdes.  
                        message "txb_trxgen -> " + p-err.
                      end.
                  end.
          end.
          otherwise do:
              p-err = "Невозможно определить тип операции!". 
              message "ibfl_" + p-type + " -> " + p-err.
          end.
        end case.


        if VALID-OBJECT(MsgCode)  then DELETE OBJECT MsgCode NO-ERROR.
   
   if p-err = "" then  p-replyText = "<Data><Trx>" + string(s-jh) + "</Trx><Time>" + string(time,"HH:MM:SS")+ "</Time></Data>".
  
end.

if VALID-OBJECT ( Client )  then DELETE OBJECT Client NO-ERROR .

if p-err = "" then message "ibfl_" + p-type + " -> OK, CIF=" + p-cif + " msgBody=" + p-replyText.
else message "ibfl_" + p-type + " -> FAIL, CIF=" + p-cif + " msgBody=" + p-err.
