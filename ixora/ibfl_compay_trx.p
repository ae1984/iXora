/* compay_trx.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        03/11/2009 id00205
        13.10.2010 k.gitalov перекомпиляция
        25.10.2010 k.gitalov проверка на доступность сервиса
 * CHANGES
        02.02.2012 lyubov - изменила симв.касспл.: было 200, стало 100

*/

{xmlParser.i}

def input param Doc as COMPAYDOCClass.
def input param p-acc_from as character.
def input param TypeOperation as character.
def output param iRez as log init no.
define output parameter s-jh as integer.

/************************************************************************************/
find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then
do:
  if comm.pksysc.loval = no then
  do:
    message "Прием платежей Авангард-Plat в данное время недоступен!" view-as alert-box title "Внимание".
    return.
  end.
end.
else do:
  message "Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.
/************************************************************************************/



 if not VALID-OBJECT(Doc)  then do: message "Объект не инициализирован!" view-as alert-box. return. end.

 def var vdel   as char init "^".
 def var v-param as char.
 def var rcode  as int.
 def var rdes   as char.
 define variable p-err as character.
 def var casvod as log.
 def var v-yn   as log init false.
 def var v-err  as log init false.
 define variable vrem as character no-undo.
 def var jdno as char.
 define variable IdFreeze as character no-undo.
 /*def new shared var s-jh like txb.jh.jh.*/

 vrem = "Оплата услуг " + Doc:suppname.
 
            case TypeOperation:
              when "FromAcc" then do:
                 /*Платеж*/
                  v-param = "" + vdel +
                  string(Doc:summ) + vdel +
                  "1" + vdel + /* валюта */
                  p-acc_from + vdel +
                  Doc:arp + vdel +
                  vrem + vdel +
                  Doc:knp. /*"321". код назначения платежа */
                  s-jh = 0.
                  if p-err = "" then do:
                      run txb_trxgen ("jou0028", vdel, v-param, "cif", Doc:arp,0, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                        p-err = rdes.  
                        message "txb_trxgen -> " + p-err.
                        return.
                      end.
                  end.
                  /*комиссия*/
                  if Doc:comm_summ > 0 then do:
                      vrem = "Комиссия за оплату " + Doc:suppname.
                      /*Формирование проводки */
                      v-param = string(Doc:comm_summ) + vdel +
                                             "cif"  + vdel +
                                         p-acc_from + vdel +
                                         Doc:incom  + vdel + vrem.
                      /*потом доработать по аналогии комиссия с валютного счета - dil0072*/          
                      run txb_trxgen ("dil0075", vdel, v-param, "cif", Doc:incom,0, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                         p-err = rdes.  
                         message "txb_trxgen -> " + p-err.
                         return.
                      end.
                  end.
                  
                        
              end.
              when "FromCard" then do:
                 def var MsgCode as class MessageCodeClass.
                 MsgCode = NEW MessageCodeClass().
                 MsgCode:SetMessageCode(1,"PAYMFIB").
                 
                    run ow_send("Freeze","",p-acc_from,"","","PAYMFIB","KZT",string(Doc:summ),"Блокирование средств для коммунального платежа","",output rdes,output iRez).
                    if not iRez then do:
                       p-err = "Ошибка блокирования средств для коммунального платежа - " + rdes.
                       message "Freeze OW - " + p-err.
                       return.
                    end.  
                    else message "Freeze OW - OK.".
                    IdFreeze = GetParamValueOne(rdes,"FrID").
                    message "Freeze OW № " + IdFreeze. 
        
                  
                      v-param = '' + vdel +
                  string(Doc:summ) + vdel +
                               "1" + vdel +
   /*p-acc_from*/ MsgCode:GetAcc() + vdel +
                           Doc:arp + vdel +
                              vrem + vdel +
                               "1" + vdel + /*резидент*/
                               "1" + vdel + Doc:knp.
                      s-jh = 0.                        
                      run txb_trxgen ("jou0036", vdel, v-param, "arp",Doc:arp,0, output rcode, output rdes, input-output s-jh).
                      if rcode <> 0 then do:
                          run ow_send("UnFreeze","",p-acc_from,"","","PAYMFIB","","","",IdFreeze,output rdes,output iRez).
                          if not iRez then do:
                            /* Транзакция OW не удалась*/  
                            p-err = "Ошибка разблокирования транзакции OW - " + rdes.
                            message "UnFreeze OW - " + p-err.
                          end. 
                          else message "UnFreeze OW - OK.".
                          
                          p-err = "Ошибка проводки " + "jou0036" +  " rcode = " +  string(rcode) +  ":" +  rdes +  " " + string( s-jh ).
                          message "txb_trxgen -> " + p-err.
                          return.
                      end. 
                      
                      /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                      run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB","KZT",string(Doc:summ),vrem,IdFreeze,output rdes,output iRez).
                      if not iRez then do:
                        /* Транзакция OW не удалась*/  
                        p-err = "Ошибка формирования транзакции 1_OW - " + rdes.
                        message "ERR: ibfl_compay_trx -> " + p-err.
                        return.
                      end.
                      
                      
                      if Doc:comm_summ > 0 then do:
                            
                            message "Start снятие комиссии...".
                         
                            run ow_send("Freeze","",p-acc_from,"","","PAYMFIB","KZT",string(Doc:comm_summ),"Блокирование средств для оплаты комиссии №" + string(s-jh),"",output rdes,output iRez).
                            if not iRez then do:
                               p-err = "Ошибка блокирования средств оплаты комиссии №" + string(s-jh) + " " + rdes.
                               message "Freeze OW - " + p-err.
                               return.
                            end.  
                            else message "Freeze OW - OK.".
                            IdFreeze = GetParamValueOne(rdes,"FrID").
                            message "Freeze OW № " + IdFreeze. 
                    
                             
                              vrem = "Комиссия за оплату " + Doc:suppname.
                              /*Формирование проводки */
                              v-param = string(Doc:comm_summ) + vdel +
                                                     "arp"  + vdel +
                            /*p-acc_from*/ MsgCode:GetAcc() + vdel +
                                                 Doc:incom  + vdel + vrem.
                              
                              run txb_trxgen ("dil0075", vdel, v-param, "arp", Doc:incom,0, output rcode, output rdes, input-output s-jh).
                              if rcode <> 0 then do:
                                  run ow_send("UnFreeze","",p-acc_from,"","","PAYMFIB","","","",IdFreeze,output rdes,output iRez).
                                  if not iRez then do:
                                    /* Транзакция OW не удалась*/  
                                    p-err = "Ошибка разблокирования транзакции OW - " + rdes.
                                    message "UnFreeze OW - " + p-err.
                                  end. 
                                  else message "UnFreeze OW - OK.".
                                  
                                  p-err = "Ошибка проводки " + "dil0075" +  " rcode = " +  string(rcode) +  ":" +  rdes +  " " + string( s-jh ).
                                  message "txb_trxgen -> " + p-err.
                                  return.
                              end.
                            
                              /*Запрос на проведение операции в OW ForteDb PAYMFIB*/
                              run ow_send("DoTransaction","",p-acc_from,"","","PAYMFIB","KZT",string(Doc:comm_summ),vrem,IdFreeze,output rdes,output iRez).
                              if not iRez then do:
                                /* Транзакция OW не удалась*/  
                                p-err = "Ошибка формирования транзакции 1_OW - " + rdes.
                                message "ERR: ibfl_compay_trx -> " + p-err.
                                return.
                              end.
                      
                       
                      end.  
                  
                      
                 if VALID-OBJECT(MsgCode)  then DELETE OBJECT MsgCode NO-ERROR.
              end.
            end. /*case*/ 
            
            
                    message "Штамп...".
            
                    run txb_trxgen('7777777', vdel, "Штамп","JOU",Doc:DocNo,6, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then
                    do:
                      p-err =  "Ошибка штамповки проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                      message p-err.
                      return.
                    end.
                    else do:
                      message "Транзакция сделана" skip  "jh " s-jh .
                      Doc:Edit().
                      Doc:jh = s-jh.
                      if not Doc:Post() then do: 
                        p-err = "Ошибка при сохранении номера проводки документа!".  
                        message "txb_trxgen -> " + p-err.
                        return.
                      end.
                      iRez = true.
                    end.
 

 /*
      run jou.

      jdno = return-value.
      if jdno <> "" then
      do:
       find first joudoc where docnum = jdno.
       if avail joudoc then
       do:
        joudoc.info = Doc:payname.
        joudoc.perkod = Doc:payrnn.
        joudoc.comcode = Doc:paycod.
       end.
      end.
      else do:
        message "Ошибка формирования joudoc!" view-as alert-box.
        leave.
      end.
*/
  

 