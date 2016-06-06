/* RME_sps.p
 * MODULE
        Процессы Sonic
 * DESCRIPTION
        Чтение сообщений из очереди RME
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
        13/08/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{qps.i}

function Timestamp2DateTime returns char (input ts as deci).
    def var res as char no-undo.
    def var dt as date no-undo.
    def var tm as integer no-undo. /* секунды от полуночи */
    def var ms as integer no-undo. /* миллисекунды */
    def var ts64 as int64 no-undo.

    ts64 = round(ts, 0).

    ms = ts64 modulo 1000.
    ts64 = round((ts64 - ms) / 1000, 0).

    tm = ts64 modulo 86400.
    ts64 = round((ts64 - tm) / 86400, 0).

    dt = 01/01/1970 + ts64.

    res = string(dt,"99/99/9999") + ' ' + string(tm,"hh:mm:ss") + '.' + string(ms).

    return res.
end function.


define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.

def var v-terminate as logi no-undo.
v-terminate = no.

def stream qq.
def var i as integer no-undo.

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
    message 'RME_sps-> error finding registered process'.
    return.
end.

if (brokerhost = '') or (brokerport = 0) or (myQ = '') then do:
    message 'RME_sps-> incorrect sonic connection information'.
    return.
end.


/* Создаем объект сессии */
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
run setBrokerURL in ptpsession ("tcp://" + brokerhost + ":" + string(brokerport)).
run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').

run beginSession in ptpsession no-error.
if error-status:error then do:
    message 'RME_sps-> error beginSession'.
    return.
end.

/* сообщения из входящей очереди */
run createMessageConsumer in ptpsession (
                              THIS-PROCEDURE,   /* данная процедура */
                             "requestHandler",  /* внутренняя процедура */
                              output consumerH) no-error.
if error-status:error then do:
    message 'RME_sps-> error createMessageConsumer'.
    run deletesession in ptpsession no-error.
    return.
end.

run receiveFromQueue in ptpsession (myQ,   /* очередь входящих сообщений */
                                    ?,                 /* не фильтруем */
                                    consumerH          /* указатель на обработчик сообщений */
                                   ) no-error.
