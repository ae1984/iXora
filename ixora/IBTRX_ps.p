/* ibfl_trx.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        процесс ПС для проведения документов ИБФЛ
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
        05/11/2013 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}
{xmlParser.i}

function IsCloseDay returns logical ().
    find first comm.pksysc where comm.pksysc.sysc = "DAYCLOSE" no-lock no-error.
    if available comm.pksysc then return comm.pksysc.loval.
    else return true. 
end function.

if IsCloseDay() then return.

define    variable      fs           as character   no-undo init "A,B,C,D,E,F,H,K,L,M,N,O,P,Q,R,S,T".
define    variable      fsb          as character   no-undo init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".


define variable v-type       as character   no-undo.
define variable v-acc        as character   no-undo.
define variable v-phone      as character   no-undo.
define variable v-idn        as character   no-undo.
define variable v-bank       as character   no-undo.
define variable v-cif        as character   no-undo.
define variable v-err        as character   no-undo.

define variable v-acc-from as character no-undo.
define variable v-acc-to as character no-undo.
define variable v-amount as character no-undo.
define variable v-begin-date as character no-undo.
define variable v-end-date as character no-undo.
define variable v-acc-comm as character no-undo.
define variable v-amount-crc as character no-undo.
define variable requestText as character    no-undo.
define variable replyText   as character    no-undo.
define variable v-mess as character no-undo.
define variable id_rec as integer.
define variable v-trx as integer.

define buffer b-ibfl for comm.ibfl_doc.

/*message string(today,"99/99/9999") " " string(time, "hh:mm:ss") " Start IBTRX".*/ 

for each comm.ibfl_doc where comm.ibfl_doc.state = 0 no-lock:
        
        id_rec = comm.ibfl_doc.id.
        v-type = comm.ibfl_doc.v-type.
        v-acc = comm.ibfl_doc.v-acc.
        v-phone = comm.ibfl_doc.v-phone.
        v-idn = comm.ibfl_doc.v-idn.
        v-cif = comm.ibfl_doc.cif.
        v-acc-from = comm.ibfl_doc.v-acc-from.
        v-acc-to = comm.ibfl_doc.v-acc-to.
        v-amount = string(comm.ibfl_doc.v-amount,">>>>>>>>>>>>>>>>9.99").
        v-acc-comm = comm.ibfl_doc.v-acc-comm.
        v-amount-crc = comm.ibfl_doc.v-amount-crc.
        v-bank = comm.ibfl_doc.bank.
        requestText = comm.ibfl_doc.request.
        message '--------------------------------------------------------------------------------------------------'.
        message string(today,"99/99/9999") " " string(time, "hh:mm:ss").
        message 'v-id        =' + string(id_rec).
        message 'v-bank      =' + v-bank.
        message 'v-type      =' + v-type.
        message 'v-acc       =' + v-acc.
        message 'v-phone     =' + v-phone.
        message 'v-idn       =' + v-idn.
        message 'v-cif       =' + v-cif. 
        message 'v-acc-from  =' + v-acc-from.
        message 'v-acc-to    =' + v-acc-to.
        message 'v-amount    =' + v-amount.
        message 'v-acc-comm  =' + v-acc-comm.
        message 'v-amount-crc=' + v-amount-crc. 
        message 'requestText =' + requestText. 
        
        
        message "Update Status id_rec = " + string(id_rec).
        find first b-ibfl where b-ibfl.id = id_rec and b-ibfl.state = 0 exclusive-lock no-error no-wait.
        if not available b-ibfl then do: message "Record # " string(id_rec) "is locked...". next. end.
            
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
                     when "doTransferOwn" then do: /*Проведение перевода между своими счетами (в одной валюте)*/
                          run ibfl_Transfer(v-cif,v-acc-from,v-acc-to, v-amount,Base,v-type, output replyText, output v-err).
                     end.
                     when "doConversionOwn" then do: /*Проведение конвертации*/
                          run ibfl_Convertation(v-cif,v-acc-from,v-acc-to,v-acc-comm, v-amount,v-amount-crc,Base,v-type, output replyText, output v-err).
                     end.
                     when "providerPaymentCommit" then do: /*Проведение коммунального платежа*/
                          run ibfl_Compay(v-cif,v-acc-from,v-amount,requestText,Base,v-type, output replyText, output v-err).
                     end.
                     otherwise do:
                         v-err = 'Неизвестный тип операции '.
                         message v-err + v-type.
                     end.
                    end case.
                /******************************************************************************/
                if connected ("txb") then disconnect "txb".
            end.
            else 
            do:
                v-err = "Ошибка определения кода филиала ".
                message v-err + " bank = " + v-bank.
            end.
         end.     
         else v-err = "Отсутствует информация о клиенте во входящем сообщении".
        
        
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
                
                v-mess = v-mess + "~n" + v-err.
                run mail("IBFL_service@fortebank.com", "superman@metrocombank.kz", "Ошибка формирование транзакции ИБФЛ",v-mess, "1", "","" ).
            
        end.
         /*Все ОК, сохраняем номер транзакции*/
          
            
              if v-err <> '' then do:
                b-ibfl.state = 3.
                b-ibfl.reply = v-err.
                message "Result FAIL (" + v-err + ")".
              end.  
              else do:
               b-ibfl.state = 2.
               b-ibfl.reply = replyText.
               if GetParamValueOne(replyText,"Trx") <> "" then b-ibfl.trx = integer(GetParamValueOne(replyText,"Trx")).
               message "Result OK (" + string(b-ibfl.trx,"9999999") + ")".
              end. 
              b-ibfl.v-date2 = today.
              b-ibfl.v-time2 = time.
              release b-ibfl.
            
             
           
            
end.
    


