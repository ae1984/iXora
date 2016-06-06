/* ibfl_sps.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для регистрации клиента ИБФЛ
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
        13/05/2013 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{srvcheck.i}
{classes.i}
{xmlParser.i}

define variable v-terminate as logi no-undo.
v-terminate = no.

define    variable      fs           as character   no-undo init "A,B,C,D,E,F,H,K,L,M,N,O,P,Q,R,S,T".
define    variable      fsb          as character   no-undo init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".


define variable v-type       as character   no-undo.
define variable v-acc        as character   no-undo.
define variable v-phone      as character   no-undo.
define variable v-idn        as character   no-undo.
define variable v-bank       as character   no-undo.
define variable v-cif        as character   no-undo.
define variable v-err        as character   no-undo.
define variable s-err        as character   no-undo.
define variable v-out as log init no.

define variable v-acc-from as character no-undo.
define variable v-acc-to as character no-undo.
define variable v-amount as character no-undo.
define variable v-begin-date as character no-undo.
define variable v-end-date as character no-undo.
define variable v-acc-comm as character no-undo.
define variable v-amount-crc as character no-undo.

define variable id_rec as integer.
define variable WorkType as integer.
define variable v-message as character init "В данный момент проводится закрытие операционного дня<br>Попробуйте позднее.".

define variable ptpsession   as handle.
define variable consumerH    as handle.
define variable replyMessage as handle.


message "--------------------------------------------------------------------------------------------------------------".

function IsCloseDay returns logical ().
    find first comm.pksysc where comm.pksysc.sysc = "DAYCLOSE" no-lock no-error.
    if available comm.pksysc then return comm.pksysc.loval.
    else return true. 
end function.




/* Создаем объект сессии */
run jms/jmssession.p persistent set ptpsession ("-SMQConnect").
if isProductionServer() then 
do:
    run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
end. 
else 
do:
    run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").
end.

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").

run beginSession in ptpsession no-error.
if error-status:error then 
do:
    message 'ibfl_sps-> error beginSession'.
    return.
end.

/* Для всех ответных сообщений используем один объект */
run createTextMessage in ptpsession (output replyMessage) no-error.
if error-status:error then 
do:
    message 'ibfl_sps-> error createTextMessage'.
    run deletesession in ptpsession no-error.
    return.
end.

/* сообщения из входящей очереди */
run createMessageConsumer in ptpsession (
    THIS-PROCEDURE,   /* данная процедура */
    "requestHandler",  /* внутренняя процедура */
    output consumerH) no-error.
if error-status:error then 
do:
    message 'ibfl_sps-> error createMessageConsumer'.
    run deletesession in ptpsession no-error.
    return.
end.

run receiveFromQueue in ptpsession ("FOLK", /* очередь входящих сообщений */
    ?,            /* не фильтруем */
    consumerH) no-error.   /* указатель на обработчик сообщений */
if error-status:error then 
do:
    message 'ibfl_sps-> error receiveFromQueue'.
    run deleteConsumer in ptpsession no-error.
    run deletesession in ptpsession no-error.
    return.
end.

/* Запускаем получение запросов */
run startReceiveMessages in ptpsession.

/* Обрабатываем запросы бесконечно */
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).

message "Процесс корректно завершен".

run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.


