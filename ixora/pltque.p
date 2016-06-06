/* pltque.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
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
        BANK COMM IB
 * AUTHOR
       19/05/2010 id00004
 * CHANGES
       22/07/2010 id00004 добавил корректное завершение процессов
       09/008/2010 id00004 добавил контроль списания средств(разрешен только 1 платеж за сертификат)
       18/11/2010 id00004 запрос остатка по счету
       13/10/2010 id00004 повторный раз сумма списывается вручную если прошло < 90 мес
       04/10/2011 id00004 повторный раз сумма списывается автоматически по распоряжению руководства.

*/


{srvcheck.i}

def buffer bwpay for wpay.
define variable v-option as char.
define variable rcod as char.
define variable rdes as char.
define variable rstatus as char.

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.

def var v-terminate as logi no-undo.
v-terminate = no.

v-option = "0" .
rcod = "0".
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").

run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').

run beginSession in ptpsession.
run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (
                             THIS-PROCEDURE,
                             "requestHandler",
                              output consumerH).
run receiveFromQueue in ptpsession ("CERTIFICATE_PAYMENT",

/*run receiveFromQueue in ptpsession ("test",   */
                                     ?,
                                     consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Процесс корректно завершен".

run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.


procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var pNames as char no-undo.
    def var pExtid as char no-undo.
    def var pBic as char no-undo.
    def var pAccount as char no-undo.
    def var pValue as char no-undo.
    def var pInvoice as char no-undo.
    def var msgText as char no-undo.
    def var AccOst  as char  no-undo.
    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:


    pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).

    hide message no-pause.

    if lookup("EXT_ID",pNames)   > 0 then pExtid   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "EXT_ID").
    if lookup("BIC",pNames)      > 0 then pBic     = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "BIC").
    if lookup("ACCOUNT",pNames)  > 0 then pAccount = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ACCOUNT").
    if lookup("CA_INVOICE_NUMBER",pNames)  > 0 then pInvoice = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "CA_INVOICE_NUMBER").

    pValue = DYNAMIC-FUNCTION('getTextSegment':U IN requestH).
    replyH = replyMessage.

    run deleteMessage in requestH.

      if connected ("txb") then disconnect "txb".


       find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.
       if not avail comm.txb then do:
          run setText in replyH ("ERROR: Клиент не найден").
          return.
       end.




/*ЗАГЛУШКА если по каким либо причинам надо сделать чтобы не снялись средства за выпуск сертификата то раскомментить это*/
/*
    if pValue = "START_PAYMENT_TRANSACTION" then do:
       run setText in replyH ("OK").
          return.
    end.

    if pValue = "FINISH_PAYMENT_TRANSACTION" then do:
       run setText in replyH ("OK").
       return.
    end.  */

/*test ЗАГЛУШКА потом закомментим*/

    if pValue = "GET_ACCOUNT_BALANCE" then do:
       if connected ("txb") then disconnect "txb".
       connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).


       run pltque2(string(substring(pAccount, 1, 20)),
                   output rcod,
                   output rdes).


       if rcod = "0" then do:
          run setText in replyH ("ERROR: " + rdes).

          return.
       end.
       else do:


          if decimal(rdes) < 0 then AccOst  = "Нет доступных средств". else  AccOst  = replace(trim(string(decimal(rdes),"z,zzz,zzz,zz9.99-")),","," ") .
          run setText in replyH (AccOst) .

          return.
       end.
    end.





  /*Проверка списывалась ли сумма за последние 90 дней*/
/*
  find last wpay where wpay.aaa = pAccount and  wpay.cif =  pExtid no-lock no-error.
  if avail wpay then do:
     if (pValue = "START_PAYMENT_TRANSACTION" or pValue = "FINISH_PAYMENT_TRANSACTION") then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run pltque3(string(wpay.sts), output rstatus).
        if connected ("txb") then disconnect "txb".

        if rstatus = 'yes' then do:
           run setText in replyH ("OK").
           return.
        end.
     end.
  end.
*/
/* END Проверка списывалась ли сумма за последние 90 дней */





    /*Проверяем можно ли списать сумму*/
    if pValue = "START_PAYMENT_TRANSACTION" then do:

       if connected ("txb") then disconnect "txb".
       connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

       run pltque1(string(pExtid),
                   string(pAccount),
                   output rcod,
                   output rdes).
       if rcod = "0" then do:

          run setText in replyH ("ERROR: " + rdes).
          return.
       end.
       else do:

          run setText in replyH ("OK").
          return.
       end.
    end.


    /*Списываем сумму*/
    if pValue = "FINISH_PAYMENT_TRANSACTION" then do:
/*message pExtid  pAccount pInvoice  comm.txb.bank.
  pause 333. */
/*       find last wpay where wpay.aaa = pAccount and  wpay.txb = txb.bank no-lock no-error.
       if avail wpay then do:
          run setText in replyH ("Error: Комиссия по данному счету уже была списана ").
          return.
       end.
       else  */
do:
            release wpay.
do transaction:
            create wpay.
                   wpay.cif =  pExtid.
                   wpay.aaa =  pAccount.
                   wpay.txb =  comm.txb.bank.
                   wpay.rem =  pInvoice.
                   wpay.pay =  "0".
                   release wpay.

end .

pause 4.




            find last wpay where wpay.aaa = pAccount and  wpay.txb = comm.txb.bank and wpay.pay = "1" no-lock no-error.

            if avail wpay then do:
               run setText in replyH ("OK").
              run mail("denis@metrobank.kz", "PLATEG-NETBANK <netbank@metrocombank.kz>", "Произведена оплата за Cертификат" , "Номер заказа " + pInvoice , "", "","").
              run mail("anuar.tursunbayev@metrocombank.kz", "PLATEG-NETBANK <netbank@metrocombank.kz>", "Произведена оплата за Cертификат" , "Номер заказа " + pInvoice , "", "","").
            end.
            else do:
               run setText in replyH ("ERROR: Ошибка при создании платежа в Ixora").
            end.
       end.
    end.
   end.
end.


function inWait returns logical.
   return not(v-terminate).
end.
