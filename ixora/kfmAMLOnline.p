/* kfmAMLOnline.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Запрос к сервису AMLOnline
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
        12/07/2010 madiyar - коннект к боевому сонику
        22/09/2010 madiyar - 3-хпозиционный статус операции
        12/10/2010 madiyar - в статусе может быть цифра '2'; при наличии - запрещаем проведение операции
        04/11/2010 madiyar - операции аффилированных лиц пропускаем с отображением в АМЛ
        05/11/2010 madiyar - подправил сообщения об ошибках
        08/11/2010 madiyar - удалилось изменение от 04/11/2010, исправил
        06/09/2012 madiyar - тестовый/боевой сервер
        20/09/2012 madiyar - новый справочник от World Compliance
        21/09/2012 madiyar - коды операций - в верхний регистр
        22.09.2012 evseev - вернул проверку на первый справочник
        11/10/2012 madiyar - проверка на time_out
        12/10/2012 madiyar - добавил выходной статус 2
        18/10/2012 madiyar - включаем стопы
        23/11/2012 madiyar - добавил сохранение файлов запросов-ответов в архив
        29/01/2013 madiyar - стопим операции по первому справочнику
        29.01.2013 evseev - recompile
*/

{srvcheck.i}

def input parameter p-bankOperationID as char no-undo.      /* jou000073a */
def input parameter p-beneficiaryCountry as char no-undo.   /* KAZ */
def input parameter p-beneficiaryName as char no-undo.      /* ТОО Куку */
def input parameter p-beneficiaryNameList as char no-undo.  /* ФИО1|ФИО2|ФИО3| */
def input parameter p-checkBlackListBool as char no-undo.   /* 0 или 1 */
def input parameter p-issueDBID as char no-undo.            /* 1 */
def input parameter p-senderCountry as char no-undo.        /* KAZ */
def input parameter p-senderName as char no-undo.           /* ТОО Куку2 */
def input parameter p-senderNameList as char no-undo.       /* ФИО4|ФИО5|ФИО6| */

def output parameter p-errorDes as char no-undo.            /* описание ошибки, если пусто - ошибок нет */
def output parameter p-operId as char no-undo.              /* jou000073a */
def output parameter p-operStatus as char no-undo.          /* 0 (остановлено), 1 (разрешено), 2 (запрещено) */
def output parameter p-operComment as char no-undo.         /* комментарий - максимальный процент совпадения */

def var v-operSts3 as char no-undo.            /* 3-хпозиционный статус операции вида "ххх", где х - 0 или 1 */
def var v-dir as char no-undo.
def var v-exist as char no-undo.
def var v-file as char no-undo.
def stream slog.
def shared var g-today as date.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def shared var g-ofc as char.
def var dt as date no-undo.
def var tt as integer no-undo.
def var time_int as integer no-undo.
def var time_out as integer no-undo.

time_out = 300.
find first pksysc where pksysc.sysc = 'kfmOn' no-lock no-error.
if avail pksysc then time_out = pksysc.inval.

def var errorCode as integer no-undo.
def var q_name as char no-undo.
q_name = "AMLOnlineQ".

function checkSts returns logical (input sts as char).
    def var res as logical no-undo.
    def var j as integer no-undo.
    res = yes.
    if sts = '' then res = no.
    if length(sts) <> 3 then res = no.
    if res then do:
        do j = 1 to 3:
            if index("012",substring(sts,j,1)) = 0 then do:
                res = no.
                leave.
            end.
        end.
    end.
    return res.
end function.

time_int = 0.
find last amlonline where amlonline.operCode = p-bankOperationID no-lock no-error.
if avail amlonline then do:
    dt = today.
    tt = time.
    time_int = (dt - amlonline.rdt) * 86400 + tt - amlonline.rtim.
    if time_int < time_out then do:
        errorCode = 100.
        p-errorDes = "(" + string(errorCode) + ") Не истекло время предыдущего запроса. Попробуйте через несколько минут.".
        return.
    end.
end.

v-operSts3 = ''.
p-operStatus = ''.

if trim(p-bankOperationID) = '' then do:
    errorCode = 101.
    p-errorDes = "(" + string(errorCode) + ") Некорректный запрос".
    return.
end.