if error-status:error then do:
    message 'RME_sps-> error receiveFromQueue'.
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
    def var msgText1 as char no-undo.
    def var pNames as char no-undo.
    def var pType as char no-undo.
    def var pValue as char no-undo.
    def var pFile as char no-undo.
    def var hMsgDest as char no-undo init ''.
    def var hMsgDeliveryMode as char no-undo init ''.
    def var hMsgId as char no-undo init ''.
    def var hMsgTimestamp as deci no-undo init 0.
    def var hMsgCorrelationID as char no-undo init ''.
    def var hMsgReplyTo as char no-undo init ''.
    def var hMsgRedelivered as logi no-undo init false.
    def var hMsgType as char no-undo init ''.
    def var hMsgExpiration as deci no-undo init 0.
    def var hMsgPriority as integer no-undo init 0.
    def var suffix as char no-undo.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH) no-error.
    if error-status:error then do:
        msgText = DYNAMIC-FUNCTION('getTextPartByIndex':U IN requestH, 0, output msgText1) no-error.
    end.

    if msgText = ? then msgText = ''.
    if msgText1 = ? then msgText1 = ''.

    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:
        hMsgId = DYNAMIC-FUNCTION('getJMSMessageID':U IN requestH).
        if trim(hMsgId) <> '' then do:
            if length(hMsgId) < 7 then suffix = hMsgId.
            else suffix = substring(hMsgId,length(hMsgId) - 6,7).
        end.
        pFile = "msg_" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "_" + replace(string(time,"hh:mm:ss"),":","") + "_" + suffix + ".htm".
        output stream qq to value("/data/import/sonic/RME/" + pFile).

        put stream qq unformatted "<html><body><pre>" skip.
        put stream qq unformatted skip(1).
        put stream qq unformatted "[Headers]" skip.
        hMsgDest = DYNAMIC-FUNCTION('getJMSDestination':U IN requestH).
        put stream qq unformatted "JMSDestination=" if hMsgDest <> ? then hMsgDest else '' skip.
        hMsgDeliveryMode = DYNAMIC-FUNCTION('getJMSDeliveryMode':U IN requestH).
        put stream qq unformatted "JMSDeliveryMode=" if hMsgDeliveryMode <> ? then hMsgDeliveryMode else '' skip.
        put stream qq unformatted "JMSMessageID=" if hMsgId <> ? then hMsgId else '' skip.
        hMsgTimestamp = DYNAMIC-FUNCTION('getJMSTimestamp':U IN requestH).
        put stream qq unformatted "JMSTimestamp=" if hMsgTimestamp <> ? then Timestamp2DateTime(hMsgTimestamp) else '' skip.
        hMsgCorrelationID = DYNAMIC-FUNCTION('getJMSCorrelationID':U IN requestH).
        put stream qq unformatted "JMSCorrelationID=" if hMsgCorrelationID <> ? then hMsgCorrelationID else '' skip.
        hMsgReplyTo = DYNAMIC-FUNCTION('getJMSReplyTo':U IN requestH).
        put stream qq unformatted "JMSReplyTo=" if hMsgReplyTo <> ? then hMsgReplyTo else '' skip.
        hMsgRedelivered = DYNAMIC-FUNCTION('getJMSRedelivered':U IN requestH).
        put stream qq unformatted "JMSRedelivered=" if hMsgRedelivered <> ? then string(hMsgRedelivered) else '' skip.
        hMsgType = DYNAMIC-FUNCTION('getJMSType':U IN requestH).
        put stream qq unformatted "JMSType=" if hMsgType <> ? then hMsgType else '' skip.
        hMsgExpiration = DYNAMIC-FUNCTION('getJMSExpiration':U IN requestH).
        put stream qq unformatted "JMSExpiration=" if hMsgExpiration <> ? then Timestamp2DateTime(hMsgExpiration) else '' skip.
        hMsgPriority = DYNAMIC-FUNCTION('getJMSPriority':U IN requestH).
        put stream qq unformatted "JMSPriority=" if hMsgPriority <> ? then string(hMsgPriority) else '' skip.

        put stream qq unformatted skip(1).

        put stream qq unformatted "[Properties]" skip.
        pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        do i = 1 to num-entries(pNames):
            pValue = ''.
            pType = DYNAMIC-FUNCTION('getPropertyType':U IN requestH, entry(i,pNames)) no-error.
            if pType = ? then pType = "error defining property type".
            case pType:
                when "string" then pValue = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, entry(i,pNames)).
                when "byte" or when "short" or when "int" then pValue = string(DYNAMIC-FUNCTION('getIntProperty':U IN requestH, entry(i,pNames))).
                when "float" or when "double" or when "long" then pValue = string(DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, entry(i,pNames))).
                when "boolean" then pValue = string(DYNAMIC-FUNCTION('getLogicalProperty':U IN requestH, entry(i,pNames))).
                otherwise do:
                    if pType <> "error defining property type" then message 'RME_sps-> unknown property type - ' + pType.
                end.
            end case.
            if pValue = ? then pValue = ''.
            put stream qq unformatted entry(i,pNames) + "(" + pType + ")=" + pValue skip.
        end.

        put stream qq unformatted skip(1).

        put stream qq unformatted "[Message Body - msgText]" skip.
        put stream qq unformatted msgText skip.
        put stream qq unformatted skip(1).
        put stream qq unformatted "[Message Body - msgText1]" skip.
        put stream qq unformatted msgText1 skip.

        put stream qq unformatted skip(1).
        put stream qq unformatted "</pre></body></html>" skip.

        output stream qq close.

        run deleteMessage in requestH.

        run mail("id00020@metrocombank.kz",
                 "METROCOMBANK <abpk@metrocombank.kz>",
                 "sonic RME",
                 "JMSMessageID=" + (if hMsgId <> ? then hMsgId else '') + "\nJMSDestination=" + (if hMsgDest <> ? then hMsgDest else '') + "\nJMSReplyTo=" + (if hMsgReplyTo <> ? then hMsgReplyTo else ''),
                 "1",
                 "",
                 "/data/import/sonic/RME/" + pFile).

    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.