procedure requestHandler:
    define input parameter requestH as handle.
    define input parameter msgConsumerH as handle.
    define output parameter replyH as handle.

    define variable requestText as character    no-undo.
    define variable replyText   as character    no-undo.
    define variable long-replyText   as longchar    no-undo.
    define variable pRes        as integer no-undo.
    define variable v-mess as character no-undo.
    requestText = DYNAMIC-FUNCTION('getText':U IN requestH) no-error.
    hide message no-pause.
    if requestText = ? then requestText = ''.
    message string(time,"hh:mm:ss") + ' ' + requestText.
    if num-entries(requestText,"=") = 2 and entry(1,requestText,"=") = "qcommand" and trim(entry(2,requestText,"=")) <> '' then 
    do:
        run deleteMessage in requestH.
        if trim(entry(2,requestText,"=")) = "terminate" then v-terminate = yes.
    end.
    else 
    do:
       /* message "requestText = " + requestText.*/
        v-acc   = ''.
        v-phone = ''.
        v-idn   = ''.
        v-bank  = ''.
        v-cif   = ''.
        replyText = ''.
        v-begin-date = ''.
        v-end-date = ''.
        v-acc-from = ''.
        v-acc-to = ''.
        v-acc-comm = ''.
        v-amount = ''.
        v-amount-crc = ''.
        v-err = ''.
        s-err = ''.
        v-out = no.
        v-mess = ''.
        long-replyText = ''.
        id_rec = 0.
        if IsCloseDay() then WorkType = 0.
        else WorkType = 1.
                        
        v-type = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TYPE") no-error.
        if v-type = ? then v-type = ''.
        v-type = trim(v-type).
        v-acc = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ACCOUNT") no-error.
        if v-acc = ? then v-acc = ''.
        v-acc = trim(v-acc).
        v-phone = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "PHONE") no-error.
        if v-phone = ? then v-phone = ''.
        v-phone = trim(v-phone).
        v-idn = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "IDN") no-error.
        if v-idn = ? then v-idn = ''.
        v-idn = trim(v-idn).
        v-cif = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "CLIENT") no-error.
        if v-cif = ? then v-cif = ''.
        v-cif = trim(v-cif).
        
        v-acc-from = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ACCOUNT_FROM") no-error.
        if v-acc-from = ? then v-acc-from = ''.
        v-acc-from = trim(v-acc-from).
        v-acc-to = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ACCOUNT_TO") no-error.
        if v-acc-to = ? then v-acc-to = ''.
        v-acc-to = trim(v-acc-to).
        v-amount = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "AMOUNT") no-error.
        if v-amount = ? then v-amount = ''.
        v-amount = trim(v-amount).
        
        v-begin-date = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "BEGINDATE") no-error.
        if v-begin-date = ? then v-begin-date = ''.
        v-begin-date = trim(v-begin-date).
        
        v-end-date = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ENDDATE") no-error.
        if v-end-date = ? then v-end-date = ''.
        v-end-date = trim(v-end-date).
        
        v-acc-comm = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "COMMISSION_ACC") no-error.
        if v-acc-comm = ? then v-acc-comm = ''.
        v-acc-comm = trim(v-acc-comm).
        
        v-amount-crc = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "AMOUNT_CRC") no-error.
        if v-amount-crc = ? then v-amount-crc = ''.
        v-amount-crc = trim(v-amount-crc).
        
                         
                
        message 'v-type      =' + v-type.
        message 'v-acc       =' + v-acc.
        message 'v-phone     =' + v-phone.
        message 'v-idn       =' + v-idn.
        message 'v-cif       =' + v-cif. 
        message 'v-acc-from  =' + v-acc-from.
        message 'v-acc-to    =' + v-acc-to.
        message 'v-amount    =' + v-amount.
        message 'v-begin-date=' + v-begin-date.
        message 'v-end-date  =' + v-end-date.
        message 'v-acc-comm  =' + v-acc-comm.
        message 'v-amount-crc=' + v-amount-crc.
       
            
        if v-acc <> "" then v-bank = "txb" + substring(v-acc,19,2) no-error.
        else v-bank = entry(lookup(substring(v-cif,1,1),fs),fsb) no-error. 
        
         if v-bank <> ? and v-bank <> "" then
         do:
            if connected ("txb") then disconnect "txb".
            find first comm.txb where comm.txb.bank = v-bank and comm.txb.consolid no-lock no-error.
            if available comm.txb then 
            do:
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                /******************************************************************************/
                    
                    case v-type:
                     when "GetBalance" then do: /*баланс по счету*/
                        run ow_send("GetBalance","",v-acc,"","","","","","","",output replyText,output v-out).
                        if not v-out then do: s-err = replyText. v-err = "Ошибка обработки запроса!". end.
                        else message "ibfl_sps GetBalance-> " + replyText.
                     end.
                     when "GetStatement" then do: /**/
                        run ow_send("GetStatement","",v-acc,v-begin-date,v-end-date,"","","","","",output long-replyText,output v-out).
                        if not v-out then do: s-err = long-replyText. v-err = "Ошибка обработки запроса!". end.
                        else do:
                            define variable tmp as character.
                            define variable i as integer.
                            if length(long-replyText) > 1000 then do:
                               repeat i = 1 to length(long-replyText):
                                 tmp = substring(long-replyText,i,1000).
                                 message "ibfl_sps GetStatement-> " + tmp.
                                 i = i + 1000.  
                               end.     
                            end.
                            else do:
                                tmp = long-replyText.
                                message "ibfl_sps GetStatement-> " + tmp.
                            end.    
                        end. 
                     end.
                     when "check" then do: /*проверка данных пользователя при регистрации*/
                        if WorkType = 0 then v-err = v-message.
                        else do:
                          run ibfl_check(v-acc, v-phone, v-idn, output replyText, output v-err).
                          if v-err <> "" then do: s-err = v-err. v-err = "Неверные данные!". end.
                        end.  
                     end.
                     when "init" then do: /*инициализация пользователя ИБ*/
                        if WorkType = 0 then v-err = v-message.
                        else do:
                          run ibfl_init(v-cif, output replyText, output v-err).
                          if v-err <> "" then do: s-err = v-err. v-err = "Ошибка инициализации!". end.
                        end.  
                     end.
                     when "providers" then do: /*загрузка списка провайдеров комм-платежей*/
                        run ibfl_get_supp(v-cif, output long-replyText, output v-err).
                     end.
                     when "checkTransferOwn" then do: /*Проверка корректности документа перевода между своими счетами (в одной валюте)*/
                        run ibfl_Transfer(v-cif,v-acc-from,v-acc-to, v-amount,Base,v-type, output replyText, output v-err).
                        /*if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проверке документа!". end.*/
                     end.
                     when "doTransferOwn" then do: /*Проведение перевода между своими счетами (в одной валюте)*/
                        run CreateData(input WorkType,input requestText,output replyText).
                        if WorkType = 1 then do:
                          run ibfl_Transfer(v-cif,v-acc-from,v-acc-to, v-amount,Base,v-type, output replyText, output v-err).
                          run SaveResult(input replyText, input v-err).
                          if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проведении платежа!". end.
                        end. 
                     end.
                     when "checkConversionOwn" then do: /*Проверка корректности документа конвертации*/
                        run ibfl_Convertation(v-cif,v-acc-from,v-acc-to,v-acc-comm, v-amount,v-amount-crc,Base,v-type, output replyText, output v-err).
                        /*if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проверке документа!". end.*/
                     end.
                     when "doConversionOwn" then do: /*Проведение конвертации*/
                        run CreateData(input WorkType,input requestText,output replyText).
                        if WorkType = 1 then do:
                          run ibfl_Convertation(v-cif,v-acc-from,v-acc-to,v-acc-comm, v-amount,v-amount-crc,Base,v-type, output replyText, output v-err).
                          run SaveResult(input replyText, input v-err).
                          if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проведении платежа!". end.
                        end.  
                     end.
                     when "providerPaymentPrepare" then do: /*Проверка корректности документа коммунального платежа*/
                        run ibfl_Compay(v-cif,v-acc-from,v-amount,requestText,Base,v-type, output replyText, output v-err).
                        /*if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проверке документа!". end.*/
                     end.
                     when "providerPaymentCommit" then do: /*Проведение коммунального платежа*/
                        run CreateData(input WorkType,input requestText,output replyText).
                        if WorkType = 1 then do:
                          run ibfl_Compay(v-cif,v-acc-from,v-amount,requestText,Base,v-type, output replyText, output v-err).
                          run SaveResult(input replyText, input v-err).
                          if v-err <> "" then do: s-err = v-err. v-err = "Ошибка при проведении платежа!". end.
                        end.  
                     end.
                     when "UpdateData" then do: /*обновление данных клиента*/
                        run ibfl_UpdateData(v-cif,v-phone,output v-err).
                        if v-err <> "" then do: s-err = v-err. v-err = "Ошибка обработки запроса!". end.
                     end.
                     otherwise do:
                         v-err = 'Неизвестный тип операции '.
                         message v-err + v-type.
                         s-err = v-err + v-type.
                     end.
                    end case.
                /******************************************************************************/
                if connected ("txb") then disconnect "txb".
            end.
            else 
            do:
                v-err = "Ошибка определения кода филиала ".
                message v-err + " bank = " + v-bank.
                s-err = v-err + " bank = " + v-bank.
            end.
         end.     
         else v-err = "Отсутствует информация о клиенте во входящем сообщении".
         
         
        /* создаем ответное сообщение */
        run deleteMessage in requestH.
        replyH = replyMessage.
        run reset in replyH.
        run clearBody in replyH.
        run clearProperties in replyH.
        
        if v-err <> '' then 
        do:
                   
        v-mess ='TYPE           =' + v-type + '~n' +
                'ACCOUNT        =' + v-acc + '~n' +
                'PHONE          =' + v-phone + '~n' +
                'IDN            =' + v-idn + '~n' +
                'CLIENT         =' + v-cif + '~n' + 
                'ACCOUNT_FROM   =' + v-acc-from + '~n' +
                'ACCOUNT_TO     =' + v-acc-to + '~n' +
                'COMMISSION_ACC =' + v-acc-comm + '~n' +
                'AMOUNT         =' + v-amount + '~n' +
                'AMOUNT_CRC     =' + v-amount-crc + '~n' +
                'BEGINDATE      =' + v-begin-date + '~n' +
                'ENDDATE        =' + v-end-date + '~n'.
                
                if s-err = '' then v-mess = v-mess + "~n" + v-err.
                else v-mess = v-mess + "~n" + s-err.
                run mail("IBFL_service@fortebank.com", "superman@metrocombank.kz", "Ошибка ИБФЛ",v-mess, "1", "","" ).
            
            run setStringProperty in replyH("ERROR", v-err).
        end.
        else do:
            
            if long-replyText <> '' then run setLongText in replyH( long-replyText).
            else  run appendText in replyH (replyText).
        end. 
        message "--------------------------------------------------------------------------------------------------------------".
       
    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.

