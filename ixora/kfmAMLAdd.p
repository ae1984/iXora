/* kfmAMLAdd.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Сервис для возврата доп. инфо по клиенту в AML
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
        17/07/2010 madiyar - корректное завершение работы процесса
        19/07/2010 madiyar - запись в лог о корректном завершении работы процесса
        22/10/2010 madiyar - мелкое исправление
*/

{srvcheck.i}

def var v-terminate as logi no-undo.
v-terminate = no.

def new shared temp-table t-part no-undo
  field pId as integer
  field pName as char
  field pValue as char
  field pType as char
  index idx is primary pId.

def new shared temp-table t-founder no-undo
  field pId as integer
  field pName as char
  field pValue as char
  field pType as char
  index idx is primary pId.

function stripXMLTags returns char (input str as char).
    def var res as char no-undo.
    def var ii as integer no-undo.
    do ii = 1 to length(str):
        if asc(substring(str,ii,1)) <> 22 then res = res + substring(str,ii,1).
    end.
    res = replace(res,'<','').
    res = replace(res,'>','').
    res = replace(res,'&','').
    res = replace(res,'№','N').
    res = replace(res,'«','"').
    res = replace(res,'»','"').
    return res.
end function.

procedure createPParam:
    def input parameter vName as char no-undo.
    def input parameter vValue as char no-undo.
    def input parameter vType as char no-undo.

    def var vId as integer no-undo.

    find last t-part no-lock no-error.
    if avail t-part then vId = t-part.pId + 1.
    else vId = 1.

    if vType = 'c' then vValue = stripXMLTags(vValue).

    create t-part.
    assign t-part.pId = vId
           t-part.pName = vName
           t-part.pValue = vValue
           t-part.pType = vType.
end procedure.

procedure parseAddress.
    def input parameter p-fm as char no-undo.
    def input parameter p-suffix as char no-undo.
    def input parameter p-dataValue as char no-undo.

    def var v-country2 as char no-undo init ''.
    def var v-country_cod as char no-undo init '0'.
    def var v-region as char no-undo init ''.
    def var v-city as char no-undo init ''.
    def var v-street as char no-undo init ''.
    def var v-house as char no-undo init ''.
    def var v-office as char no-undo init ''.
    def var v-index  as char no-undo init '0'.

    if num-entries(p-dataValue) = 7 then do:
        v-country2 = entry(1,p-dataValue).
        if num-entries(v-country2,"(") = 2 then v-country_cod = substr(entry(2,entry(1,p-dataValue),"("),1,2).
        assign v-region = entry(2,p-dataValue)
               v-city = entry(3,p-dataValue)
               v-street = entry(4,p-dataValue)
               v-house = entry(5,p-dataValue)
               v-office = entry(6,p-dataValue)
               v-index = entry(7,p-dataValue).

        find first code-st where code-st.code = v-country_cod no-lock no-error.
        if avail code-st then v-country_cod = code-st.cod-ch.

        if p-fm begins "founder" then do:
            run createFParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
            run createFParam(p-fm + "Area" + p-suffix, '', 'c').
            run createFParam(p-fm + "Region" + p-suffix, v-region, 'c').
            run createFParam(p-fm + "City" + p-suffix, v-city, 'c').
            run createFParam(p-fm + "Street" + p-suffix, v-street, 'c').
            run createFParam(p-fm + "House" + p-suffix, v-house, 'c').
            run createFParam(p-fm + "Office" + p-suffix, v-office, 'c').
            run createFParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
        end.
        else if p-fm begins "member" then do:
            run createPParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
            run createPParam(p-fm + "Area" + p-suffix, '', 'c').
            run createPParam(p-fm + "Region" + p-suffix, v-region, 'c').
            run createPParam(p-fm + "City" + p-suffix, v-city, 'c').
            run createPParam(p-fm + "Street" + p-suffix, v-street, 'c').
            run createPParam(p-fm + "House" + p-suffix, v-house, 'c').
            run createPParam(p-fm + "Office" + p-suffix, v-office, 'c').
            run createPParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
        end.

    end.
end procedure. /* parseAddress */

def var i as integer no-undo.
def var v-str as char no-undo.
def var v-str2 as char no-undo.
def var memberResCountryCode as char no-undo.


def var v-txb as char no-undo.
def var fs as char no-undo init "A,B,C,D,E,F,H,K,L,M,N,O,P,Q,R,S,T".
def var fsb as char no-undo init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16|TXB00".

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.

/* Создаем объект сессии */
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.1.22:2507").
else run setBrokerURL in ptpsession ("tcp://172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").

run beginSession in ptpsession no-error.
if error-status:error then do:
    run savelog('aml','kfmAMLAdd-> error beginSession').
    message 'kfmAMLAdd-> error beginSession'.
    return.
end.

/*message "---===copy=" + m_copy + "===---".*/
/*message "1".*/

/* Для всех ответных сообщений используем один объект */
run createTextMessage in ptpsession (output replyMessage) no-error.
if error-status:error then do:
    run savelog('aml','kfmAMLAdd-> error createTextMessage').
    message 'kfmAMLAdd-> error createTextMessage'.
    run deletesession in ptpsession no-error.
    return.
end.

/* сообщения из входящей очереди */
run createMessageConsumer in ptpsession (
                              THIS-PROCEDURE,   /* данная процедура */
                             "requestHandler",  /* внутренняя процедура */
                              output consumerH) no-error.
if error-status:error then do:
    run savelog('aml','kfmAMLAdd-> error createMessageConsumer').
    message 'kfmAMLAdd-> error createMessageConsumer'.
    run deletesession in ptpsession no-error.
    return.
end.