def var ptpsession as handle.
def var consumerh as handle.
def var requesth as handle.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("172.16.1.22:2507").
else run setbrokerurl in ptpsession ("172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.

/* create a message */
run createxmlmessage in ptpsession (output requesth).

/* creates a consumer for the reply  */
run createmessageconsumer in ptpsession (
                              this-procedure, /* this proc will handle it */
                             "replyhandler", /* name of internal procedure */
                              output consumerh).

/* start receiving replies */
run startreceivemessages in ptpsession.

/* fill the outgoing message */
run settext in requesth (p-bankOperationID).
p-bankOperationID = caps(p-bankOperationID).
run setStringProperty in requesth("bankOperationID", p-bankOperationID).
run setStringProperty in requesth("beneficiaryCountry", p-beneficiaryCountry).
run setStringProperty in requesth("beneficiaryName", p-beneficiaryName).
run setStringProperty in requesth("beneficiaryNameList", p-beneficiaryNameList).
run setStringProperty in requesth("checkBlackListBool", p-checkBlackListBool).
run setStringProperty in requesth("issueDBID", p-issueDBID).
run setStringProperty in requesth("senderCountry", p-senderCountry).
run setStringProperty in requesth("senderName", p-senderName).
run setStringProperty in requesth("senderNameList", p-senderNameList).

/* log the outgoing data */
v-dir = "/data/export/aml/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-dir + ";echo $?").
repeat:
    import unformatted v-exist.
end.
if v-exist <> "0" then do:
    unix silent value ("mkdir " + v-dir).
    unix silent value("chmod 777 " + v-dir).
end.
v-file = v-dir + p-bankOperationID + "_" + string(time) + ".txt".
output stream slog to value(v-file).
put stream slog unformatted
    "_request_time=" string(time,"hh:mm:ss") skip
    "bankOperationID=" p-bankOperationID skip
    "beneficiaryCountry=" p-beneficiaryCountry skip
    "beneficiaryName=" p-beneficiaryName skip
    "beneficiaryNameList=" p-beneficiaryNameList skip
    "checkBlackListBool=" p-checkBlackListBool skip
    "issueDBID=" p-issueDBID skip
    "senderCountry=" p-senderCountry skip
    "senderName=" p-senderName skip
    "senderNameList=" p-senderNameList skip(1).
output stream slog close.

/* send a request to the requestqueue and handle the reply in the replyhandler internal procedure. */
run requestreply in ptpsession ( q_name,
                                 requesth,
                                 ?, /* no reply selector */
                                 consumerh,
                                 ?, /* priority */
                                 120000, /* Time to Live, milliseconds */
                                 "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
                                 ).

run deletemessage in requesth.

/* wait for the reply. */
wait-for u1 of this-procedure.

run stopReceiveMessages in ptpsession.
run deleteSession in ptpsession.


procedure replyhandler:
    define input parameter replyh as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.

    def var v-reply as char no-undo.
    def var pNames as char no-undo.

    /* get the reply from the service */
    v-reply = dynamic-function('gettext':u in replyh).

    output stream slog to value(v-file) append.
    put stream slog unformatted
        "_response_time=" string(time,"hh:mm:ss") skip
        "response=" v-reply skip.

    if num-entries(v-reply,"=") = 2 then do:
        errorCode = integer(entry(2,v-reply,'=')) no-error.
        if error-status:error then do:
            errorCode = 102.
            p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа".
        end.
        else do:
            pNames = dynamic-function('getPropertyNames':u in replyh).
            if errorCode = 0 then do:
                if lookup("operId",pNames) > 0 then p-operId = dynamic-function('getCharProperty':u in replyh, "operId").
                if lookup("operStatus",pNames) > 0 then v-operSts3 = dynamic-function('getCharProperty':u in replyh, "operStatus").
                if lookup("operComment",pNames) > 0 then p-operComment = dynamic-function('getCharProperty':u in replyh, "operComment").

                put stream slog unformatted
                    "operStatus=" v-operSts3 skip
                    "operComment=" p-operComment skip.

                if checkSts(v-operSts3) then do:
                    if index(v-operSts3,'2') > 0 then p-operStatus = '2'. /* операция запрещена комплаенсом */
                    else do:
                        if substring(v-operSts3,1,1) = '0' then p-operStatus = '0'. /* справочник террористов */
                        /* if substring(v-operSts3,2,1) = '0' then p-operStatus = '0'. */ /* справочник ИПДЛ WOrldCompliance - пропускаем с отображением в АМЛ */
                        /* if substring(v-operSts3,3,1) = '0' then p-operStatus = '0'. */ /* справочник аффилированных лиц - пропускаем с отображением в АМЛ */
                        if p-operStatus = '' then p-operStatus = '1'.
                    end.
                    if (p-operStatus = '0') or (p-operStatus = '2') then do transaction:
                        create amlonline.
                        assign amlonline.bank = s-ourbank
                               amlonline.operCode = p-bankOperationID
                               amlonline.sts = v-operSts3
                               amlonline.who = g-ofc
                               amlonline.rdt = today
                               amlonline.rtim = time.
                    end.
                end.
                else do:
                    errorCode = 103.
                    p-errorDes = "(" + string(errorCode) + ") Некорректный статус [" + v-operSts3 + "]".
                end.

            end.
            else do:
                if lookup("errordes",pNames) > 0 then p-errorDes = dynamic-function('getCharProperty':u in replyh, "errordes").
                else p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа - нет описания ошибки".
            end.
        end.
    end.
    else do:
        errorCode = 104.
        p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа".
    end.

    output stream slog close.

    run deletemessage in replyh.

    apply "u1" to this-procedure.
end.
