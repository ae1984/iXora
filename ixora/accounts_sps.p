/* accounts_sps
 * MODULE
        Возвращает данные по счету
 * DESCRIPTION
        Описание программы
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
        13.12.2012 e.berdibekov
 * BASES
        BANK TXB
 * CHANGES
        24/01/2013 madiyar - учетка SonicClient
        24.04.2013 evseev - tz1720
        17.05.2012 yerganat - логирование менеджера если счет клиента указан неправельно
        07.11.2013 yerganat - интеграция Интернет Банкинга для проверки социальных Swift файлов
*/

{srvcheck.i}
{qps.i}

define variable pAccount       as char.


/*define variable q_name         as character init "accounts_abs_queue".*/

define variable ptpsession     as handle.
define variable consumerH      as handle.
define variable replyMessage   as handle.

define variable v-terminate    as logical no-undo.

define variable r-des          as char.
define variable r-code         as integer.


define variable id_ofc         as char.
define variable v-user-name as char no-undo.

def var brokerhost as char no-undo.
def var brokerport as integer no-undo.
def var myQ as char no-undo.
find first qproc where qproc.pid = m_pid no-lock no-error.
if avail qproc then do:
    brokerhost = trim(qproc.sonichost).
    brokerport = qproc.sonicport.
    myQ = trim(qproc.q[1]).
end.
else do:
    message 'ACCOUNTS_sps-> error finding registered process'.
    return.
end.

if (brokerhost = '') or (brokerport = 0) or (myQ = '') then do:
    message 'ACCOUNTS_sps-> incorrect sonic connection information'.
    return.
end.


v-terminate = no.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

/* Для иксоры */

/*if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").*/
if isProductionServer() then do:
    run setBrokerURL in ptpsession ("tcp://" + brokerhost + ":" + string(brokerport)).
end. else do:
    if  brokerhost = '172.16.3.5' then
        run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").
    else
        run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").
end.

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginSession in ptpsession.

run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (this-procedure, "replyhandler", output consumerH).
run receiveFromQueue in ptpsession (myQ, ?, consumerH).

run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).

message "Процесс корректно завершен".

run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession no-error.


/*******************************/
function inWait returns logical.
    return not(v-terminate).
end.
/*******************************/


/***********************************************************************************/
procedure replyhandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var msgText as char no-undo.

    r-des=''.
    r-code=0.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH) no-error.

    if num-entries(msgText,"=") = 2 and
        entry(1,msgText,"=") = "qcommand" and
        trim(entry(2,msgText,"=")) <> '' then do:

        run deleteMessage in requestH.

        if trim(entry(2,msgText,"=")) = "terminate" then
            v-terminate = yes.

    end.
    else do:

        pAccount = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "account").
        id_ofc = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ID_OFC").

        hide message no-pause.
        message string(today).
        message string(time,'HH:MM:SS').
        message "********************************************************".
        message "[ account =" pAccount "]".
        message "********************************************************".


        if pAccount <> ? and pAccount <> '' then do:
            find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.

            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

            if avail comm.txb and connected ("txb") then do:
                run account_info(pAccount, replyMessage, output replyH).

                run setIntProperty in replyH("ERRCODE",r-code).
                run setStringProperty in replyH("ERRDESC",r-des).
            end. else do:

                find first ofc where ofc.ofc = id_ofc  no-lock no-error.
                if avail ofc then do:
                    v-user-name = ofc.name.
                end.

                message "Отсутствует счет клиента." skip.
                message "Менеджер : " v-user-name  " id: " id_ofc skip.

                replyH = replyMessage.
                r-code = 1.
                r-des = 'Отсутствует счет клиента.'.
                run setIntProperty in replyH("ERRCODE",r-code).
                run setStringProperty in replyH("ERRDESC",r-des).
                run setText in replyH ("").
            end.

        end. else do:

            replyH = replyMessage.
            r-code = 1.
            r-des = 'Счет не найден'.
            run setIntProperty in replyH("ERRCODE",r-code).
            run setStringProperty in replyH("ERRDESC",r-des).
            run setText in replyH ("").
        end.

        message "********************************************************".
        /*run sendToQueue in ptpsession (q_name, replyH, ?, ?, ?).*/
        run deleteMessage in requestH.
    end.

end procedure.
/***********************************************************************************/