run receiveFromQueue in ptpsession ("AMLAddInfoQ", /* очередь входящих сообщений */
                                     ?,            /* не фильтруем */
                                     consumerH) no-error.   /* указатель на обработчик сообщений */
if error-status:error then do:
    run savelog('aml','kfmAMLAdd-> error receiveFromQueue').
    message 'kfmAMLAdd-> error receiveFromQueue'.
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

    define var requestText as char no-undo.
    define var replyText as char no-undo.
    define var pRes as integer no-undo.

    /*output to rep.log append.*/

    requestText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(requestText,"=") = 2 and entry(1,requestText,"=") = "qcommand" and trim(entry(2,requestText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,requestText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:

        hide message no-pause.
        message string(time,"hh:mm:ss") + ' ' + requestText.

        /*
        put unformatted "ws_service: requestText='" + requestText + "'" skip.
        put unformatted "ws_service: requestText='" + requestText + "'" + " replyText='" + replyText + "'" skip.
        */
        /*
        run savelog( "mcbws" + string(p-copy,"99"), "ws_service: requestText='" + requestText + "'" + " replyText='" + replyText + "'").
        */

        empty temp-table t-part.
        empty temp-table t-founder.

        def var v-path as char no-undo.
        v-path = '/data/b'.

        if requestText begins "txb" then do:
            if connected ("txb") then disconnect "txb".
            find first comm.txb where comm.txb.bank = requestText and comm.txb.consolid no-lock no-error.
            if avail comm.txb then do:
                connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                run kfmAMLAdd2("bank", requestText, output pRes).
                if connected ("txb") then disconnect "txb".
            end.
        end.
        else
        if requestText begins "cm" then do:
            find first cifmin where cifmin.cifmin = requestText no-lock no-error.
            if avail cifmin then do:
                run createPParam("memberKind",'5','i'). /* участник */
                run createPParam("memberRole",'1','i'). /* самостоятельно */
                run createPParam("memberResBool",cifmin.res,'i').
                memberResCountryCode = '0'.
                if cifmin.res = '1' then memberResCountryCode = '398'.
                else
                if cifmin.res = '0' then do:
                    if num-entries(cifmin.addr) = 7 then do:
                        v-str = entry(1,cifmin.addr).
                        if num-entries(v-str,'(') = 2 then v-str2 = substr(entry(2,v-str,'('),1,2).
                        find first code-st where code-st.code = v-str2 no-lock no-error.
                        if avail code-st then memberResCountryCode = code-st.cod-ch.
                    end.
                end.
                run createPParam("memberResCountryCode",memberResCountryCode,'c').
                run createPParam("memberType",'2','i').
                run createPParam("memberForeignCode",cifmin.publicf,'i').
                run createPParam("memberForeignExtra",'','c').
                run createPParam("memberTaxCode",cifmin.rnn,'c').
                run createPParam("memberMainCode",cifmin.iin,'c').
                run createPParam("memberPhone",cifmin.tel,'c').
                /*run createPParam("memberEmail",memberEmail,'c').*/
                run parseAddress("memberReg", '', cifmin.addr).
                run createPParam("memberAcFirstName",cifmin.name,'c').
                run createPParam("memberAcSecondName",cifmin.fam,'c').
                run createPParam("memberAcMiddleName",cifmin.mname,'c').
                run createPParam("memberAcDocTypeCode",cifmin.doctype,'c').
                run createPParam("memberAcDocNumber",cifmin.docnum,'c').
                run createPParam("memberAcDocWhom",cifmin.docwho,'c').
                if cifmin.docdt <> ? then run createPParam("memberAcDocIssueDate",replace(string(cifmin.docdt,"99/99/9999"),'/','.') + " 00:00:00",'c').
                if cifmin.bdt <> ? then run createPParam("memberAcBirthDate",replace(string(cifmin.bdt,"99/99/9999"),'/','.') + " 00:00:00",'c').
                run createPParam("memberAcBirthPlace",cifmin.bplace,'c').
                run createPParam("memberFoundersCount",'0','i').
            end.
        end.
        else do:
            pRes = 0.
            v-txb = ?.
            v-txb = entry(lookup(substring(requestText,1,1),fs),fsb) no-error.
            if (v-txb <> ?) and (v-txb <> '') then do:
                do i = 1 to num-entries(v-txb,"|"):
                    find first comm.txb where comm.txb.bank = entry(i,v-txb,"|") and comm.txb.consolid no-lock no-error.
                    if avail comm.txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                        run kfmAMLAdd2("cif", requestText, output pRes).
                        if connected ("txb") then disconnect "txb".
                    end.
                    if pRes = 1 then leave.
                end.
            end.
        end.

        /* создаем ответное сообщение, отправляется автоматом, когда контроль передается реализации 4GL-To-JMS */
        run deleteMessage in requestH.
        replyH = replyMessage.

        run reset in replyH.
        run clearBody in replyH.
        run clearProperties in replyH.

        for each t-part no-lock:
            if t-part.pType = 'c' then run setStringProperty in replyH(t-part.pName, t-part.pValue).
            else
            if t-part.pType = 'i' then do:
                i = 0.
                i = integer(t-part.pValue) no-error.
                run setIntProperty in replyH(t-part.pName, i).
            end.
        end.

        for each t-founder no-lock:
            if t-founder.pType = 'c' then run setStringProperty in replyH(t-founder.pName, t-founder.pValue).
            else
            if t-founder.pType = 'i' then do:
                i = 0.
                i = integer(t-founder.pValue) no-error.
                run setIntProperty in replyH(t-founder.pName, i).
            end.
        end.

        run setText in replyH (replyText).

        /*output close.*/
    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.