procedure CreateData:
  define input parameter wt as integer.  
  define input parameter requestText as char no-undo. 
  define output parameter replyText as char no-undo.  
  do transaction:
      create comm.ibfl_doc.
        id_rec = next-value(ibfl_id).
        comm.ibfl_doc.id = id_rec.
        comm.ibfl_doc.v-type = v-type.
        comm.ibfl_doc.v-acc = v-acc.
        comm.ibfl_doc.v-phone = v-phone.
        comm.ibfl_doc.v-idn = v-idn.
        comm.ibfl_doc.cif = v-cif.
        comm.ibfl_doc.v-acc-from = v-acc-from.
        comm.ibfl_doc.v-acc-to = v-acc-to.
        comm.ibfl_doc.v-amount = decimal(v-amount).
        comm.ibfl_doc.v-acc-comm = v-acc-comm.
        comm.ibfl_doc.v-amount-crc = v-amount-crc.
        comm.ibfl_doc.bank = v-bank.
        comm.ibfl_doc.v-date = today.
        comm.ibfl_doc.v-time = time.
        comm.ibfl_doc.state = wt.
        comm.ibfl_doc.request = requestText.
        replyText = "<Data><Trx>0</Trx><Time>" + string(time,"HH:MM:SS")+ "</Time></Data>".
  end. /*transaction*/
  find last comm.ibfl_doc no-lock no-error.
end procedure.

procedure SaveResult:
    def input parameter replyText as char no-undo.
    def input parameter v-err as char no-undo.
    define buffer b-ibfl for comm.ibfl_doc.
           do transaction:  
            find first b-ibfl where b-ibfl.id = id_rec exclusive-lock.
            if available b-ibfl then do:
              if v-err <> '' then do:
                b-ibfl.state = 3. /*Ошибка*/
                b-ibfl.reply = v-err.
              end.  
              else do:
               b-ibfl.state = 2. /*OK*/
               b-ibfl.reply = replyText.
               if GetParamValueOne(replyText,"Trx") <> "" then b-ibfl.trx = integer(GetParamValueOne(replyText,"Trx")).
              end. 
              b-ibfl.v-date2 = today.
              b-ibfl.v-time2 = time.
              release b-ibfl.
            end.    
          end. /*transaction*/  
end procedure.

