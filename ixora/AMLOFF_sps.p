/* AMLOFF_sps.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Обработка сообщений от AML по принятым оффлайн-операциям
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
        29/06/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        07/07/2010 madiyar - обработка ошибок соединения
        12/07/2010 madiyar - коннект к боевому сонику
        17/07/2010 madiyar - корректное завершение работы процесса
        19/07/2010 madiyar - запись в лог о корректном завершении работы процесса
        22/07/2010 galina - находим запись со статусом rcvd
        26/08/2010 madiyar - перекомпиляция
        18/11/2010 madiyar - отправка информации по удаленным операциям
*/

/*
def var nmess as integer no-undo.
nmess = 0.
*/

{srvcheck.i}

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.

def var v-terminate as logi no-undo.
v-terminate = no.

/* Создаем объект сессии */
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.1.22:2507").
else run setBrokerURL in ptpsession ("tcp://172.16.1.12:2507").
run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession no-error.

if error-status:error then do:
    run savelog('aml','AMLOFF_sps-> error beginSession').
    message 'AMLOFF_sps-> error beginSession'.
    return.
end.

/* сообщения из входящей очереди */
run createMessageConsumer in ptpsession (
                              THIS-PROCEDURE,   /* данная процедура */
                             "requestHandler",  /* внутренняя процедура */
                              output consumerH) no-error.
if error-status:error then do:
    run savelog('aml','AMLOFF_sps-> error createMessageConsumer').
    message 'AMLOFF_sps-> error createMessageConsumer'.
    run deletesession in ptpsession no-error.
    return.
end.

run receiveFromQueue in ptpsession ("AMLOfflineOutQ",   /* очередь входящих сообщений */
                                     ?,                 /* не фильтруем */
                                     consumerH          /* указатель на обработчик сообщений */
                                   ) no-error.
if error-status:error then do:
    run savelog('aml','AMLOFF_sps-> error receiveFromQueue').
    message 'AMLOFF_sps-> error receiveFromQueue'.
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

    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var msgText as char no-undo.
    def var pNames as char no-undo.

    def var pBank as char no-undo init ''.
    def var pOperId as char no-undo init ''.
    def var pAMLId as char no-undo init ''.
    def var pSts as char no-undo init ''.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:
        pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).

        /*
        hide message no-pause.
        message pNames.
        */

        if lookup("bank",pNames) > 0 then pBank = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "bank").
        if lookup("bankOperationID",pNames) > 0 then pOperId = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "bankOperationID").
        if lookup("AMLId",pNames) > 0 then pAMLId = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "AMLId").
        if lookup("sts",pNames) > 0 then pSts = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "sts").

        /*
        hide message no-pause.
        message "bank=" + pBank + " operId=" + pOperId + " AMLId=" + pAMLId + " sts=" + pSts.
        pause.
        */

        run deleteMessage in requestH.

        /*
        nmess = nmess + 1.
        if (nmess mod 50) = 0 then do:
            hide message no-pause.
            message nmess.
        end.
        */

        do transaction:
            find first amloffline where amloffline.bank = pBank and amloffline.operCode = pOperId and amloffline.sts = "sent" exclusive-lock no-error.
            if avail amloffline then do:
                if pSts = "1" then do:
                    if amloffline.issueDBID = -1 then amloffline.sts = "del".
                    else amloffline.sts = "rcvd".
                end.
                else amloffline.sts = "rcve". /* rem!!!! */
                amloffline.gdt = today.
                amloffline.gtim = time.
                amloffline.idAML = pAMLId.
                find current amloffline no-lock.
            end.
        end.
    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.

